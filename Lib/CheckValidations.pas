unit CheckValidations;

interface

uses
  Data.Win.ADODB;

function ValidarEmail(AEmail: string; AConnection:
TADOConnection): Boolean;

function ValidarEmailID(AEmail: string; AID: Integer;
AConnection: TADOConnection): Boolean;

function ValidarTelefone(ATelefone: string;
AConnection: TADOConnection): Boolean;

function ValidarTelefoneID(ATelefone: string; AID: Integer;
AConnection: TADOConnection): Boolean;

implementation

uses
  System.SysUtils;

function ValidarEmail(AEmail: string;
  AConnection: TADOConnection): Boolean;
var
  LSQL: string;
  LQuery: TADOQuery;
begin
  try
    LQuery := TADOQuery.Create(nil);
    LQuery.Connection := AConnection;
    with LQuery do
    begin
      Close;
      SQL.Text := Format('SELECT * FROM usuarios WHERE email = %s', [QuotedStr(AEmail)]);
      Open;
    end;

    Result := LQuery.RecordCount > 0;

  except
    raise;
  end;
end;

function ValidarEmailID(AEmail: string; AID: Integer;
  AConnection: TADOConnection): Boolean;
var
  LSQL: string;
  LQuery: TADOQuery;
begin
  try
    LQuery := TADOQuery.Create(nil);
    LQuery.Connection := AConnection;
    with LQuery do
    begin
      Close;
      SQL.Text := Format('SELECT * FROM usuarios WHERE email = %s AND id_usuario <> %d',
      [QuotedStr(AEmail), AID]);
      Open;
    end;

    Result := LQuery.RecordCount > 0;

  except
    raise;
  end;
end;

function ValidarTelefone(ATelefone: string;
  AConnection: TADOConnection): Boolean;
var
  LSQL: string;
  LQuery: TADOQuery;
begin
  try
    LQuery := TADOQuery.Create(nil);
    LQuery.Connection := AConnection;
    with LQuery do
    begin
      Close;
      SQL.Text := Format('SELECT * FROM usuarios WHERE telefone = %s', [QuotedStr(ATelefone)]);
      Open;
    end;

    Result := LQuery.RecordCount > 0;

  except
    raise;
  end;
end;

function ValidarTelefoneID(ATelefone: string; AID: Integer;
  AConnection: TADOConnection): Boolean;
var
  LSQL: string;
  LQuery: TADOQuery;
begin
  try
    LQuery := TADOQuery.Create(nil);
    LQuery.Connection := AConnection;
    with LQuery do
    begin
      Close;
      SQL.Text := Format('SELECT * FROM usuarios WHERE telefone = %s AND id_usuario <> %d',
      [QuotedStr(ATelefone), AID]);
      Open;
    end;

    Result := LQuery.RecordCount > 0;

  except
    raise;
  end;
end;

end.
