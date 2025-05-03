unit Model.Usuario;

interface

uses
  Provider.Connection;

type
  TUsuario = class
    private
      FID: Integer;
      FPrimeiroNome: string;
      FSobrenome: string;
      FEmail: string;
      FTelefone: string;
      FSenha: string;
    public
      function ValidarUsuario(AConnection: TConnectionProvider; AUsername, APassword: string): Boolean;
  end;

implementation

uses
  Data.Win.ADODB,
  Data.SqlExpr,
  System.SysUtils;

function TUsuario.ValidarUsuario(AConnection: TConnectionProvider; AUsername, APassword: string): Boolean;
var
  LQuery: TADOQuery;
begin
    try
     LQuery := TADOQuery.Create(nil);
    With LQuery do
    begin
      Connection := AConnection.GetConnection;
      SQL.Text := 'SELECT * FROM users WHERE username = ' + QuotedStr(AUsername) + ' AND password = ' + QuotedStr(APassword);
      Open;
    end;
    if (LQuery.ExecSQL = 1) then
    begin
      Result := True;
    end
    else
      Result := False;
  finally
    LQuery.Free;
  end;

end;

end.
