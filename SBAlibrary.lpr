program SBAlibrary;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uecontrols, lazcontrols, libraryformu,
  UtilsU, SBAProgContrlrU, SBAProgramU, versionsupportu
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

