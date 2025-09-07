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

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LDashboard: TDashboard;
  LTotalAnotacoes, LTotalPacientes: Integer;
  LJSON: TJSONObject;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LDashboard := TDashboard.Create;

    if not Req.Query.Dictionary.ContainsKey('idpsicologo') then
    begin
      Res.Send('[ERRO] Envie o id do psicólogo').Status(400);
      Exit;
    end;

    LTotalAnotacoes := LDashboard.TotalAnotacoes(Req.Query.Items['idpsicologo'].ToInteger(),
    LConnection.GetConnection);

    LTotalPacientes := LDashboard.TotalPacientes(Req.Query.Items['idpsicologo'].ToInteger(),
    LConnection.GetConnection);

    LJSON := TJSONObject.Create.AddPair('anotacoes', LTotalAnotacoes)
    .AddPair('pacientes', LTotalPacientes);
    try
      Res.ContentType('application/json')
         .Send(LJSON.ToJSON)
         .Status(200);
    finally
      LJSON.Free;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/dashboard', Get);
end;

end.
