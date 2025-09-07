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
  SSQL: string;
begin
    CoInitialize(nil); // Inicializa COM para esta thread
  try
    LConnection := TConnectionProvider.Create;
    LQuery := TADOQuery.Create(nil);
    SSQL := Format
      ('SELECT u.id_usuario, id_paciente, primeiro_nome, sobrenome, data_nascimento, '
      + ' email, telefone FROM PACIENTES p ' +
      ' LEFT JOIN usuarios u ON u.id_usuario = p.id_usuario ' +
      ' WHERE id_psicologo = %d ', [StrToInt(Req.Query.Items['idpsicologo'])]);

    if Req.Query.ContainsKey('primeiroNome') then
    begin
      if (Trim(Req.Query.Items['primeiroNome'])) <> '' then
      begin
        SSQL := SSQL + ' AND u.primeiro_nome like ' +
          QuotedStr('%' + Req.Query.Items['primeiroNome'] + '%');
      end;

    end;

    if Req.Query.ContainsKey('sobrenome') then
    begin
      if (Trim(Req.Query.Items['sobrenome'])) <> '' then
      begin
        SSQL := SSQL + ' AND u.sobrenome like ' +
          QuotedStr('%' + Req.Query.Items['sobrenome'] + '%');
      end;

    end;

    if Req.Query.ContainsKey('idusuario') then
    begin
      if (Trim(Req.Query.Items['idusuario'])) <> '' then
      begin
        SSQL := SSQL + ' AND u.id_usuario = ' + Req.Query.Items['idusuario'];
      end;

    end;

    try
      with LQuery do
      begin
        Connection := LConnection.GetConnection;
        SQL.Text := SSQL;
        Open;
      end;

      try
        Res.Send(LQuery.ToJSONArrayString());
      except on ex:Exception do
        Res.Send(ex.message);
      end;

      // Enviar a resposta como JSON


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

    if (LPaciente.ValidarEmail(LBody.GetValue('email').Value, LConnection.GetConnection)) then
    begin
      Res.Send('[ERRO] Email já cadastrado').Status(207);
      Exit;
    end;

    if (LPaciente.ValidarTelefone(LBody.GetValue('telefone').Value, LConnection.GetConnection)) then
    begin
      Res.Send('[ERRO] Telefone já cadastrado').Status(207);
      Exit;
    end;

    if (LPaciente.CriarPaciente(LBody.GetValue('primeiroNome').Value,
      LBody.GetValue('sobrenome').Value, LBody.GetValue('dataNascimento').Value,
      LBody.GetValue('email').Value, LBody.GetValue('telefone').Value,
      LBody.GetValue('senha').Value, StrToInt(LBody.GetValue('idpsicologo')
      .Value), LConnection.GetConnection())) then
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
      if not Req.Query.ContainsKey('idUsuario') then
      begin
        Res.Send('Envie o id do paciente').Status(400);
        Exit;
      end;

      if LBody.GetValue('primeiroNome') <> nil then
      begin
        LPaciente.AtualizarPrimeiroNome(LBody.GetValue('primeiroNome').Value,
          StrToInt(Req.Query.Items['idUsuario']),
          LConnection.GetConnection);
      end;

      if LBody.GetValue('sobrenome') <> nil then
      begin
        LPaciente.AtualizarSobrenome(LBody.GetValue('sobrenome').Value,
          StrToInt(Req.Query.Items['idUsuario']),
          LConnection.GetConnection);
      end;

      if LBody.GetValue('dataNascimento') <> nil then
      begin
        LPaciente.AtualizarDataNascimento(LBody.GetValue('dataNascimento')
          .Value, StrToInt(Req.Query.Items['idUsuario']),
          LConnection.GetConnection);
      end;

      if LBody.GetValue('email') <> nil then
      begin
         if LPaciente.ValidarEmailID(LBody.GetValue('email').Value,
         StrToInt(Req.Query.Items['idUsuario']), LConnection.GetConnection) then
         begin
           Res.Send('[ERRO] Email já cadastrado').Status(207);
           Exit;
         end;

        LPaciente.AtualizarEmail(LBody.GetValue('email').Value,
          StrToInt(Req.Query.Items['idUsuario']),
          LConnection.GetConnection);
      end;

      if LBody.GetValue('telefone') <> nil then
      begin
        if LPaciente.ValidarTelefoneID(LBody.GetValue('telefone').Value,
        StrToInt(Req.Query.Items['idUsuario']), LConnection.GetConnection) then
        begin
          Res.Send('[ERRO] Telefone já cadastrado').Status(207);
          Exit;
        end;

        LPaciente.AtualizarTelefone(LBody.GetValue('telefone').Value,
          StrToInt(Req.Query.Items['idUsuario']),
          LConnection.GetConnection);
      end;

      if LBody.GetValue('senha') <> nil then
      begin
        LPaciente.AtualizarSenha(LBody.GetValue('senha').Value,
          StrToInt(Req.Query.Items['idUsuario']),
          LConnection.GetConnection);
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
    if (LPaciente.ExcluirPaciente(StrToInt(Req.Query.Items['idUsuario']),
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
