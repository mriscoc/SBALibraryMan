unit ConfigFormU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LazFileUtils, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, EditBtn,
  ComCtrls, IniFiles;

const  //based in sub dirs in zip file from Github
  DefSBAbaseDir='SBA-master';
  DefLibraryDir='SBA-Library';
  DefSnippetsDir='SBA-Snippets';
  DefProgramsDir='SBA-Programs';
  DefProjectsDir='sbaprojects';

  cSBAbaseZipFile='sbamaster.zip';
  cSBAlibraryZipFile='sbalibrary.zip';
  cSBAprogramsZipFile='sbaprograms.zip';
  cSBAsnippetsZipFile='sbasnippets.zip';
  cSBARepoZipFile='/archive/master.zip';
  cSBAthemeZipFile='theme.zip';
  cSBADocZipFile='doc.zip';
  cLocSBAprjparams='lprjparams.ini'; // Save the local parameters for each project file
  cSBApluginsZipFile='plugins.zip';
  cDefNewFileName='NewFile';

var
  ConfigFile,AppDir,ConfigDir,LibraryDir,SnippetsDir,ProgramsDir,
  ProjectsDir,SBAbaseDir,ThemeDir,ThemeFile,TempFolder:string;
  LocSBAPrjParams:string;  //Local associated Prj parameters ini file
  DefAuthor:string;
  LibAsReadOnly:Boolean;
  AutoOpenPrjF:Boolean;
  AutoOpenEdFiles:Boolean;
  CtrlAdvMode:Boolean;
  EnableFilesMon:Boolean;
  BakTimeStamp:Boolean;
  IpCoreList,SnippetsList,ProgramsList:Tstringlist;
  SBAversion:integer;
  SelTheme:integer;

function GetConfigValues:boolean;
function SBAVersionToStr(v:integer):string;
function StrToSBAVersion(s:string):integer;
procedure UpdateLists;

implementation

uses UtilsU, DebugU;

function SBAVersionToStr(v: integer): string;
begin
  case v of
    0: Result:='1.1';
    1: Result:='1.2';
    else Result:='1.1';
  end;
end;

function StrToSBAVersion(s:string): integer;
begin
  case s of
    '1.1' : Exit(0);
    '1.2' : Exit(1);
    else Exit(0);
  end;
end;

procedure UpdateLists;
begin
  GetAllFileNamesOnly(LibraryDir,'*.ini',IpCoreList);
  GetAllFileNamesOnly(SnippetsDir,'*.snp',SnippetsList);
  GetAllFileNamesOnly(ProgramsDir,'*.prg',ProgramsList);
end;

function GetConfigValues: boolean;
var IniFile:TIniFile;
begin
  result:=false;
  AppDir:=Application.location;
  Info('GetConfigValues','Application folder: '+AppDir);
  {$IFDEF Darwin}
  AppDir := AppendPathDelim(copy(AppDir,1,Pos('/SBAcreator.app',AppDir)-1));
  {$ENDIF}
  if paramcount=0 then
  begin
    ConfigFile:=GetAppConfigDir(false);
    ConfigFile:=ExtractFilePath(ExtractFileDir(ConfigFile));
    ConfigFile:=ConfigFile+'SBACreator'+PathDelim+'SBACreator.cfg';
  end else ConfigFile:=paramstr(1);
  if not fileexists(ConfigFile) then exit;
  IniFile := TIniFile.Create(ConfigFile);
  with IniFile do try
    Info('GetConfigValues','Config File: '+ConfigFile);
    ConfigDir:=ReadString('TApplication.MainForm','ConfigDir',ExtractFilePath(ConfigFile));
    SBAbaseDir:=ReadString('TApplication.MainForm','SBAbaseDir',ConfigDir+DefSBAbaseDir+PathDelim);
    LibraryDir:=ReadString('TApplication.MainForm','LibraryDir',ConfigDir+DefLibraryDir+PathDelim);
    SnippetsDir:=ReadString('TApplication.MainForm','SnippetsDir',ConfigDir+DefSnippetsDir+PathDelim);
    ProgramsDir:=ReadString('TApplication.MainForm','ProgramsDir',ConfigDir+DefProgramsDir+PathDelim);
    ProjectsDir:=ReadString('TApplication.MainForm','ProjectsDir',GetUserDir+DefProjectsDir+PathDelim);
    ThemeDir:=ReadString('TApplication.MainForm','ThemeDir',ConfigDir+'theme'+PathDelim);
    LocSBAPrjParams:=ConfigDir+cLocSBAprjparams;
    DefAuthor:=ReadString('TApplication.MainForm','DefAuthor','Author');
    SBAversion:=ReadInteger('TApplication.MainForm','SBAversion',1);
    SelTheme:=ReadInteger('TApplication.MainForm','SelTheme',0);
    result:=true;
  finally
    IniFile.Free;
  end;
end;


initialization


finalization


end.

