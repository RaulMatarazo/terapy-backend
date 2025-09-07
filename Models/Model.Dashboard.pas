unit Model.Dashboard;

interface

uses
  Data.Win.ADODB;

type TDashboard = class
  private
  public
  function TotalAnotacoes(AIdPsicologo: Integer;
  AConnection: TADOConnection): Integer;
  function TotalPacientes(AIdPsicologo: Integer;
  AConnection: TADOConnection): Integer;
  function TotalAnotacoesGrafico(AIdPsicologo: Integer;
  AConnection: TADOConnection): TADOQuery;
end;

implementation

uses
  System.SysUtils;

{ TDashboard }

function TDashboard.TotalAnotacoes(AIdPsicologo: Integer;
  AConnection: TADOConnection): Integer;
var
  LQuery: TADOQuery;
  DataAtual: TDateTime;
  LDataStr: string;
begin
  LQuery := TADOQuery.Create(nil);
  LQuery.Connection := AConnection;

  DataAtual := Date;

  LDataStr := FormatDateTime('yyyymm', DataAtual);

  with LQuery do
  begin
    Close;
    SQL.Text := Format('SELECT count(*) as total FROM psicologo_notas ' +
    ' where id_psicologo = %d AND ' +
    ' TO_CHAR(data_criacao, ''YYYYMM'') = %s', [AIdPsicologo, QuotedStr(LDataStr)]);
    Open;
  end;

  Result := LQuery.FieldByName('total').AsInteger;

end;

function TDashboard.TotalPacientes(AIdPsicologo: Integer;
  AConnection: TADOConnection): Integer;
var
  LQuery: TADOQuery;
begin
  LQuery := TADOQuery.Create(nil);
  LQuery.Connection := AConnection;

  with LQuery do
  begin
    Close;
    SQL.Text := Format('SELECT count(*) as total FROM pacientes ' +
    ' where id_psicologo = %d', [AIdPsicologo]);
    Open;
  end;

  Result := LQuery.FieldByName('total').AsInteger;

end;

function TDashboard.TotalAnotacoesGrafico(AIdPsicologo: Integer;
  AConnection: TADOConnection): TADOQuery;
var
  LQuery: TADOQuery;
begin
  LQuery := TADOQuery.Create(nil);
  LQuery.Connection := AConnection;

  with LQuery do
  begin
    Close;
    SQL.Text := Format('WITH ultimos7 AS (' +
    'SELECT (CURRENT_DATE - i) AS data' +
    'FROM generate_series(0,6) AS i' +
    '),' +
    'contagem AS (' +
    '  SELECT data_criacao::date AS data, COUNT(*) AS total' +
    '  FROM psicologo_notas' +
    '  WHERE data_criacao::date >= CURRENT_DATE - interval ''6 days''' +
    '    AND data_criacao::date <= CURRENT_DATE and id_psicologo = %d' +
    '  GROUP BY data' +
    ')' +
    'SELECT' +
    '  u.data,' +
    '  TO_CHAR(u.data, ''Dy'') AS nome, ' +
    '  COALESCE(c.total, 0) AS total' +
    'FROM ultimos7 u' +
    'LEFT JOIN contagem c' +
    '  ON c.data = u.data'  +
    'ORDER BY u.data DESC ', [AIdPsicologo]);
    Open;
  end;
end;

end.
