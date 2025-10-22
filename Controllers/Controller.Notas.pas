unit Controller.Notas;

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
  Model.Notas,
  System.SysUtils,
  GetTimestamp;

procedure Post(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LNota: TNota;
  LData: string;
  LIDNota: Integer;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LNota := TNota.Create;

    LBody := TJSONObject.Create;
    LBody := TJSONObject.ParseJSONValue(Req.Body) As TJSONObject;
    LData := GetTimestampStr();

    if (LNota.CriarAnotacao(StrToInt(LBody.GetValue('idpsicologo').Value),
    StrToInt(LBody.GetValue('idpaciente').Value),
    LBody.GetValue('anotacao').Value, LData, LIDNota, LConnection.GetConnection)) then
      Res.Send(TJSONObject.Create.AddPair('idNota', LIDNota.ToString).ToJSON()).Status(200)
    else
      Res.Send('Erro ao cadastrar a anotação').Status(400);
  finally
    CoUninitialize;
    FreeAndNil(LConnection);
  end;
end;

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LNota: TNota;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;

    if not Req.Query.Dictionary.ContainsKey('idpsicologo') then
    begin
      Res.Send('Envie o id do psicologo').Status(400);
      Exit;
    end;

    Res.Send(LNota.VisualizarAnotacoes(Req.Query.Items['data'],
    Req.Query.Items['palavra'], Req.Query.Items['ordem'],
    StrToInt(Req.Query.Items['idpsicologo']), Req.Query.Items['idpaciente'],
    LConnection.GetConnection).ToJSONArrayString()).Status(200);
  finally
    CoUninitialize;
    FreeAndNil(LConnection);
  end;
end;


procedure Put(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LNota: TNota;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LNota := TNota.Create;

    LBody := TJSONObject.Create;
    LBody := TJSONObject.ParseJSONValue(Req.Body) As TJSONObject;

    if (LNota.AtualizarAnotacao(StrToInt(LBody.GetValue('idanotacao').Value),
    LBody.GetValue('anotacao').Value, LConnection.GetConnection)) then
      Res.Send('Anotação atualizada com sucesso!').Status(201)
    else
      Res.Send('Erro ao atualizar a anotação').Status(400);

  finally
    CoUninitialize;
    FreeAndNil(LConnection);
  end;
end;

procedure Delete(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LNota: TNota;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LNota := TNota.Create;

    LBody := TJSONObject.Create;
    LBody := TJSONObject.ParseJSONValue(Req.Body) As TJSONObject;

    if (LNota.ExcluirAnotacao(StrToInt(LBody.GetValue('idanotacao').Value),
    LConnection.GetConnection)) then
      Res.Send('Anotação excluída com sucesso!').Status(201)
    else
      Res.Send('Erro ao excluir a anotação').Status(400);

  finally
    CoUninitialize;
    FreeAndNil(LConnection);
  end;
end;

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/anotacoes', Get);
  THorse.AddCallback(Authorization()).Post('/api/anotacoes', Post);
  THorse.AddCallback(Authorization()).Put('/api/anotacoes', Put);
  THorse.AddCallback(Authorization()).Delete('/api/anotacoes', Delete);
end;

end.
