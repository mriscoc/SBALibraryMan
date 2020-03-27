unit SBAProgContrlrU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, Math, ConfigU;

const
  cSBACtrlrSignatr='-- /SBA: Controller';
  cSBALblSignatr='-- /L:';
  cSBAStartProgDetails='-- /SBA: Program Details';
  cSBAEndProgDetails='-- /SBA: End';
  cSBAStartUSignals='-- /SBA: User Signals';
  cSBAEndUSignals='-- /SBA: End';
  cSBAStartUProc='-- /SBA: User Procedures';
  cSBAEndUProc='-- /SBA: End';
  cSBAStartProgUReg='-- /SBA: User Registers';
  cSBAEndProgUReg='-- /SBA: End';
  cSBAStartProgLabels='-- /SBA: Label constants';
  cSBAEndProgLabels='-- /SBA: End';
  cSBAStartUserProg='-- /SBA: User Program';
  cSBAEndUserProg='-- /SBA: End';
  cSBAStartUStatements='-- /SBA: User Statements';
  cSBAEndUStatements='-- /SBA: End';
  cSBASTPTypedef='subtype STP_type';

type

  { TSBAContrlrProg }

  TSBAContrlrProg = class(TObject)
    FFileName : string;
    STPCnt : integer;
  private
    procedure SetFilename(AValue: String);
  public
    constructor Create;
    function DetectSBAContrlr(Src:TStrings):boolean;
    function ExtractSBALbls(Prog:TStrings; Labels:TListItems): boolean;
    function CpyUBlock(Prog,Src:TStrings;BStart,BEnd:String):boolean;
    function CpySrc2Prog(Src,Prog:TStrings):boolean;
    function CpyProgDetails(Prog,Src:TStrings):boolean;
    function CpyUSignals(Prog,Src:TStrings):boolean;
    function CpyUProcedures(Prog, Src: TStrings): boolean;
    function CpyProgUReg(Prog,Src:TStrings):boolean;
    function GenLblandProgFormat(Prog:TStrings; Labels:TListItems ): boolean;
    function CpyProgLabels(Labels:TListItems;Src:TStrings):boolean;
    function CpyUserProg(Prog,Src:TStrings):boolean;
    function CpyUStatements(Prog, Src: TStrings): boolean;
    property Filename : String read FFilename write SetFilename;
  end;

implementation

uses SBAProgramU, UtilsU, DebugU;

{ TSBAContrlrProg }

function TSBAContrlrProg.DetectSBAContrlr(Src: TStrings): boolean;
var I:integer;
begin
  Result:=false;
  for I:=0 to Min(Src.Count-1,9) do
  begin
    Result:=(Pos(cSBACtrlrSignatr,Src[i])<>0);
    if Result then break;
  end;
end;

function TSBAContrlrProg.ExtractSBALbls(Prog: TStrings; Labels: TListItems
  ): boolean;
var
  i,iPos,sblock:integer;
begin
  Result:=false;
  Labels.Clear;
  sblock:=GetPosList(cSBAStartUserProg,Prog);
  if sblock=-1 then exit;
  for i:=sblock to Prog.Count-1 do
  begin
    iPos := Pos(cSBALblSignatr, Prog[i]);
    if (iPos<>0) then Labels.Add.Caption:=Copy(Prog[i],iPos+length(cSBALblSignatr),100);
    if (pos(cSBAEndUserProg,Prog[i])<>0) then break;
  end;
  Result:=pos(cSBAEndUserProg,Prog[i])<>0;
end;

function TSBAContrlrProg.CpySrc2Prog(Src, Prog: TStrings): boolean;
var
  i,startpos,iPos:integer;

  function CopyS2P(BStart,BEnd:string):boolean;
  var i:integer;
  begin
    result:=false;
    startpos:=GetPosList(BStart,Src);
    if startpos>=0 then
    begin
      For i:=startpos to Src.Count-1 do
      begin
        Prog.Append(Src[i]);
        if (pos(BEnd,Src[i])<>0) then break;
      end;
      if (pos(BEnd,Src[i])=0) then exit;
      Prog.Append('');
      result:=true;
    end;
  end;

begin
  Result:=false;
  Prog.Clear;

  // Program Details
  if not CopyS2P(cSBAStartProgDetails,cSBAEndProgDetails) then exit;

  // User Signals (Optional)
  if CtrlAdvMode then CopyS2P(cSBAStartUSignals,cSBAEndUSignals);

  // User Main process Procedures and Functions (Optional)
  if CtrlAdvMode then CopyS2P(cSBAStartUProc,cSBAEndUProc);

  // Program User Registers and Constants
  if not CopyS2P(cSBAStartProgUReg,cSBAEndProgUReg) then exit;

  //Check for labels block
  startpos:=GetPosList(cSBAStartProgLabels,Src);
  iPos:=GetPosList(cSBAEndProgLabels,Src,startpos);
  startpos:=GetPosList(cSBAStartUserProg,Src,iPos);
  if startpos=-1 then exit;

  // SBA User Program
  startpos:=GetPosList(cSBAStartUserProg,Src);
  if startpos>=0 then
  begin
    iPos:=0;
    For i:=startpos to Src.Count-1 do
    begin
      iPos := Pos('=>', Src[i]);
      if (iPos<>0) then break;
    end;
    if (iPos=0) or (iPos>20) then exit;

    For i:=startpos to Src.Count-1 do
    begin
      if LeftStr(Src[i],2)='--' then
        Prog.Append(Src[i])
      else
        Prog.Append(Copy(Src[i],iPos,1000));
      if (pos(cSBAEndUserProg,Src[i])<>0) then break;
    end;
    if (pos(cSBAEndUserProg,Src[i])=0) then exit;
    Prog.Append('');
  end;

  // User Statements (Optional)
  if CtrlAdvMode then CopyS2P(cSBAStartUStatements,cSBAEndUStatements);

  Result:=true;
end;

// Copy User block code from Prog to Src
// BStart and BEnd are start and end block signature constants
function TSBAContrlrProg.CpyUBlock(Prog, Src: TStrings; BStart, BEnd: String
  ): boolean;
var
  i,sblock,eblock,iPos:integer;

begin
  Result:=false;

  iPos:=GetPosList(BStart,Src);
  if iPos=-1 then
  begin
    Result:=GetPosList(BStart,Prog)=-1;
    exit;
  end;

  while (pos(BEnd,Src[iPos])=0) and (Src.Count>iPos) do Src.Delete(iPos);
  if (pos(BEnd,Src[iPos])=0) then exit else Src.Delete(iPos);

  sblock:=GetPosList(BStart,Prog);
  eblock:=GetPosList(BEnd,Prog,sblock);
  if (sblock=-1) or (eblock=-1) then exit;

  For i:=eblock downto sblock do Src.Insert(iPos,Prog[i]);
  Result:=true;
end;

// Copy Program Details
function TSBAContrlrProg.CpyProgDetails(Prog, Src: TStrings): boolean;
begin
  Result:=CpyUBlock(Prog,Src,cSBAStartProgDetails,cSBAEndProgDetails);
end;

// Copy User signals and type definitions
function TSBAContrlrProg.CpyUSignals(Prog, Src: TStrings): boolean;
begin
  Result:=CpyUBlock(Prog,Src,cSBAStartUSignals,cSBAEndUSignals);
end;

// Copy Main process user prodecures and functions
function TSBAContrlrProg.CpyUProcedures(Prog, Src: TStrings): boolean;
begin
  Result:=CpyUBlock(Prog,Src,cSBAStartUProc,cSBAEndUProc);
end;

//Copy User registers and constants
function TSBAContrlrProg.CpyProgUReg(Prog, Src: TStrings): boolean;
begin
  Result:=CpyUBlock(Prog,Src,cSBAStartProgUReg,cSBAEndProgUReg);
end;

// Copy User program
function TSBAContrlrProg.CpyUserProg(Prog, Src: TStrings): boolean;
begin
  Result:=CpyUBlock(Prog,Src,cSBAStartUserProg,cSBAEndUserProg);
end;

//Copy User Statements
function TSBAContrlrProg.CpyUStatements(Prog, Src: TStrings): boolean;
begin
  Result:=CpyUBlock(Prog,Src,cSBAStartUStatements,cSBAEndUStatements);
end;

// Set Controller file name
procedure TSBAContrlrProg.SetFilename(AValue: String);
begin
  if FFilename=AValue then Exit;
  FFilename:=AValue;
end;

constructor TSBAContrlrProg.Create;
begin
  FFileName:=ProgramsDir+cSBADefaultPrgName;
end;

// Extract Labels and complete steps numbers
function TSBAContrlrProg.GenLblandProgFormat(Prog: TStrings; Labels: TListItems
  ): boolean;
const
  sizestep = 3;  //Number of digits for the step
var
  i,sblock:integer;
  iPos,cnt:integer;
  s:String;
begin
  Result:=false;
  Labels.Clear;
  cnt:=1;
  sblock:=GetPosList(cSBAStartUserProg,Prog);
  if sblock=-1 then exit;

  for i:=sblock to Prog.Count-1 do
  begin
    iPos := Pos(cSBALblSignatr, Prog[i]);
    if (iPos<>0) then Labels.Add.Caption:='  constant '+Copy(Prog[i],iPos+length(cSBALblSignatr),100)+': integer := '+Format('%.*d;', [sizestep,cnt]);
    iPos := Pos('=>', Prog[i]);
    if (iPos=1) then
    begin
      s:='        When '+Format('%.*d', [sizestep,cnt]);
      inc(cnt);
    end else S:= Format('%*s',[13+sizestep,' ']);
    if LeftStr(Prog[i],2)<>'--' then Prog[i]:=S+Prog[i];
    if (pos(cSBAEndUserProg,Prog[i])<>0) then break;
  end;
  STPCnt:=cnt;
  Result:=pos(cSBAEndUserProg,Prog[i])<>0;
end;

// Copy program labels
function TSBAContrlrProg.CpyProgLabels(Labels: TListItems; Src: TStrings
  ): boolean;
var i,iPos:integer;
begin
  Result:=false;
  iPos:=GetPosList(cSBAStartProgLabels,Src);
  if iPos=-1 then exit;
  Inc(iPos);
  while (pos(cSBAEndProgLabels,Src[iPos])=0) and (Src.Count>iPos) do Src.Delete(iPos);
  if (pos(cSBAEndProgLabels,Src[iPos])=0) then exit;
  For i:=Labels.Count-1 downto 0 do Src.Insert(iPos,Labels[i].Caption);
  iPos:=GetPosList(cSBASTPTypedef,Src);
  if iPos<>-1 then Src[iPos]:='  subtype STP_type is integer range 0 to '+inttostr(STPCnt)+';';
  Result:=true;
end;

end.

