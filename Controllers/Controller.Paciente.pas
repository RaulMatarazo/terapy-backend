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
  Provider.Authorization;

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
        SQL.Text := 'SELECT u.id_usuario primeiro_nome, sobrenome, data_nascimento, ' +
        ' email, telefone FROM PACIENTES p ' +
        ' LEFT JOIN usuarios u ON u.id_usuario = p.id_usuario ';
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

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/pacientes', Get);
end;

end.
