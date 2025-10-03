unit Controller.Usuario;

interface

procedure Registry;

implementation

uses
  Horse,
  Provider.Authorization,
  Provider.Connection,
  Data.Win.ADODB,
  Dataset.Serialize,
  ActiveX,
  System.SysUtils;

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LQuery: TADOQuery;
  LConnection: TConnectionProvider;
begin
  COInitialize(nil);
  try
    try
      LQuery := TADOQuery.Create(nil);
      LConnection := TConnectionProvider.Create;
      with LQuery do
      begin
        Connection := LConnection.GetConnection;
        SQL.Text := 'SELECT id_usuario, papel, primeiro_nome, sobrenome, ' +
        ' data_nascimento, email, telefone FROM usuarios';
        Open;
      end;

      Res.Send(LQuery.ToJSONArrayString()).Status(200);
    finally
      LQuery.Free;
    end;
  finally
    CoUninitialize;
    FreeAndNil(LConnection);
  end;
end;

procedure Registry;
begin
  THorse.AddCallBack(Authorization()).Get('/api/usuarios', Get);
end;

end.
