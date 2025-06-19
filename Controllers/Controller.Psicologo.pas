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
  ActiveX;

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
  LQuery: TADOQuery;
  LBody: TJSONObject;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LQuery := TADOQuery.Create(nil);
    LBody := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;
    try

    finally
      LQuery.Free;
      LConnection.Free;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/psicologos', Get);
  THorse.AddCallback(Authorization()).Post('/api/psicologos', Post);
end;

end.
