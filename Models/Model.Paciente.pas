unit Model.Paciente;

interface

uses
  Model.Usuario;

type
  TPaciente = class(TUsuario)
    private
      FDataNascimento: TDate;
    public
  end;

implementation

end.
