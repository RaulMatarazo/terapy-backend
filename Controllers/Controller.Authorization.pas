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
  LRole: string;
begin

  try
    try
      CoInitialize(nil);
      LConnection := TConnectionProvider.Create;
      LUsuario := TUsuario.Create;
      LBody := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;

      if LUsuario.ValidarUsuario(LConnection, LBody.GetValue('username').Value, LBody.GetValue('password').Value, LRole) then
      begin
        LToken := getToken(LBody.GetValue('username').Value);
        WriteLn(LToken);
        Res.Send(TJSONObject.Create.AddPair('token', LToken).AddPair('papel', LRole).ToJSON).Status(200);
      end
      else
      begin
        Res.Send('Usuário Inválido').Status(203);
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
