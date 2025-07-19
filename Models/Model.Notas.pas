unit Model.Notas;

interface

uses
  Data.Win.ADODB;

type TNota = class
  private
  public
  function CriarAnotacao(AIdPsicologo, AIdPaciente: Integer; AAnotacao,
  ADataCriacao: string; AConnection: TADOConnection): Boolean;
  function VisualizarAnotacoes(AData, APalavra, AOrdem: string;
  AConnection: TADOConnection): TADOQuery;
  function AtualizarAnotacao(AIdAnotacao: Integer;
  AAnotacao: string; AConnection: TADOConnection): Boolean;
  function ExcluirAnotacao(AIdAnotacao: Integer;
  AConnection: TADOConnection): Boolean;
end;

implementation

uses
  System.SysUtils;

{ TNotas }

function TNota.AtualizarAnotacao(AIdAnotacao: Integer;
  AAnotacao: string; AConnection: TADOConnection): Boolean;
var
  LSQL: string;
begin
  try
    LSQL := Format('UPDATE psicologo_notas SET anotacao = %s WHERE id_nota = %d ',
    [Quotedstr(AAnotacao), AIdAnotacao]);
    AConnection.Execute(LSQL);
    Result := True;
  except
    Result := False;
  end;
end;

function TNota.ExcluirAnotacao(AIdAnotacao: Integer;
AConnection: TADOConnection): Boolean;
var
  LSQL: string;
begin
  try
    LSQL := Format('DELETE FROM psicologo_notas WHERE id_nota = %d ',
    [AIdAnotacao]);
    AConnection.Execute(LSQL);
    Result := True;
  except
    Result := False;
  end;
end;

function TNota.CriarAnotacao(AIdPsicologo, AIdPaciente: Integer; AAnotacao,
  ADataCriacao: string; AConnection: TADOConnection): Boolean;
var
  LSQL: string;
begin
  try
    LSQL := Format('INSERT INTO psicologo_notas (id_psicologo, id_paciente, anotacao ' +
    ' ,data_criacao) VALUES (%d, %d, %s, %s)', [AIdPsicologo, AIdPaciente, Quotedstr(AAnotacao),
    QuotedStr(ADataCriacao)]);
    AConnection.Execute(LSQL);
    Result := True;
  except
    Result := False;
  end;
end;

function TNota.VisualizarAnotacoes(AData, APalavra,
  AOrdem: string; AConnection: TADOConnection): TADOQuery;
var
  LQuery: TADOQuery;
  LSQL: string;
begin

  LQuery := TADOQuery.Create(nil);
  LQuery.Connection := AConnection;

  LSQL := 'SELECT * FROM psicologo_notas where 1 = 1 ';

  if (AData <> '') then
  begin
    LSQL := LSQL + Format(' AND data_criacao::date = %s ', [QuotedStr(AData)]);
  end;

  if (APalavra <> '') then
  begin
    LSQL := LSQL + Format(' AND anotacao like %s ', [QuotedStr('%' + APalavra + '%')]);
  end;

  if (AOrdem <> '') then
  begin
    LSQL := LSQL + Format(' ORDER BY data_criacao %s ', [AOrdem]);
  end
  else
    LSQL := LSQL + ' ORDER BY data_criacao DESC ';

  with LQuery do
  begin
    Close;
    SQL.Text := LSQL;
    Open;
  end;

  Result := LQuery;

end;

end.
