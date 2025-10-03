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
  LRole, LIDPsicologo, LIDPaciente: string;
begin

  try
    try
      CoInitialize(nil);
      LConnection := TConnectionProvider.Create;
      LUsuario := TUsuario.Create;
      LBody := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;

      if LUsuario.ValidarUsuario(LConnection, LBody.GetValue('username').Value, LBody.GetValue('password').Value, LRole, LIDPsicologo, LIDPaciente) then
      begin
        LToken := getToken(LBody.GetValue('username').Value);
        //WriteLn(LToken);
        if LRole = 'psicologo' then
          Res.Send(TJSONObject.Create.AddPair('token', LToken).AddPair('papel', LRole).AddPair('idpsicologo', LIDPsicologo).ToJSON).Status(200)
        else if LRole = 'paciente' then
          Res.Send(TJSONObject.Create.AddPair('token', LToken).AddPair('papel', LRole).AddPair('idpaciente', LIDPsicologo).ToJSON).Status(200)
        else if LRole = 'admin' then
          Res.Send('Entre como paciente ou psicólogo, função de admin indisponível no momento').Status(240);
      end
      else
      begin
        Res.Send('Usuário Inválido').Status(203);
      end;
    finally
      LUsuario.Free;
    end;
  finally
    CoUninitialize;
    FreeAndNil(LConnection);
  end;



end;

procedure Registry;
begin
  THorse.Post('/api/login', Post);
end;

end.
