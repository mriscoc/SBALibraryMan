unit DebugU;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, lclversion, dbugintf;

procedure infoEx(L,M:String; MType: TDebugLevel);
procedure info(L:String;M:String='');
procedure info(L:String;I:integer);
procedure info(L:String;b:boolean);
procedure info(L:String;SL:Tstrings);
procedure info(L:String;P:TPoint);
procedure infoErr(L:String;M:String='');

implementation

procedure infoEx(L,M:String; MType: TDebugLevel);
begin
  {$IFDEF DEBUG}
  SendDebugFmtEx('%s: %s',[L,M],MType);
  {$ENDIF}
end;

procedure info(L,M:String);
begin
  {$IFDEF DEBUG}
  SendDebugFmt('%s: %s',[L,M]);
  {$ENDIF}
end;

procedure info(L:string; I: integer);
begin
  {$IFDEF DEBUG}
  info(L,inttostr(i));
  {$ENDIF}
end;

procedure info(L:string;b: boolean);
begin
  {$IFDEF DEBUG}
  if b then info(L,'true') else info(L,'false');
  {$ENDIF}
end;

procedure info(L:String;SL: TStrings);
var s:string;
begin
  {$IFDEF DEBUG}
  SendSeparator;
  info(L,'Start of list: ');
  for s in SL do info('',s);
  info(L,'End of list');
  SendSeparator;
  {$ENDIF}
end;

procedure info(L: String; P: TPoint);
begin
  {$IFDEF DEBUG}
  info(L,' X='+inttostr(P.x)+' Y='+inttostr(P.y));
  {$ENDIF}
end;

procedure infoErr(L: String; M: String);
begin
  {$IFDEF DEBUG}
  SendDebugFmtEx('%s: %s',[L,M],dlError);
  {$ENDIF}
end;


initialization

  info('LCLFullVersion',lcl_fullversion);

end.

