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
  try
    LSQLUsuario := ' INSERT INTO USUARIOS (papel, primeiro_nome, sobrenome, ' +
            ' data_nascimento, email, telefone, senha) ' +
            ' VALUES (''psicologo'', ' + QuotedStr(APrimeiroNome) + ', ' +
            QuotedStr(ASobrenome) + ', ' + QuotedStr(ADataNascimento) + ', ' +
            QuotedStr(AEmail) + ', ' + QuotedStr(ATelefone) + ', ' +
            QuotedStr(ASenha) + ')';

    AConnection.Execute(LSQLUsuario);

    LQueryBusca := TADOQuery.Create(nil);
    LQueryBusca.Connection := AConnection;
    With LQueryBusca do
    begin
      Close;
      SQL.Text := ' SELECT id_usuario FROM USUARIOS WHERE email = ' +
      QuotedStr(AEmail);
      Open;
    end;

    LSQLPsicologo := ' INSERT INTO PSICOLOGOS (id_usuario, crp) VALUES (' +
    QuotedStr(LQueryBusca.FieldByName('id_usuario').AsString) + ', ' +
    QuotedStr(ACRM) + ')';

    AConnection.Execute(LSQLPsicologo);

    Result := True;

  except
    Result := False;
  end;
end;

end.
