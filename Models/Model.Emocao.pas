unit Model.Emocao;

interface

uses
  Data.Win.ADODB;

type TEmocao = class
  private
  public
  function CriarEmocao(AIdPaciente, AIdEmocao: Integer; AData: string;
AQualidade: Integer; AIdIntensidade: Integer; ADescricao, AAtividade: string;
  AConnection: TADOConnection): Boolean;
  function AtualizarEmocao(AIdPacienteEmocao: Integer;
  AIdEmocao: Integer; AData: string; AConnection: TADOConnection): Boolean;
  function ExcluirEmocao(AIdPacienteEmocao: Integer;
  AConnection: TADOConnection): Boolean;
  function VisualizarEmocoes(AIdPaciente: Integer;
  AConnection: TADOConnection): TADOQuery;
end;

implementation

uses
  System.SysUtils;

{ TEmocao }

function TEmocao.CriarEmocao(AIdPaciente, AIdEmocao: Integer; AData: string;
AQualidade: Integer; AIdIntensidade: Integer; ADescricao, AAtividade: string;
  AConnection: TADOConnection): Boolean;
var
  LSQL: string;
begin
  try
    LSQL := Format('INSERT INTO paciente_emocao (id_paciente, id_emocao, qualidade, id_intensidade, descricao, atividade,  hora) ' +
     ' VALUES (%d, %d, %d, %d, %s, %s, %s)', [AIdPaciente, AIdEmocao, AQualidade, AIdIntensidade, QuotedStr(ADescricao), QuotedStr(AAtividade), Quotedstr(AData)]);
    AConnection.Execute(LSQL);
    Result := True;
  except
    Result := False;
  end;
end;

function TEmocao.AtualizarEmocao(AIdPacienteEmocao: Integer;
  AIdEmocao: Integer; AData: string; AConnection: TADOConnection): Boolean;
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE paciente_emocao SET id_emocao = %d WHERE id_paciente_emocao = %d ',
    [AIdEmocao, AIdPacienteEmocao]);
    AConnection.Execute(LSQL);
    Result := True;
  except
    Result := False;
  end;
end;

function TEmocao.ExcluirEmocao(AIdPacienteEmocao: Integer;
AConnection: TADOConnection): Boolean;
var
  LSQL: string;
begin
  try
    LSQL := Format('DELETE FROM paciente_emocao WHERE id_paciente_emocao = %d ',
    [AIdPacienteEmocao]);
    AConnection.Execute(LSQL);
    Result := True;
  except
    Result := False;
  end;
end;

function TEmocao.VisualizarEmocoes(AIdPaciente: Integer;
AConnection: TADOConnection): TADOQuery;
var
  LQuery: TADOQuery;
  LSQL: string;
begin

  LQuery := TADOQuery.Create(nil);
  LQuery.Connection := AConnection;

  LSQL := Format('SELECT e.nome, p.id_paciente, p.hora FROM paciente_emocao p LEFT JOIN emocoes e ' +
  ' ON e.id_emocao = p.id_emocao where id_paciente = %d ORDER BY p.hora DESC ', [AIdPaciente]);

  with LQuery do
  begin
    Close;
    SQL.Text := LSQL;
    Open;
  end;

  Result := LQuery;

end;

end.
