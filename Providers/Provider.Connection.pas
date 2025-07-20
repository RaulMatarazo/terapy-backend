unit Provider.Connection;

interface

uses
  System.SysUtils, Data.Win.ADODB;

type
  TConnectionProvider = class
  private
    FConnection: TADOConnection;
  public
    constructor Create;
    destructor Destroy; override;

    function GetConnection: TADOConnection;
  end;

implementation

{ TConnectionProvider }

constructor TConnectionProvider.Create;
begin
  // o driver utilizado foi o odbc: gratuito e fácil configuração
  // o odbc é compatível com o FireDac e o ADO (como é community edition só tem o ADO)
  FConnection := TADOConnection.Create(nil);
  FConnection.LoginPrompt := False;
  FConnection.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;User ID=postgres;Data Source=PostgreSQL35W';
  FConnection.Connected := True;
end;

destructor TConnectionProvider.Destroy;
begin
  if FConnection.Connected then
    FConnection.Connected := False;
  FConnection.Free;
  inherited;
end;

function TConnectionProvider.GetConnection: TADOConnection;
begin
  Result := FConnection;
end;

end.

