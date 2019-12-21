unit UtilsU;

{$mode objfpc}{$H+}

interface

uses
  Forms, Classes, SysUtils, Dialogs, FileUtil, LazFileUtils, StrUtils, DateUtils,
  lclintf, Zipper, DebugU;


function SearchForFiles(const dir,mask: string; Onfind:TFileFoundEvent):boolean;
function PopulateDirList(const directory : string; list : TStrings): boolean;
function PopulateFileList(const directory,mask : string; list : TStrings): boolean;
function GetAllFileNamesOnly(const dir,mask:string; list:TStrings):boolean;
procedure GetAllFileNamesOnlyEqPaths(const dir,mask:string; list:TStrings);
function UnZip(f,p:string):boolean;
function GetZipMainFolder(f:string):string;
function IsDirectoryEmpty(const directory : string) : boolean;
function GetPosList(s: string; list: Tstrings; start:integer=0): integer;
function DirReplace(s,d:string): boolean;
function DeleteDirectoryEx(DirectoryName: string): boolean;
function DirDelete(d:string):boolean;
function MoveDir(const fromDir, toDir: string): Boolean;
Function GetDeepestDir(const aFilename:string):string;
function VCmpr(v1,v2:string):integer;
procedure PauseXms(const Milliseconds: longword);

implementation

function GetAllFileNamesOnly(const dir,mask:string; list:TStrings):boolean;
var
  L:TStringList;
  s:String;
begin
  list.Clear;
  L:=FindAllFiles(dir,mask);
  For s in L do list.Add(ExtractFileNameOnly(S));
  L.Free;
  result:=list.Count>0;
end;

procedure GetAllFileNamesOnlyEqPaths(const dir,mask:string; list:TStrings);
var
  L:TStringList;
  s:String;
begin
  list.Clear;
  L:=FindAllFiles(dir,mask);
  For s in L do list.Add(ExtractFileNameOnly(s)+'='+s);
  L.Free;
end;

function SearchForFiles(const dir,mask: string; Onfind:TFileFoundEvent):boolean;
var
  FS:TFileSearcher;
begin
  result:=false;
  try
    FS:=TFileSearcher.Create;
    FS.OnFileFound:=OnFind;
    FS.Search(dir,mask,true,true);
    result:=true;
  finally
    FS.Free;
  end;
end;

function PopulateFileList(const directory,mask: string; list: TStrings): boolean;
var
  sr : TSearchRec;
begin
  result:=false;
  list.Clear;
  try
    if FindFirst(IncludeTrailingPathDelimiter(directory) + mask, faAnyFile, sr) < 0 then Exit
    else
    repeat
      if (sr.Attr and faDirectory = 0) then List.Add(sr.Name+'='+directory);
    until FindNext(sr) <> 0;
  finally
    FindClose(sr);
  end;
  result:=true;
end;

function UnZip(f,p:string):boolean;
var
  UnZipper: TUnZipper;
{$ifdef debug}
  i:integer;
{$endif}
begin
  result:=false;
  UnZipper := TUnZipper.Create;
  try
    UnZipper.FileName := Utf8ToAnsi(f);
    UnZipper.OutputPath := Utf8ToAnsi(p);
    try
      UnZipper.Examine;
{$ifdef debug}
      for i:=0 to UnZipper.Entries.Count-1 do info('UnZip',UnZipper.Entries.Entries[i].ArchiveFileName);
{$endif}
      UnZipper.UnZipAllFiles;
    except
      ON E:Exception do
      begin
        ShowMessage(E.Message);
        exit;
      end;
    end;
  finally
    UnZipper.Free;
  end;
  Result:=true;
end;

function GetZipMainFolder(f:string):string;
var
  UnZipper: TUnZipper;
begin
  result:='';
  UnZipper := TUnZipper.Create;
  try
    UnZipper.FileName := Utf8ToAnsi(f);
    try
      UnZipper.Examine;
      Result:=UnZipper.Entries.Entries[0].ArchiveFileName;
    except
      ON E:Exception do
      begin
        ShowMessage(E.Message);
        exit;
      end;
    end;
  finally
    UnZipper.Free;
  end;
end;

function PopulateDirList(const directory : string; list : TStrings): boolean;
var
  sr : TSearchRec;
begin
  result:=false;
  list.Clear;
  try
    if FindFirst(IncludeTrailingPathDelimiter(directory) + '*.*', faDirectory, sr) < 0 then Exit
    else
    repeat
      if ((sr.Attr and faDirectory <> 0) AND (sr.Name <> '.') AND (sr.Name <> '..')) then
        List.Add(sr.Name);
    until FindNext(sr) <> 0;
  finally
    FindClose(sr);
  end;
  result:=true;
end;

function IsDirectoryEmpty(const directory : string) : boolean;
var
  searchRec :TSearchRec;
begin
  try
    result := (FindFirst(directory+'\*.*', faAnyFile, searchRec) = 0) AND
              (FindNext(searchRec) = 0) AND
              (FindNext(searchRec) <> 0);
  finally
    FindClose(searchRec);
  end;
end;

function GetPosList(s: string; list: Tstrings; start: integer=0): integer;
var
  i: integer;
begin
  if start<0 then exit(-1);
  For i:=start to list.Count-1 do if pos(s,list[i])<>0 then exit(i);
  exit(-1);
end;

function DirReplace(s,d:string): boolean;
begin
  if DirDelete(d) then
  begin
    Sleep(10);
    Result:=RenameFile(s,d);
  end else exit(false);
end;

function DirDelete(d: string): boolean;
var i:integer;
begin
  info('DirDelete',d);
  if not DirectoryExists(d) then
  begin
    info('DirDelete','The folder '+d+' do not exists.');
    Result:=true;
    exit;
  end;
  Result:=DeleteDirectoryEx(d);
  for i:=0 to 10 do if DirectoryExists(d) then
  begin
    sleep(300);
    Application.ProcessMessages;
  end else break;
end;

function DeleteDirectoryEx(DirectoryName: string): boolean;
// Lazarus fileutil.DeleteDirectory on steroids, works like
// deltree <directory>, rmdir /s /q <directory> or rm -rf <directory>
// - removes read-only files/directories (DeleteDirectory doesn't)
// - removes directory itself
// Adapted from fileutil.DeleteDirectory, thanks to Paweł Dmitruk
var
  FileInfo: TSearchRec;
  CurSrcDir: String;
  CurFilename: String;
begin
  Result:=false;
  CurSrcDir:=CleanAndExpandDirectory(DirectoryName);
  if FindFirst(CurSrcDir+GetAllFilesMask,faAnyFile,FileInfo)=0 then
  begin
    repeat
      // Ignore directories and files without name:
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then
      begin
        // Remove all files and directories in this directory:
        CurFilename:=CurSrcDir+FileInfo.Name;
        // Remove read-only file attribute so we can delete it:
        if (FileInfo.Attr and faReadOnly)>0 then
          FileSetAttr(CurFilename, FileInfo.Attr-faReadOnly);
        if (FileInfo.Attr and faDirectory)>0 then
        begin
          // Directory; exit with failure on error
          if not DeleteDirectoryEx(CurFilename) then exit;
        end
        else
        begin
          // File; exit with failure on error
          if not DeleteFile(CurFilename) then exit;
        end;
      end;
    until FindNext(FileInfo)<>0;
  end;
  FindClose(FileInfo);
  // Remove "root" directory; exit with failure on error:
  if (not RemoveDir(CurSrcDir)) then exit;
  Result:=true;
end;

Function GetDeepestDir(const aFilename:string):string;
begin
  Result := extractFileName(ExtractFileDir(afilename));
end;

function VCmpr(v1, v2: string): integer;
var i:integer;
  function nl(s:string;l:integer):integer;
  begin
    result:=StrtoIntDef(ExtractDelimited(l,s,['.']),0)
  end;

begin
  i:=nl(v1,1)-nl(v2,1);
  if i<>0 then result:=i else
  begin
    i:=nl(v1,2)-nl(v2,2);
    if i<>0 then result:=i else
    begin
      i:=nl(v1,3)-nl(v2,3);
      result:=i
    end;
  end;
end;

function MoveDir(const fromDir, toDir: string): Boolean;
begin
  try
    if DirectoryExistsUTF8(toDir) then exit(false);
    result:=CopyDirTree(fromDir,toDir,[cffCreateDestDirectory,cffPreserveTime]);
    if result then DirDelete(fromDir) else
      ShowMessage('The PlugIn could not be moved.');
  except
    on E:Exception do ShowMessage(E.Message);
  end;
end;

procedure PauseXms(const Milliseconds: longword);
var
  TimeGoal: longword;
begin
  TimeGoal := MilliSecondOfTheDay(Now)+Milliseconds;
  while MilliSecondOfTheDay(Now) < (TimeGoal) do ;
end;

end.

