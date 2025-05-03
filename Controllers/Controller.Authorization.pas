unit Controller.Authorization;

interface

procedure Registry;

implementation

uses
  Horse,
  Provider.Connection,
  System.JSON,
  Provider.Authorization,
  System.SysUtils,
  Model.Usuario,
  Data.SqlExpr,
  Data.Win.ADODB,
  Data.DB,
  ActiveX,
  Vcl.Dialogs;

procedure Post(Req: THorseRequest; Res: THorseResponse);
var
  LToken: string;
  LBody: TJSONObject;
  LConnection: TConnectionProvider;
  LUsuario: TUsuario;
begin

  try
    try
      CoInitialize(nil);
      LConnection := TConnectionProvider.Create;
      LUsuario := TUsuario.Create;
      LBody := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;

      if LUsuario.ValidarUsuario(LConnection, LBody.GetValue('username').Value, LBody.GetValue('password').Value) then
      begin
        LToken := getToken(LBody.GetValue('username').Value);
        WriteLn(LToken);
        Res.Send(TJSONObject.Create.AddPair('token', LToken).ToJSON).Status(200);
      end
      else
      begin
        Res.Send('Usuário Inválido').Status(401);
      end;
    finally
      LConnection.Free;
      LUsuario.Free;
    end;
  finally
    CoUninitialize;
  end;



end;

procedure Registry;
begin
  THorse.Post('/api/login', Post);
end;

end.
