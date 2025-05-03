unit Controller.Psicologo;

interface

procedure Registry;

implementation

uses
  Horse,
  Provider.Authorization;

procedure Get(Req: THorseRequest; Res: THorseResponse);
begin
  Res.Send('Retornando psicologos').Status(200);
end;

procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/api/psicologos', Get);
end;

end.
