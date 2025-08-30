unit Controller.Dashboard;

interface

procedure Registry;

implementation

uses
  Horse,
  DataSet.Serialize,
  Provider.Connection,
  Data.SqlExpr,
  Data.Win.ADODB,
  Data.DB,
  Windows,
  ActiveX,
  Provider.Authorization,
  JOSE.Types.JSON,
  Model.Dashboard,
  System.SysUtils,
  GetTimestamp;

procedure GetEmocoes(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LDashboard: TDashboard;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LDashboard := TDashboard.Create;

    if not Req.Query.Dictionary.ContainsKey('idpaciente') then
    begin
      Res.Send('Envie o id do paciente').Status(400);
      Exit;
    end;

    if not Req.Query.Dictionary.ContainsKey('idpsicologo') then
    begin
      Res.Send('Envie o id do psicólogo').Status(400);
      Exit;
    end;

    Res.Send(LDashboard.DashboardEmocoes(StrToInt(Req.Query.Items['idpsicologo']),
    StrToInt(Req.Query.Items['idpaciente']),LConnection.GetConnection).
    ToJSONArrayString()).Status(200);
  finally
    CoUninitialize;
  end;
end;

procedure GetRegistros(Req: THorseRequest; Res: THorseResponse);
begin

end;

procedure GetPacientes(Req: THorseRequest; Res: THorseResponse);
begin

end;


procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/dashboard/emocoes', GetEmocoes);
  THorse.AddCallback(Authorization()).Get('/api/dashboard/registros', GetRegistros);
  THorse.AddCallback(Authorization()).Get('/api/dashboard/pacientes', GetPacientes);
end;

end.
