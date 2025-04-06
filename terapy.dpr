program terapy;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Model.Psicologo in 'Models\Model.Psicologo.pas',
  Model.Paciente in 'Models\Model.Paciente.pas',
  Model.Usuario in 'Models\Model.Usuario.pas',
  Controller.Psicologo in 'Controllers\Controller.Psicologo.pas',
  Controller.Paciente in 'Controllers\Controller.Paciente.pas',
  Provider.Connection in 'Providers\Provider.Connection.pas';

begin

  Controller.Psicologo.Registry;
  Controller.Paciente.Registry;

  THorse.Listen(9000);
end.
