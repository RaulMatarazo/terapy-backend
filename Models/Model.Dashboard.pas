unit Model.Dashboard;

interface

uses
  Data.Win.ADODB;

type TDashboard = class
  private
  public
  function DashboardEmocoes(AIdPsicologo: Integer; AIdPaciente: Integer;
  AConnection: TADOConnection): TADOQuery;
end;

implementation

{ TDashboard }

function TDashboard.DashboardEmocoes(AIdPsicologo, AIdPaciente: Integer;
  AConnection: TADOConnection): TADOQuery;
begin

end;

end.
