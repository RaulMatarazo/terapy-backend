unit Controller.Psicologo;

interface

procedure Registry;

implementation

uses
  Horse;

procedure Get(Req: THorseRequest; Res: THorseResponse);
begin
  Res.Send('Retornando psicologos');
end;

procedure Registry;
begin
  THorse.Get('/api/psicologo', Get);
end;

end.
