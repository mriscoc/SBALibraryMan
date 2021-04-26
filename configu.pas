unit ConfigU;
{
 Program configuration values
 Author: Miguel A. Risco-Castillo
 Version 1.1.1
}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LazFileUtils, Forms, Dialogs, IniFiles
{$IFDEF UNIX}
  ,Process
{$ENDIF}
  ;

const
  DefSBAbaseDir='SBA-master';  //based in sub dir in zip file from Github
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
function SaveConfigValues:boolean;
function SetUpConfig: boolean;
function SBAVersionToStr(v:integer):string;
function StrToSBAVersion(s:string):integer;
procedure UpdateLists;

implementation

uses UtilsU, DebugU, EditorU, SBAProgramU;

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
var
  IniFile:TIniFile;
  s:String;
begin
  result:=false;
  AppDir:=Application.location;
  Info('GetConfigValues','Application folder: '+AppDir);
  {$IFDEF Darwin}
  AppDir := AppendPathDelim(copy(AppDir,1,Pos('/SBAcreator.app',AppDir)-1));
  {$ENDIF}
  {Verificar la opción -c [file] ó --config=[file] para definir un archivo de configuración diferente. }
  s:=Application.GetOptionValue('c','config');
  if (s<>'') and fileexists(s) then
  begin
    ConfigFile:=s;
  end else
  begin
    ConfigFile:=GetAppConfigDir(false); // ConfigFile:=GetAppConfigFile(false);
    ConfigFile:=ExtractFilePath(ExtractFileDir(ConfigFile));
    ConfigFile:=ConfigFile+'SBACreator'+PathDelim+'SBACreator.cfg';
  end;
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

    EditorFontName:=ReadString('TApplication.MainForm','EditorFontName','Courier New');
    EditorFontSize:=ReadInteger('TApplication.MainForm','EditorFontSize',10);
    if Screen.Fonts.IndexOf(EditorFontName)=-1 then EditorFontName:='Courier New';
    LibAsReadOnly:=ReadBool('TApplication.MainForm','LibAsReadOnly',true);
    AutoOpenPrjF:=ReadBool('TApplication.MainForm','AutoOpenPrjF',true);
    AutoOpenEdFiles:=ReadBool('TApplication.MainForm','AutoOpenEdFiles',true);
    CtrlAdvMode:=ReadBool('TApplication.MainForm','CtrlAdvMode',false);
    EnableFilesMon:=ReadBool('TApplication.MainForm','EnableFilesMon',true);
    BakTimeStamp:=ReadBool('TApplication.MainForm','BakTimeStamp',false);

    SBAversion:=ReadInteger('TApplication.MainForm','SBAversion',1);
    SelTheme:=ReadInteger('TApplication.MainForm','SelTheme',0);

    result:=true;
  finally
    IniFile.Free;
  end;
end;

function SaveConfigValues:boolean;
var IniFile:TIniFile;
const Section:string='TApplication.MainForm';
begin
  result:=false;
  IniFile := TIniFile.Create(ConfigFile);
  with IniFile do try
    WriteString(Section,'ConfigDir',ConfigDir);
    WriteString(Section,'LibraryDir',LibraryDir);
    WriteString(Section,'SnippetsDir',SnippetsDir);
    WriteString(Section,'ProgramsDir',ProgramsDir);
    WriteString(Section,'ProjectsDir',ProjectsDir);
    WriteString(Section,'DefAuthor',DefAuthor);
    WriteBool(Section,'LibAsReadOnly',LibAsReadOnly);
    WriteBool(Section,'AutoOpenPrjF',AutoOpenPrjF);
    WriteBool(Section,'AutoOpenEdfiles',AutoOpenEdfiles);
    WriteBool(Section,'CtrlAdvMode',CtrlAdvMode);
    WriteBool(Section,'EnableFilesMon',EnableFilesMon);
    WriteBool(Section,'BakTimeStamp',BakTimeStamp);
    WriteString(Section,'EditorFontName',EditorFontName);
    WriteInteger(Section,'EditorFontSize',EditorFontSize);
    WriteString(Section,'SBAbaseDir',SBAbaseDir);
    WriteInteger(Section,'SBAversion',SBAversion);
    WriteInteger(Section,'SelTheme',SelTheme);
    result:=true;
  finally
    IniFile.Free;
  end;
end;

function SetUpConfig: boolean;
{$IFDEF UNIX}
var s:string; //dummy string for RunCommandIndir
{$ENDIF}

begin
  result:=false;
  Info('SetUpConfig','ConfigDir= '+ConfigDir);
  If Not DirectoryExistsUTF8(ConfigDir) then
    If Not ForceDirectoriesUTF8(ConfigDir) Then
    begin
      ShowMessage('Failed to create config folder!: '+ConfigDir);
      Exit;
    end;

  Info('SetUpConfig','ProjectsDir= '+ProjectsDir);
  If Not DirectoryExistsUTF8(ProjectsDir) then
    If Not ForceDirectoriesUTF8(ProjectsDir) Then
    begin
      ShowMessage('Failed to create SBA projects folder: '+ProjectsDir+#13#10' the system is going to try with the default path: '+GetUserDir+DefProjectsDir+PathDelim);
      ProjectsDir:=GetUserDir+DefProjectsDir+PathDelim;
      If Not ForceDirectoriesUTF8(ProjectsDir) Then Exit;
    end;

  Info('SetUpConfig','LibraryDir= '+LibraryDir);
  If Not DirectoryExistsUTF8(LibraryDir) then
    If not Unzip(AppDir+cSBAlibraryZipFile,ConfigDir) then
    begin
      ShowMessage('Failed to create SBA library folder: '+LibraryDir);
      Exit;
    end;

  Info('SetUpConfig','SnippetsDir= '+SnippetsDir);
  If Not DirectoryExistsUTF8(SnippetsDir) then
    If not Unzip(AppDir+cSBAsnippetsZipFile,ConfigDir) then
    begin
      ShowMessage('Failed to create code snippets folder: '+SnippetsDir);
//      Exit; // Non Critical
    end;

  Info('SetUpConfig','ProgramsDir= '+ProgramsDir);
  If Not DirectoryExistsUTF8(ProgramsDir) then
    If not Unzip(AppDir+cSBAprogramsZipFile,ConfigDir) then
    begin
      ShowMessage('Failed to create code programs folder: '+ProgramsDir);
//      Exit; // Non Critical
    end;

  Info('SetUpConfig','SBAbaseDir= '+SBAbaseDir);
  If FileExists(AppDir+cSBABaseZipFile) then
    If Unzip(AppDir+cSBABaseZipFile,ConfigDir) then DeleteFile(AppDir+cSBABaseZipFile)
    else begin
      ShowMessage('Failed to create SBA base folder: '+SBAbaseDir);
      Exit;
    end;

  Info('SetUpConfig','ThemeDir= '+ConfigDir+'theme');
  If FileExists(AppDir+cSBAthemeZipFile) then
    If Unzip(AppDir+cSBAthemeZipFile,ConfigDir+'theme') then DeleteFile(AppDir+cSBAthemeZipFile)
    else begin
      ShowMessage('Failed to create theme folder: '+ConfigDir+'theme');
//      Exit; // Non Critical
    end;

  Info('SetUpConfig','PlugInsDir= '+ConfigDir+'plugins');
  If FileExists(AppDir+cSBApluginsZipFile) then
    If Unzip(AppDir+cSBApluginsZipFile,ConfigDir+'plugins') then DeleteFile(AppDir+cSBApluginsZipFile)
    else begin
      ShowMessage('Failed to create plugins folder: '+ConfigDir+'plugins');
//      Exit;  // Non Critical
    end;

  Info('SetUpConfig','DocDir= '+ConfigDir+'doc');
  If FileExists(AppDir+cSBADocZipFile) then
    If Unzip(AppDir+cSBADocZipFile,ConfigDir+'doc') then DeleteFile(AppDir+cSBADocZipFile)
    else begin
      ShowMessage('Failed to create doc help folder: '+ConfigDir+'doc');
//      Exit;  // Non Critical
    end;

  if FileExists(AppDir+cSBADefPrgTemplate) then if CopyFile(AppDir+cSBADefPrgTemplate,ConfigDir+cSBADefPrgTemplate) then DeleteFile(AppDir+cSBADefPrgTemplate);
  if FileExists(AppDir+cSBAAdvPrgTemplate) then if CopyFile(AppDir+cSBAAdvPrgTemplate,ConfigDir+cSBAAdvPrgTemplate) then DeleteFile(AppDir+cSBAAdvPrgTemplate);
  if FileExists(AppDir+'newbanner.gif') then if CopyFile(AppDir+'banner.gif',ConfigDir+'newbanner.gif') then DeleteFile(AppDir+'newbanner.gif');
  if FileExists(AppDir+'templates.ini') then if CopyFile(AppDir+'templates.ini',ConfigDir+'templates.ini') then DeleteFile(AppDir+'templates.ini');

  {$IFDEF UNIX}
  RunCommandInDir(AppDir,'/bin/bash',['-c','chmod -R +x .'],s);
  RunCommandInDir(ConfigDir+'plugins','/bin/bash',['-c','chmod -R +x .'],s);
  {$ENDIF}

  result:=true;
end;


initialization
TempFolder:=GetTempDir(false)+'sbacreator'+PathDelim;
ForceDirectories(TempFolder);

finalization
DirDelete(TempFolder);

end.

