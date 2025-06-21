unit Model.Psicologo;

interface

uses
  Model.Usuario,
  Data.Win.ADODB;

type
  TPsicologo = class(TUsuario)
    private
      FCRP: Integer;
    public
      function CriarPsicologo(APrimeiroNome, ASobrenome, ADataNascimento,
      AEmail, ATelefone, ASenha, ACRM: string; AConnection: TADOConnection): Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TPsicologo }

function TPsicologo.CriarPsicologo(APrimeiroNome, ASobrenome, ADataNascimento,
  AEmail, ATelefone, ASenha, ACRM: string; AConnection: TADOConnection): Boolean;
var
  LSQLUsuario: string;
  LSQLPsicologo: string;
  LQueryBusca: TADOQuery;
begin
  Result := False;
  AConnection.BeginTrans;
  try
    // Inserir na tabela USUARIOS
    LSQLUsuario := 'INSERT INTO USUARIOS (papel, primeiro_nome, sobrenome, ' +
      'data_nascimento, email, telefone, senha) VALUES (' +
      QuotedStr('psicologo') + ', ' +
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
        LSQLPsicologo := 'INSERT INTO PSICOLOGOS (id_usuario, crp) VALUES (' +
          LQueryBusca.FieldByName('id_usuario').AsString + ', ' +
          QuotedStr(ACRM) + ')';

        AConnection.Execute(LSQLPsicologo);

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


end.
