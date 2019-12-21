unit DwFileU;
{
 Author: Miguel A. Risco-Castillo
 Version 3.2
 Use of InternetTools
}
{$mode objfpc}{$H+}
{$DEFINE USE_SOROKINS_REGEX}

interface

uses
  Classes, Forms, Dialogs, SysUtils,
  bbutils, simpleinternet, internetaccess,
  LazFileUtils;

function DownloadFile(UrlSource,FileDestiny:string):boolean;
function CheckNetworkConnection:boolean;
procedure CheckNetworkThread;
function UrlSolveRedir(var UrlValue:string):boolean;

Type

 tDwStatus=(dwStart,dwIdle,dwDownloading,dwTimeOut,dwError);

 { TDownloadThread }

 TOnDownloaded = procedure of Object;
 TDownloadThread = class(TThread)
 private
   FFileDestiny: String;
   FStatus: tDwStatus;
   fStatusText : string;
   FUrlSource: String;
   FOnDownloaded: TOnDownloaded;
   procedure SetFileDestiny(AValue: String);
   procedure SetStatus(AValue: tDwStatus);
   procedure SetUrlSource(AValue: String);
   procedure ShowStatus;
   procedure Downloaded;
 protected
   procedure Execute; override;
 public
   Constructor Create(UrlSource,FileDestiny:string);
 published
   property Status:tDwStatus read FStatus write SetStatus;
   property UrlSource:String read FUrlSource write SetUrlSource;
   property FileDestiny:String read FFileDestiny write SetFileDestiny;
   property OnDownloaded:TOnDownloaded read FOnDownloaded write FOnDownloaded;
 end;

 { TCheckNetworkConnectionThread }

 TCheckNetworkConnectionThread = class(TThread)
 protected
   procedure Execute; override;
 public
   Constructor Create;
 end;

var
  isNetworkEnabled:boolean=false;

implementation

uses DebugU;

function DownloadFile(UrlSource,FileDestiny:string):boolean;
begin
  result:=false;
  if isNetworkEnabled then try
    strSaveToFileUTF8(FileDestiny, retrieve(UrlSource));
  finally
    freeThreadVars;
  end;
  result:=true;
end;

function CheckNetworkConnection:boolean;
var Ip:String;
begin
  Ip:='';
  try
    Ip:=process('http://checkip.dyndns.org', 'extract(//body, "[0-9.]+")').toString;
    Info('CheckNetworkConnection IP',Ip);
  except
    On E :Exception do Info('CheckNetworkConnection error',E.Message);
  end;
  isNetworkEnabled:=Ip<>'';
  exit(isNetworkEnabled);
end;

procedure CheckNetworkThread;
begin
  TCheckNetworkConnectionThread.Create;
end;

function UrlSolveRedir(var UrlValue: string): boolean;
begin
  result:=false;
  try
    httpRequest(TrimLeft(UrlValue));
    Info('TDownloadThread.UrlSolveRedir original:',UrlValue);
    UrlValue := defaultInternet.lastUrl;
    Info('TDownloadThread.UrlSolveRedir redirect:',UrlValue);
    result:=true;
  finally
  end;
end;

{ TCheckNetworkConnectionThread }

constructor TCheckNetworkConnectionThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(false);
end;

procedure TCheckNetworkConnectionThread.Execute;
var s:String;
begin
  s:='';
  if (not Terminated) then
  try
    s:=httpRequest('https://www.example.org');
  except
    On E :Exception do Info('CheckNetworkConnection error',E.Message);
  end;
  freeThreadVars;
  isNetworkEnabled:=s<>'';
end;

{ TDownloadThread }

constructor TDownloadThread.Create(UrlSource, FileDestiny: string);
begin
  FreeOnTerminate := True;
  FUrlSource :='';
  SetUrlSource(UrlSource);
  FFileDestiny:=FileDestiny;
  FOnDownloaded:=nil;
  inherited Create(true);
  FStatus:=dwStart;
  Synchronize(@Showstatus);
end;

procedure TDownloadThread.ShowStatus;
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  if not isNetworkEnabled then Info('TDownloadThread','Warning, Network is disabled');
  case FStatus of
    dwStart: fStatusText := 'Url:'+FUrlSource+' Starting...';
    dwDownloading  :fStatusText := 'Downloading '+FFileDestiny+'...';
    dwIdle: fStatusText := 'Idle.';
  end;
  Info('TDownloadThread.ShowStatus',fStatusText);
end;

procedure TDownloadThread.Downloaded;
begin
  if assigned(FOnDownloaded) then FOnDownloaded;
end;

procedure TDownloadThread.SetFileDestiny(AValue: String);
begin
  if FFileDestiny=AValue then Exit;
  FFileDestiny:=AValue;
end;

procedure TDownloadThread.SetStatus(AValue: tDwStatus);
begin
  if FStatus=AValue then Exit;
  FStatus:=AValue;
end;

procedure TDownloadThread.SetUrlSource(AValue: String);
begin
  if FUrlSource=AValue then Exit;
  FUrlSource := AValue;
end;

procedure TDownloadThread.Execute;
begin
  FStatus:=dwDownloading;
  Synchronize(@Showstatus);
  if (not Terminated) and isNetworkEnabled then
  try
    try
      info('TDownloadThread.Execute',FUrlSource);
      strSaveToFileUTF8(FFileDestiny,retrieve(FUrlSource));
    except
      On E :Exception do Info('TDownloadThread error',E.Message);
    end;
  finally
    // Free Memory from InternetTools
    freeThreadVars;
  end;
  FStatus:=dwIdle;
  Synchronize(@Showstatus);
  Synchronize(@Downloaded);
end;

end.

