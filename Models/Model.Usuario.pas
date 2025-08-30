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
      function ValidarUsuario(AConnection: TConnectionProvider; AUsername, APassword: string; var ARole, AIDPsicologo, AIDPaciente: string): Boolean;
  end;

implementation

uses
  Data.Win.ADODB,
  Data.SqlExpr,
  System.SysUtils;

function TUsuario.ValidarUsuario(AConnection: TConnectionProvider; AUsername, APassword: string; var ARole, AIDPsicologo, AIDPaciente: string): Boolean;
var
  LQuery: TADOQuery;
  LQueryPsicologo: TADOQuery;
  LQueryPaciente: TADOQuery;
begin
    try
      LQuery := TADOQuery.Create(nil);
      With LQuery do
      begin
        Connection := AConnection.GetConnection;
        SQL.Text := 'SELECT * FROM usuarios WHERE email = ' + QuotedStr(AUsername) + ' AND senha = ' + QuotedStr(APassword);
        Open;
      end;

      if (LQuery.ExecSQL = 1) then
      begin
        ARole := LQuery.FieldByName('papel').AsString;
        if ARole = 'psicologo' then
        begin
          LQueryPsicologo := TADOQuery.Create(nil);
          with LQueryPsicologo do
          begin
            Connection := AConnection.GetConnection;
            SQL.Text := Format('select * from psicologos where id_usuario = %d',
            [LQuery.FieldByName('id_usuario').AsInteger]);
            Open;
          end;
          AIDPsicologo := LQueryPsicologo.FieldByName('id_psicologo').AsString;
        end
        else if ARole = 'paciente' then
        begin
          LQueryPaciente := TADOQuery.Create(nil);
          with LQueryPaciente do
          begin
            Connection := AConnection.GetConnection;
            SQL.Text := Format('select * from pacientes where id_usuario = %d', [LQuery.FieldByName('id_usuario').AsInteger]);
            Open;
          end;
          AIDPaciente := LQueryPaciente.FieldByName('id_paciente').AsString;
          AIDPsicologo := LQueryPaciente.FieldByName('id_psicologo').AsString;
        end;
        Result := True;
      end
      else
        Result := False;
  finally
    LQuery.Free;
  end;

end;

end.
