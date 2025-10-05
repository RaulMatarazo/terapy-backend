unit Model.Dashboard;

interface

uses
  Data.Win.ADODB,
  Dataset.Serialize,
  System.JSON;

type
  TResultArray = array of integer;
  TDashboard = class
  private
  public
  function TotalAnotacoes(AIdPsicologo: Integer;
  AConnection: TADOConnection): Integer;
  function TotalPacientes(AIdPsicologo: Integer;
  AConnection: TADOConnection): Integer;
  function TotalAnotacoesGrafico(AIdPsicologo: Integer;
  AConnection: TADOConnection): TADOQuery;
  function GraficoEmocoes(AidPaciente: Integer; AInicio, AFim: string;
  AConnection: TADOConnection): TJSONArray;
  function GraficoEmocoesDetalhe(AidPaciente: Integer; AInicio, AFim: string;
  AConnection: TADOConnection): TADOQuery;
end;

implementation

uses
  System.SysUtils, Vcl.Dialogs;

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

function TDashboard.GraficoEmocoes(AidPaciente: Integer; AInicio, AFim: string;
  AConnection: TADOConnection): TJSONArray;
var
  LQuery: TADOQuery;
begin
  LQuery := TADOQuery.Create(nil);
  LQuery.Connection := AConnection;

  with LQuery do
  begin
    Close;
    SQL.Text := 'SELECT ' +
	  'E.NOME, ' +
	  'COUNT(PE.ID_EMOCAO) ' +
    'FROM PACIENTE_EMOCAO PE ' +
    'LEFT JOIN EMOCOES E ON E.ID_EMOCAO = PE.ID_EMOCAO ' +
    'WHERE ' +
	  'PE.ID_PACIENTE = ' + IntToStr(AidPaciente) +
    ' AND PE.hora::date BETWEEN ' + QuotedStr(AInicio) + ' AND ' + QuotedStr(AFim) +
    ' GROUP BY PE.ID_EMOCAO, E.NOME ';
    Open;
  end;

  Result := LQuery.ToJSONArray();
end;

function TDashboard.GraficoEmocoesDetalhe(AidPaciente: Integer; AInicio, AFim: string;
  AConnection: TADOConnection): TADOQuery;
var
  LQuery: TADOQuery;
begin
  LQuery := TADOQuery.Create(nil);
  LQuery.Connection := AConnection;

  with LQuery do
  begin
    Close;
    SQL.Text := 'SELECT id_emocao, qualidade, id_intensidade, descricao, atividade, hora::date as data, hora::time as hora from PACIENTE_EMOCAO ' +
    'WHERE id_paciente = ' + IntToStr(AidPaciente) +
    ' AND hora::date BETWEEN ' + QuotedStr(AInicio) + ' AND ' + QuotedStr(AFim);
    Open;
  end;

  Result := LQuery;
end;


end.
