unit Provider.Connection;

interface

uses
  FireDAC.Comp.Client;

type
  TConexao = class
    private
      FConnection: TFDConnection;
      procedure ConfigurarParametros;
    public
      constructor Create;
      destructor Destroy; override;

      function ObterConexao: TFDConnection;
      procedure Conectar;
      procedure Desconectar;
  end;

implementation

uses
  System.SysUtils;

{ TConexao }

constructor TConexao.Create;
begin
  FConnection := TFDConnection.Create(nil);
   ConfigurarParametros;
end;

destructor TConexao.Destroy;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;
    FreeAndNil(FConnection);
  end;
  inherited;
end;

procedure TConexao.ConfigurarParametros;
begin
  FConnection.LoginPrompt := False;
  FConnection.DriverName := 'MySQL'; // Troque conforme o banco
  with FConnection.Params do
  begin
    Values['Database'] := 'nomedobanco';
    Values['User_Name'] := 'root';
    Values['Password'] := 'senha';
    Values['Server'] := 'localhost';
    Values['Port'] := '3306';
  end;
end;

procedure TConexao.Conectar;
begin
  if not FConnection.Connected then
    FConnection.Connected := True;
end;

procedure TConexao.Desconectar;
begin
  if FConnection.Connected then
    FConnection.Connected := False;
end;

function TConexao.ObterConexao: TFDConnection;
begin
  Result := FConnection;
end;

end.
