unit SBASnippetU;

{$mode objfpc}{$H+}
{ TODO : Fusionar TSBAContrlrProg y TSBASnippet agregando un diferenciador basado en la extension al establecer FileName }
interface

uses
  LCLVersion, Dialogs, Classes, SysUtils, SBAProgContrlrU, ListViewFilterEdit,
  FileUtil, LazFileUtils;

const
  cSBADefaultSnippetName='NewSnippet.snp';

type

  { TSBASnippet }

  TSBASnippet = class(TSBAContrlrProg)
  private
    FData: TStrings;
    FCode: Tstrings;
    FDescription: Tstrings;
    FRegisters: Tstrings;
    FFilter:TListViewFilterEdit;
    FUProc: TStrings;
    FUSignals: Tstrings;
    FUStatements: TStrings;
    procedure AddItemToSnippetsFilter(FileIterator: TFileIterator);
    procedure Setfilename(AValue: string);
  public
    constructor Create;
    destructor Destroy; override;
    function CpyProgDetails(Prog,Src:TStrings):boolean;
    function CpyUserProg(Prog,Src:TStrings):boolean;
    function CpyProgUReg(Prog,Src:TStrings):boolean;
    function CpyUSignals(Prog,Src:TStrings):boolean;
    function CpyUProcedures(Prog, Src: TStrings): boolean;
    function CpyUStatements(Prog, Src: TStrings): boolean;
    procedure UpdateSnippetsFilter(Filter: TListViewFilterEdit);
  published
    property Filename:string read Ffilename write Setfilename;
    property Code:Tstrings read Fcode;
    property Description: Tstrings read Fdescription;
    property Registers: Tstrings read FRegisters;
    property USignals:Tstrings read FUSignals;
    property UProc:TStrings read FUProc;
    property UStatements:TStrings read FUStatements;
  end;


implementation

uses ConfigFormU,UtilsU, DebugU;

{ TSBASnippet }

procedure TSBASnippet.Setfilename(AValue: string);
begin
  if Ffilename=AValue then Exit;
  try
    FData.LoadFromFile(AValue);
  except
    on E: Exception do begin
       showmessage('Code snippet could not be loaded: '+E.Message);
       exit;
    end;
  end;
  CpyUserProg(FData,FCode);
  CpyProgDetails(FData,FDescription);
  CpyProgUReg(FData,FRegisters);
  CpyUSignals(FData,FUSignals);
  CpyUProcedures(FData,FUProc);
  CpyUStatements(FData,FUStatements);
  Ffilename:=AValue;
end;

constructor TSBASnippet.Create;
begin
  inherited Create;
  FFileName:=cSBADefaultSnippetName;
  FData:=TStringList.Create;
  FCode:=TStringList.Create;
  FDescription:=TStringList.Create;
  FRegisters:=TStringList.Create;
  FUProc:= TStringList.Create;
  FUSignals:= TstringList.Create;
  FUStatements:= TStringList.Create;
end;

destructor TSBASnippet.Destroy;
begin
  if assigned(FData) then FreeAndNil(FData);
  if assigned(FCode) then FreeAndNil(FCode);
  if assigned(FRegisters) then FreeAndNil(FRegisters);
  if assigned(FDescription) then FreeAndNil(FDescription);
  if assigned(FUProc) then FreeAndNil(FUProc);
  if assigned(FUSignals) then FreeAndNil(FUSignals);
  if assigned(FUStatements) then FreeAndNil(FUStatements);
  inherited Destroy;
end;

function TSBASnippet.CpyProgDetails(Prog, Src: TStrings): boolean;
Var I:Integer;
begin
  Src.Clear;
  Src.Add(cSBAStartProgDetails);
  Src.Add(cSBAEndProgDetails);
  Result:=inherited CpyProgDetails(Prog, Src);
  If Src.Count>1 then
  begin
    Src.Delete(0);
    Src.Delete(Src.Count-1);
    for I:=0 to Src.count-1 do Src[i]:=Trim(Copy(Src[i],3,1000)); //remove extra comments "--"
  end;
end;

function TSBASnippet.CpyUserProg(Prog, Src: TStrings): boolean;
begin
  Src.Clear;
  Src.Add(cSBAStartUserProg);
  Src.Add(cSBAEndUserProg);
  Result:=inherited CpyUserProg(Prog, Src);
  If Src.Count>1 then
  begin
    Src.Delete(0);
    Src.Delete(Src.Count-1);
  end;
end;

function TSBASnippet.CpyProgUReg(Prog, Src: TStrings): boolean;
begin
  Src.Clear;
  Src.Add(cSBAStartProgUReg);
  Src.Add(cSBAEndProgUReg);
  Result:=inherited CpyProgUReg(Prog, Src);
  If Src.Count>1 then
  begin
    Src.Delete(0);
    Src.Delete(Src.Count-1);
  end;
end;

function TSBASnippet.CpyUSignals(Prog, Src: TStrings): boolean;
begin
  Src.Clear;
  Src.Add(cSBAStartUSignals);
  Src.Add(cSBAEndUSignals);
  Result:=inherited CpyUSignals(Prog, Src);
  If Src.Count>1 then
  begin
    Src.Delete(0);
    Src.Delete(Src.Count-1);
  end;
end;

function TSBASnippet.CpyUProcedures(Prog, Src: TStrings): boolean;
begin
  Src.Clear;
  Src.Add(cSBAStartUProc);
  Src.Add(cSBAEndUProc);
  Result:=inherited CpyUProcedures(Prog, Src);
  If Src.Count>1 then
  begin
    Src.Delete(0);
    Src.Delete(Src.Count-1);
  end;
end;

function TSBASnippet.CpyUStatements(Prog, Src: TStrings): boolean;
begin
  Src.Clear;
  Src.Add(cSBAStartUStatements);
  Src.Add(cSBAEndUStatements);
  Result:=inherited CpyUStatements(Prog, Src);
  If Src.Count>1 then
  begin
    Src.Delete(0);
    Src.Delete(Src.Count-1);
  end;
end;

{$if defined(CODETYPHON) or (lcl_fullversion >= 1070000) }
procedure TSBASnippet.AddItemToSnippetsFilter(FileIterator: TFileIterator);
var
  Data:TListViewDataItem;
begin
  Data.Data := nil;
  SetLength(Data.StringArray,2);
  Data.StringArray[0]:=ExtractFileNameWithoutExt(FileIterator.FileInfo.Name);
  Data.StringArray[1]:=AppendPathDelim(FileIterator.Path)+FileIterator.FileInfo.Name;
  FFilter.Items.Add(Data);
end;
{$ELSE}
procedure TSBASnippet.AddItemToSnippetsFilter(FileIterator: TFileIterator);
var
  Data:TStringArray;
begin
  SetLength(Data,2);
  Data[0]:=ExtractFileNameWithoutExt(FileIterator.FileInfo.Name);
  Data[1]:=AppendPathDelim(FileIterator.Path)+FileIterator.FileInfo.Name;
  FFilter.Items.Add(Data);
end;
{$ENDIF}

procedure TSBASnippet.UpdateSnippetsFilter(Filter:TListViewFilterEdit);
begin
  FFilter:=Filter;
  FFilter.Items.Clear;
  SearchForFiles(SnippetsDir,'*.snp',@AddItemToSnippetsFilter);
  SearchForFiles(LibraryDir,'*.snp',@AddItemToSnippetsFilter);
  FFilter.InvalidateFilter;
end;


end.

