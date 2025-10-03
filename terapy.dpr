program terapy;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.CORS,
  Model.Psicologo in 'Models\Model.Psicologo.pas',
  Model.Paciente in 'Models\Model.Paciente.pas',
  Model.Usuario in 'Models\Model.Usuario.pas',
  Controller.Psicologo in 'Controllers\Controller.Psicologo.pas',
  Controller.Paciente in 'Controllers\Controller.Paciente.pas',
  Provider.Connection in 'Providers\Provider.Connection.pas',
  Provider.Authorization in 'Providers\Provider.Authorization.pas',
  Controller.Authorization in 'Controllers\Controller.Authorization.pas',
  Controller.Usuario in 'Controllers\Controller.Usuario.pas',
  Controller.Notas in 'Controllers\Controller.Notas.pas',
  Model.Notas in 'Models\Model.Notas.pas',
  GetTimestamp in 'Lib\GetTimestamp.pas',
  Controller.Emocao in 'Controllers\Controller.Emocao.pas',
  Model.Emocao in 'Models\Model.Emocao.pas',
  Controller.Dashboard in 'Controllers\Controller.Dashboard.pas',
  Model.Dashboard in 'Models\Model.Dashboard.pas',
  GetArrayToTJSONArray in 'Lib\GetArrayToTJSONArray.pas';

begin

  THorse
    .Use(CORS);

  // Local ou Servidor
  HorseCORS
  .AllowedOrigin('*')
  .AllowedCredentials(True)
  .AllowedMethods('*')
  .AllowedHeaders('*')
  .ExposedHeaders('*');

  Controller.Psicologo.Registry;
  Controller.Paciente.Registry;
  Controller.Authorization.Registry;
  Controller.Usuario.Registry;
  Controller.Notas.Registry;
  Controller.Emocao.Registry;
  Controller.Dashboard.Registry;

  THorse.Listen(9000);
end.
