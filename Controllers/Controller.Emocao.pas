unit Controller.Emocao;

interface

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
  Model.Emocao,
  System.SysUtils,
  GetTimestamp;

procedure Registry;

implementation

procedure Post(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LEmocao: TEmocao;
  LData: string;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LEmocao := TEmocao.Create;

    LBody := TJSONObject.Create;
    LBody := TJSONObject.ParseJSONValue(Req.Body) As TJSONObject;
    LData := GetTimestampStr();

    if (LEmocao.CriarEmocao(StrToInt(LBody.GetValue('idpaciente').Value),
    StrToInt(LBody.GetValue('idemocao').Value), LData, StrToInt(LBody.GetValue('qualidade').Value),
    StrToInt(LBody.GetValue('idintensidade').Value), LBody.GetValue('descricao').Value,
    LBody.GetValue('atividade').Value, LConnection.GetConnection)) then
      Res.Send('Emoção cadastrada com sucesso!').Status(201)
    else
      Res.Send('Erro ao cadastrar a emoção').Status(400);
  finally
    CoUninitialize;
  end;
end;

procedure Put(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LEmocao: TEmocao;
  LData: string;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LEmocao := TEmocao.Create;

    LBody := TJSONObject.Create;
    LBody := TJSONObject.ParseJSONValue(Req.Body) As TJSONObject;
    LData := GetTimestampStr();

    if (LEmocao.AtualizarEmocao(StrToInt(LBody.GetValue('idpacienteemocao').Value),
    StrToInt(LBody.GetValue('idemocao').Value), LData, LConnection.GetConnection)) then
      Res.Send('Emoção atualizada com sucesso!').Status(201)
    else
      Res.Send('Erro ao atualizar a emoção').Status(400);

  finally
    CoUninitialize;
  end;
end;

procedure Delete(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LEmocao: TEmocao;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LEmocao := TEmocao.Create;

    LBody := TJSONObject.Create;
    LBody := TJSONObject.ParseJSONValue(Req.Body) As TJSONObject;

    if (LEmocao.ExcluirEmocao(StrToInt(LBody.GetValue('idpacienteemocao').Value),
    LConnection.GetConnection)) then
      Res.Send('Emoção excluída com sucesso!').Status(201)
    else
      Res.Send('Erro ao excluir a emoção').Status(400);

  finally
    CoUninitialize;
  end;
end;

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LEmocao: TEmocao;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;

    if not Req.Query.Dictionary.ContainsKey('idpaciente') then
    begin
      Res.Send('Envie o id do paciente').Status(400);
      Exit;
    end;

    Res.Send(LEmocao.VisualizarEmocoes(StrToInt(Req.Query.Items['idpaciente']),
    LConnection.GetConnection).ToJSONArrayString()).Status(200);
  finally
    CoUninitialize;
  end;
end;



procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/emocoes', Get);
  THorse.AddCallback(Authorization()).Post('/api/emocoes', Post);
  THorse.AddCallback(Authorization()).Put('/api/emocoes', Put);
  THorse.AddCallback(Authorization()).Delete('/api/emocoes', Delete);
end;

end.
