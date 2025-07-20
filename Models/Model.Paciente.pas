unit Model.Paciente;

interface

uses
  Model.Usuario,
  Data.Win.ADODB;

type
  TPaciente = class(TUsuario)
    private
      FDataNascimento: TDate;
    public
    function CriarPaciente(APrimeiroNome, ASobrenome, ADataNascimento,
    AEmail, ATelefone, ASenha: string; AIdPsicologo: Integer;
    AConnection: TADOConnection): Boolean;
    procedure AtualizarPrimeiroNome(APrimeiroNome: string; AIdPaciente: Integer;
    AConnection: TADOConnection);
    procedure AtualizarSobrenome(ASobrenome: string; AIdPaciente: Integer;
    AConnection: TADOConnection);
    procedure AtualizarDataNascimento(ADataNascimento: string; AIdPaciente: Integer;
    AConnection: TADOConnection);
    procedure AtualizarEmail(AEmail: string;
    AIdPaciente: Integer; AConnection: TADOConnection);
    procedure AtualizarTelefone(ATelefone: string;
    AIdPaciente: Integer; AConnection: TADOConnection);
    procedure AtualizarSenha(ASenha: string;
    AIdPaciente: Integer; AConnection: TADOConnection);
    function ExcluirPaciente(AIdUsuario: Integer;
    AConnection: TADOConnection): Boolean;
  end;

implementation

uses
  System.SysUtils;

function TPaciente.CriarPaciente(APrimeiroNome, ASobrenome, ADataNascimento,
  AEmail, ATelefone, ASenha: string; AIdPsicologo: Integer;
  AConnection: TADOConnection): Boolean;
var
  LSQLUsuario: string;
  LSQLPaciente: string;
  LQueryBusca: TADOQuery;
begin
  Result := False;
  AConnection.BeginTrans;
  try
    // Inserir na tabela USUARIOS
    LSQLUsuario := 'INSERT INTO USUARIOS (papel, primeiro_nome, sobrenome, ' +
      'data_nascimento, email, telefone, senha) VALUES (' +
      QuotedStr('paciente') + ', ' +
      QuotedStr(APrimeiroNome) + ', ' +
      QuotedStr(ASobrenome) + ', ' +
      QuotedStr(ADataNascimento) + ', ' +
      QuotedStr(AEmail) + ', ' +
      QuotedStr(ATelefone) + ', ' +
      QuotedStr(ASenha) + ')';

    AConnection.Execute(LSQLUsuario);

    // Buscar ID do usuário recém-criado
    LQueryBusca := TADOQuery.Create(nil);
    try
      LQueryBusca.Connection := AConnection;
      LQueryBusca.SQL.Text := 'SELECT id_usuario FROM USUARIOS WHERE email = ' + QuotedStr(AEmail);
      LQueryBusca.Open;

      if not LQueryBusca.IsEmpty then
      begin
        // Inserir na tabela PSICOLOGOS
        LSQLPaciente := 'INSERT INTO PACIENTES(id_usuario, id_psicologo) VALUES (' +
          LQueryBusca.FieldByName('id_usuario').AsString + ',' +
          IntToStr(AIdPsicologo) + ')';

        AConnection.Execute(LSQLPaciente);

        AConnection.CommitTrans;
        Result := True;
      end
      else
      begin
        AConnection.RollbackTrans;
      end;
    finally
      LQueryBusca.Free;
    end;
  except
    AConnection.RollbackTrans;
    Result := False;
  end;
end;

procedure TPaciente.AtualizarPrimeiroNome(APrimeiroNome: string;
  AIdPaciente: Integer; AConnection: TADOConnection);
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE usuarios SET primeiro_nome = %s WHERE id_usuario = %d',
    [QuotedStr(APrimeiroNome), AIdPaciente]);
    AConnection.Execute(LSQL);
  except
    raise;
  end;
end;

procedure TPaciente.AtualizarSobrenome(ASobrenome: string; AIdPaciente: Integer;
  AConnection: TADOConnection);
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE usuarios SET sobrenome = %s WHERE id_usuario = %d',
    [QuotedStr(ASobrenome), AIdPaciente]);
    AConnection.Execute(LSQL);
  except
    raise;
  end;
end;

procedure TPaciente.AtualizarDataNascimento(ADataNascimento: string;
  AIdPaciente: Integer; AConnection: TADOConnection);
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE usuarios SET data_nascimento = %s WHERE id_usuario = %d',
    [QuotedStr(ADataNascimento), AIdPaciente]);
    AConnection.Execute(LSQL);
  except
    raise;
  end;
end;

procedure TPaciente.AtualizarEmail(AEmail: string;
  AIdPaciente: Integer; AConnection: TADOConnection);
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE usuarios SET email = %s WHERE id_usuario = %d',
    [QuotedStr(AEmail), AIdPaciente]);
    AConnection.Execute(LSQL);
  except
    raise;
  end;
end;

procedure TPaciente.AtualizarTelefone(ATelefone: string;
  AIdPaciente: Integer; AConnection: TADOConnection);
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE usuarios SET telefone = %s WHERE id_usuario = %d',
    [QuotedStr(ATelefone), AIdPaciente]);
    AConnection.Execute(LSQL);
  except
    raise;
  end;
end;

procedure TPaciente.AtualizarSenha(ASenha: string;
  AIdPaciente: Integer; AConnection: TADOConnection);
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE usuarios SET senha = %s WHERE id_usuario = %d',
    [QuotedStr(ASenha), AIdPaciente]);
    AConnection.Execute(LSQL);
  except
    raise;
  end;
end;

function TPaciente.ExcluirPaciente(AIdUsuario: Integer;
  AConnection: TADOConnection): Boolean;
var
  LSQL: string;
  LQuery: TADOQuery;
  LIdPaciente: Integer;
begin
  try
    AConnection.BeginTrans;

    LQuery := TADOQuery.Create(nil);
    LQuery.Connection := AConnection;

    with LQuery do
    begin
      Close;
      SQL.Text := Format('SELECT * FROM pacientes where id_usuario = %d',
      [AIdUsuario]);
      Open;
    end;

    LSQL := Format('DELETE FROM psicologo_notas where id_paciente = %d',
    [LQuery.FieldByName('id_paciente').AsInteger]);
    AConnection.Execute(LSQL);

    LSQL := Format('DELETE FROM pacientes where id_usuario = %d',
    [AIdUsuario]);
    AConnection.Execute(LSQL);

    LSQL := Format('DELETE FROM usuarios where id_usuario = %d AND papel = ''paciente'' ',
    [AIdUsuario]);
    AConnection.Execute(LSQL);
    AConnection.CommitTrans;

    Result := True;
  except
    AConnection.RollbackTrans;
    Result := False;
  end;
end;

end.
