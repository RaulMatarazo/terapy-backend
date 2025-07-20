unit Controller.Paciente;

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
  Provider.Authorization, System.JSON, Model.Paciente, System.SysUtils;

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LQuery: TADOQuery;
begin
  CoInitialize(nil); // Inicializa COM para esta thread
  try
    LConnection := TConnectionProvider.Create;
    LQuery := TADOQuery.Create(nil);
    try
      with LQuery do
      begin
        Connection := LConnection.GetConnection;
        SQL.Text := Format('SELECT u.id_usuario, id_paciente, primeiro_nome, sobrenome, data_nascimento, ' +
        ' email, telefone FROM PACIENTES p ' +
        ' LEFT JOIN usuarios u ON u.id_usuario = p.id_usuario ' +
        ' WHERE id_psicologo = %d ', [StrToInt(Req.Query.Items['idpsicologo'])]);
        Open;
      end;

      // Enviar a resposta como JSON
      Res.Send(LQuery.ToJSONArrayString());

    finally
      LQuery.Free;
      LConnection.Free;
    end;
  finally
    CoUninitialize; // Libera COM da thread
  end;
end;

procedure Post(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LPaciente: TPaciente;
begin
  CoInitialize(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;
    LConnection := TConnectionProvider.Create;
    LPaciente := TPaciente.Create;
    if (LPaciente.CriarPaciente(LBody.GetValue('primeiroNome').Value,
    LBody.GetValue('sobrenome').Value, LBody.GetValue('dataNascimento').Value,
    LBody.GetValue('email').Value, LBody.GetValue('telefone').Value,
    LBody.GetValue('senha').Value, StrToInt(LBody.GetValue('idpsicologo').Value),
    LConnection.GetConnection())) then
      Res.Status(201)
    else
      Res.Send('Erro ao cadastrar o paciente').Status(203);
  finally
    CoUninitialize;
  end;
end;

procedure Put(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LBody: TJSONObject;
  LPaciente: TPaciente;
begin
  CoInitialize(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;
    LConnection := TConnectionProvider.Create;
    LPaciente := TPaciente.Create;

    LConnection.GetConnection.BeginTrans;

    try
      if LBody.GetValue('idusuario') = nil then
      begin
        Res.Send('Envie o id do paciente').Status(400);
        Exit;
      end;

      if LBody.GetValue('primeiroNome') <> nil then
      begin
        LPaciente.AtualizarPrimeiroNome(LBody.GetValue('primeiroNome').Value,
        StrToInt(LBody.GetValue('idusuario').Value), LConnection.GetConnection);
      end;

      if LBody.GetValue('sobrenome') <> nil then
      begin
        LPaciente.AtualizarSobrenome(LBody.GetValue('sobrenome').Value,
        StrToInt(LBody.GetValue('idusuario').Value), LConnection.GetConnection);
      end;

      if LBody.GetValue('dataNascimento') <> nil then
      begin
        LPaciente.AtualizarDataNascimento(LBody.GetValue('dataNascimento').Value,
        StrToInt(LBody.GetValue('idusuario').Value), LConnection.GetConnection);
      end;

      if LBody.GetValue('email') <> nil then
      begin
        LPaciente.AtualizarEmail(LBody.GetValue('email').Value,
        StrToInt(LBody.GetValue('idusuario').Value), LConnection.GetConnection);
      end;

      if LBody.GetValue('telefone') <> nil then
      begin
        LPaciente.AtualizarTelefone(LBody.GetValue('telefone').Value,
        StrToInt(LBody.GetValue('idusuario').Value), LConnection.GetConnection);
      end;

      if LBody.GetValue('senha') <> nil then
      begin
        LPaciente.AtualizarSenha(LBody.GetValue('senha').Value,
        StrToInt(LBody.GetValue('idusuario').Value), LConnection.GetConnection);
      end;
    except
      LConnection.GetConnection.RollbackTrans;
      Res.Send('Erro ao atualizar o paciente').Status(400);
      Exit;
    end;

    LConnection.GetConnection.CommitTrans;
    Res.Send('Paciente atualizado com sucesso!').Status(200);

  finally
    CoUninitialize;
  end;
end;

procedure Delete(Req: THorseRequest; Res: THorseResponse);
var
  LConnection: TConnectionProvider;
  LPaciente: TPaciente;
  LBody: TJSONObject;
begin
  CoInitialize(nil);
  try
    LConnection := TConnectionProvider.Create;
    LBody := TJSONObject.ParseJSONValue(Req.Body) As TJSONObject;
    LPaciente := TPaciente.Create;
    if (LPaciente.ExcluirPaciente(StrToInt(LBody.GetValue('idusuario').Value),
    LConnection.GetConnection())) then
      Res.Send('Paciente excluído com sucesso!').Status(200)
    else
      Res.Send('Erro ao excluir o paciente').Status(400);
  finally
    CoUninitialize;
  end;
end;

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/pacientes', Get);
  THorse.AddCallback(Authorization()).Post('/api/pacientes', Post);
  THorse.AddCallback(Authorization()).Put('/api/pacientes', Put);
  THorse.AddCallback(Authorization()).Delete('/api/pacientes', Delete);
end;

end.
