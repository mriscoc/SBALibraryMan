unit SBAProgramU;

{$mode objfpc}{$H+}

interface

uses
  LCLVersion, Dialogs, Classes, SysUtils, SBAProgContrlrU, ListViewFilterEdit, FileUtil,
  LazFileUtils, ConfigU;

const
  cSBADefaultPrgName='NewProgram.prg';
  cSBADefPrgTemplate='PrgTemplate.prg';
  cSBAAdvPrgTemplate='AdvPrgTemplate.prg';

type

  { TSBAProgram }
{ TODO : Mover Variables, propiedades y métodos comunes de TSBAProgram y TSBASnippet al Objeto Ancestro TSBAContrlrProg o bien crear un ancestro intermedio que resuma lo común }
  TSBAProgram = class(TSBAContrlrProg)
  private
    FData: TStrings;
    FCode: Tstrings;
    FDescription: Tstrings;
    FRegisters: Tstrings;
    FFilter:TListViewFilterEdit;
    procedure AddItemToProgramsFilter(FileIterator: TFileIterator);
    procedure Setfilename(AValue: string);
  public
    constructor Create;
    destructor Destroy; override;
    function CpyProgDetails(Prog,Src:TStrings):boolean;
    function CpyUserProg(Prog,Src:TStrings):boolean;
    function CpyProgUReg(Prog,Src:TStrings):boolean;
    procedure UpdateProgramsFilter(Filter: TListViewFilterEdit);
  published
    property Filename:string read Ffilename write Setfilename;
    property Code:Tstrings read Fcode;
    property Description: Tstrings read Fdescription;
    property Registers: Tstrings read FRegisters;
  end;


implementation

uses UtilsU;

{ TSBAProgram }

procedure TSBAProgram.Setfilename(AValue: string);
begin
  if Ffilename=AValue then Exit;
  try
    FData.LoadFromFile(AValue);
  except
    showmessage('Code Program could not be loaded');
    exit;
  end;
  CpyUserProg(FData,FCode);
  CpyProgDetails(FData,FDescription);
  CpyProgUReg(FData,FRegisters);
  Ffilename:=AValue;
end;

constructor TSBAProgram.Create;
begin
  inherited Create;
  FFileName:=cSBADefaultPrgName;
  FData:=TStringList.Create;
  FCode:=TStringList.Create;
  FDescription:=TStringList.Create;
  FRegisters:=TStringList.Create;
end;

destructor TSBAProgram.Destroy;
begin
  if assigned(FData) then FreeAndNil(FData);
  if assigned(FCode) then FreeAndNil(FCode);
  if assigned(FRegisters) then FreeAndNil(FRegisters);
  if assigned(FDescription) then FreeAndNil(FDescription);
  inherited Destroy;
end;

function TSBAProgram.CpyProgDetails(Prog, Src: TStrings): boolean;
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

function TSBAProgram.CpyUserProg(Prog, Src: TStrings): boolean;
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

function TSBAProgram.CpyProgUReg(Prog, Src: TStrings): boolean;
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

{$if (lcl_fullversion >= 1070000)}
procedure TSBAProgram.AddItemToProgramsFilter(FileIterator: TFileIterator);
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
procedure TSBAProgram.AddItemToProgramsFilter(FileIterator: TFileIterator);
var
  Data:TStringArray;
begin
  SetLength(Data,2);
  Data[0]:=ExtractFileNameWithoutExt(FileIterator.FileInfo.Name);
  Data[1]:=AppendPathDelim(FileIterator.Path)+FileIterator.FileInfo.Name;
  FFilter.Items.Add(Data);
end;
{$ENDIF}

procedure TSBAProgram.UpdateProgramsFilter(Filter:TListViewFilterEdit);
begin
  FFilter:=Filter;
  FFilter.Items.Clear;
  SearchForFiles(ProgramsDir,'*.prg',@AddItemToProgramsFilter);
  SearchForFiles(LibraryDir,'*.prg',@AddItemToProgramsFilter);
  FFilter.InvalidateFilter;
end;


end.

