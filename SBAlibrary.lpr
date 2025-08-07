program SBAlibrary;

{$DEFINE SBALIBRARY} // Definido también en opciones del proyecto

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, anchordockpkg, libraryformu,
  utilsu, configu, versionsupportu, uecontrols
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='SBAlibraryManager';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TLibraryForm, LibraryForm);
  Application.Run;
end.

