unit Controller.Paciente;

interface

procedure Registry;

implementation

uses
  Horse,
  Provider.Connection,
  FireDAC.Comp.Client,
  DataSet.Serialize;

procedure Get(Req: THorseRequest; Res: THorseResponse);
var
  LConexao: TConexao;
  LQuery: TFDQuery;
begin
  try
    LConexao := TConexao.Create;
    LQuery := TFDQuery.Create(nil);

    LConexao.Conectar;

    with LQuery do
    begin
      Close;
      SQL.Text := 'SELECT * FROM pacientes';
      Open;
    end;

    Res.Send(LQuery.ToJSONArray()).Status(200);
  finally
    LQuery.Free;
    LConexao.Desconectar;
    LConexao.Free;
  end;

end;

procedure Registry;
begin
  THorse.Get('/api/paciente', Get);
end;

end.
