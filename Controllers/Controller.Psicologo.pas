unit Controller.Psicologo;

interface

procedure Registry;

implementation

uses
  Horse,
  Provider.Authorization,
  Provider.Connection,
  Data.Win.ADODB,
  Dataset.Serialize,
  ActiveX, JOSE.Types.JSON,
  Model.Psicologo;

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LQuery: TADOQuery;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LQuery := TADOQuery.Create(nil);
    try
      with LQuery do
      begin
        Connection := LConnection.GetConnection;
        SQL.Text := 'SELECT u.id_usuario, primeiro_nome, sobrenome, data_nascimento, ' +
        ' email, telefone FROM psicologos p ' +
        'LEFT JOIN usuarios u on u.id_usuario = p.id_usuario';
        Open;
      end;

      Res.Send(LQuery.ToJSONArrayString()).Status(200);
    finally
      LQuery.Free;
      LConnection.Free;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure Post(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LPsicologo: TPsicologo;
begin
  CoInitialize(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;
    LConnection := TConnectionProvider.Create;
    LPsicologo := TPsicologo.Create;
    if (LPsicologo.CriarPsicologo(LBody.GetValue('primeiroNome').Value,
    LBody.GetValue('sobrenome').Value, LBody.GetValue('dataNascimento').Value,
    LBody.GetValue('email').Value, LBody.GetValue('telefone').Value,
    LBody.GetValue('senha').Value, LBody.GetValue('crp').Value,
    LConnection.GetConnection())) then
      Res.Status(201)
    else
      Res.Send('Erro ao cadastrar o psicólogo').Status(203);
  finally
    CoUninitialize;
  end;
end;

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/psicologos', Get);
  THorse.Post('/api/psicologos', Post);
end;

end.
