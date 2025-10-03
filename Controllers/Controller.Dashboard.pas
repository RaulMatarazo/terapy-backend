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
  GetTimestamp,
  GetArrayToTJSONArray;

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LDashboard: TDashboard;
  LTotalAnotacoes, LTotalPacientes: Integer;
  LGraficoEmocoes: TJSONArray;
  LGraficoEmocoesJSON: TJSONArray;
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


    if not Req.Query.Dictionary.ContainsKey('idpaciente') then
    begin
      Res.Send('[ERRO] Envie o id do paciente').Status(400);
      Exit;
    end;

    if not Req.Query.Dictionary.ContainsKey('inicio') then
    begin
      Res.Send('[ERRO] Envie o parâmetro de início').Status(400);
      Exit;
    end;

    if not Req.Query.Dictionary.ContainsKey('fim') then
    begin
      Res.Send('[ERRO] Envie o parâmetro de fim').Status(400);
      Exit;
    end;

    LTotalAnotacoes := LDashboard.TotalAnotacoes(Req.Query.Items['idpsicologo'].ToInteger(),
    LConnection.GetConnection);

    LTotalPacientes := LDashboard.TotalPacientes(Req.Query.Items['idpsicologo'].ToInteger(),
    LConnection.GetConnection);

    LGraficoEmocoes := LDashboard.GraficoEmocoes(StrToInt(Req.Query.Items['idpaciente']),
    Req.Query.Items['inicio'], Req.Query.Items['fim'], LConnection.GetConnection);

   // LGraficoEmocoesJSON := ArrayToJsonArray(LGraficoEmocoes);

    LJSON := TJSONObject.Create.AddPair('anotacoes', LTotalAnotacoes)
   .AddPair('pacientes', LTotalPacientes).AddPair('totalEmocoes', LGraficoEmocoes);
    try
      Res.ContentType('application/json')
         .Send(LJSON.ToJSON)
         .Status(200);
    finally
      LJSON.Free;
    end;
  finally
    CoUninitialize;
    FreeAndNil(LConnection);
  end;
end;

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/dashboard', Get);
end;

end.
