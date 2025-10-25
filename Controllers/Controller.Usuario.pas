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
  SSQL: string;
begin
  COInitialize(nil);
  try
    try
      LQuery := TADOQuery.Create(nil);
      LConnection := TConnectionProvider.Create;

      if Req.Query.ContainsKey('idusuario') then
        SSQL := 'SELECT id_usuario, papel, primeiro_nome, sobrenome, ' +
        ' data_nascimento, email, telefone, senha FROM usuarios WHERE id_usuario = ' +
        Req.Query.Items['idusuario']
      else
        SSQL := 'SELECT id_usuario, papel, primeiro_nome, sobrenome, ' +
        ' data_nascimento, email, telefone, senha FROM usuarios';

      with LQuery do
      begin
        Connection := LConnection.GetConnection;
        SQL.Text := SSQL;
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
