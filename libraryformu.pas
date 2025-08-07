unit LibraryFormU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ListViewFilterEdit, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Buttons, ExtCtrls, FileUtil, LazFileUtils, SynExportHTML, StrUtils,
  SynHighlighterPas, SynHighlighterHTML, SynHighlighterCpp, SynHighlighterIni,
  lclintf, StdCtrls, EditBtn, Menus, IniPropStorage, IniFiles,
  SynHighlighterPython, SynEdit, SynHighlighterVHDL,
  MarkdownProcessor, MarkdownUtils, uEImage, BGRABitmap, Math, ConfigU,
  versionsupportu;

type
  tLibDwStatus=(Idle,GetBase, GetLibrary, GetPrograms, GetSnippets);


type

  { TLibraryForm }
  TLibraryForm = class(TForm)
    B_OpenRepo: TBitBtn;
    B_OpenDS: TBitBtn;
    B_AddtoLibrary: TBitBtn;
    B_AddtoPrograms: TBitBtn;
    B_AddtoSnippets: TBitBtn;
    B_SBAbaseGet: TBitBtn;
    B_SBAbaseSurf: TBitBtn;
    B_SBAlibraryGet: TBitBtn;
    B_SBAlibrarySurf: TBitBtn;
    B_SBAprogramsGet: TBitBtn;
    B_SBAprogramsSurf: TBitBtn;
    B_SBAsnippetsGet: TBitBtn;
    B_SBAsnippetsSurf: TBitBtn;
    CoreImagePanel: TuEImage;
    Ed_SBAbase: TEditButton;
    Ed_SBAlibrary: TEditButton;
    Ed_SBAprograms: TEditButton;
    Ed_SBARepoZipFile: TComboBox;
    Ed_SBAsnippets: TEditButton;
    GB_SBAbase: TGroupBox;
    GB_SBAlibrary: TGroupBox;
    GB_SBAprograms: TGroupBox;
    GB_SBAsnippets: TGroupBox;
    IniStor: TIniPropStorage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SnpVersionEd: TLabeledEdit;
    PrgVersionEd: TLabeledEdit;
    L_TitleIPCore: TLabel;
    MenuItem1: TMenuItem;
    Panel7: TPanel;
    ItemsMenu: TPopupMenu;
    Panel8: TPanel;
    Label5: TLabel;
    LibraryPages: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    PB_SBAbase: TProgressBar;
    PB_SBAlibrary: TProgressBar;
    PB_SBAprograms: TProgressBar;
    PB_SBAsnippets: TProgressBar;
    IpCoreDescription: TMemo;
    LibVersionEd: TLabeledEdit;
    SnpDescription: TSynEdit;
    SnippetsFilter: TListViewFilterEdit;
    IPCoresFilter: TListViewFilterEdit;
    ProgramsFilter: TListViewFilterEdit;
    LV_Snippets: TListView;
    IPCores: TTabSheet;
    Programs: TTabSheet;
    Snippets: TTabSheet;
    LV_IPCores: TListView;
    LV_Programs: TListView;
    SB: TStatusBar;
    PrgDescription: TSynEdit;
    SynExporterHTML: TSynExporterHTML;
    SynVHDLSyn1: TSynVHDLSyn;
    UpdateRep: TTabSheet;
    procedure B_OpenDSClick(Sender: TObject);
    procedure B_AddtoSnippetsClick(Sender: TObject);
    procedure B_AddtoProgramsClick(Sender: TObject);
    procedure B_AddtoLibraryClick(Sender: TObject);
    procedure B_SBAbaseGetClick(Sender: TObject);
    procedure B_SBAbaseSurfClick(Sender: TObject);
    procedure B_SBAlibraryGetClick(Sender: TObject);
    procedure B_SBAlibrarySurfClick(Sender: TObject);
    procedure B_SBAprogramsGetClick(Sender: TObject);
    procedure B_SBAprogramsSurfClick(Sender: TObject);
    procedure B_SBAsnippetsGetClick(Sender: TObject);
    procedure B_SBAsnippetsSurfClick(Sender: TObject);
    procedure Ed_SBAlibraryButtonClick(Sender: TObject);
    procedure Ed_SBAprogramsButtonClick(Sender: TObject);
    procedure Ed_SBAsnippetsButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LV_IPCoresCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure LV_IPCoresSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LV_ProgramsCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure LV_ProgramsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LV_SnippetsCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure LV_SnippetsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MenuItem1Click(Sender: TObject);
    procedure URL_IpCoreClick(Sender: TObject);
  private
    function ItemColor(Item: TListItem):TColor;
    procedure AddItemToIPCoresFilter(FileIterator: TFileIterator);
    procedure AddItemToProgramsFilter(FileIterator: TFileIterator);
    procedure AddItemToSnippetsFilter(FileIterator: TFileIterator);
    procedure dwTerminate;
    function EndGet(zfile, defdir: string): boolean;
    function EndGetBase: boolean;
    procedure EndGetLibrary;
    procedure EndGetPrograms;
    procedure EndGetSnippets;
    function GetIniVersion(f: string): string;
    function LookupFilterItem(S: string; LV: TListViewDataList): integer;
    procedure ProcessGetFile(UrlValue, ZipFile: string; PB: TProgressBar;
      status: TLibDwStatus);
    procedure UpdateIpCoresList;
    procedure UpdateProgramsList;
    procedure UpdateSnippetsList;
    { private declarations }
  public
    { public declarations }
    procedure UpdateLocalLists;
    procedure OpenDataSheet(f: string);
    function Md2Html(fi: string): string;
    function Md2Html(s, fi: string): string;
  end;

  { TCodeEmiter }

  TCodeEmiter = class(TBlockEmitter)
  public
    procedure emitBlock(out_: TStringBuilder; lines: TStringList; meta: String); override;
  end;

var
  LibraryForm: TLibraryForm;

function ShowLibraryForm:TModalResult;

implementation

{$R *.lfm}

uses UtilsU, DWFileU, DebugU;

var
  LibDwStatus:TLibDwStatus=Idle;
  URL_IpCore:String='';
  IpCoreDatasheet:String='';

const
  CSSDecoration = '<style type="text/css">'#10+
                  'code{'#10+
                  '  color: #A00;'#10+
                  '}'#10+
                  'pre{'#10+
                  '  background: #f4f4f4;'#10+
                  '  border: 1px solid #ddd;'#10+
                  '  border-left: 3px solid #f36d33;'#10+
                  '  color: #555;'#10+
                  '  overflow: auto;'#10+
                  '  padding: 1em 1.5em;'#10+
                  '  display: block;'#10+
                  '}'#10+
                  'pre code{'#10+
                  '  color: inherit;'#10+
                  '}'#10+
                  'Blockquote{'#10+
                  '  border-left: 3px solid #d0d0d0;'#10+
                  '  padding-left: 0.5em;'#10+
                  '  margin-left:1em;'#10+
                  '}'#10+
                  'Blockquote p{'#10+
                  '  margin: 0;'#10+
                  '}'#10+
                  'table{'#10+
                  '  border:1px solid;'#10+
                  '  border-collapse:collapse;'#10+
                  '}'#10+
                  'th{'+
                  '  padding:5px;'#10+
                  '  background: #e0e0e0;'#10+
                  '  border:1px solid;'#10+
                  '}'#10+
                  'td{'#10+
                  '  padding:5px;'#10+
                  '  border:1px solid;'#10+
                  '}'#10+
                  '</style>'#10;


function ShowLibraryForm: TModalResult;
begin
  LibraryForm.UpdateLocalLists;
  result:=LibraryForm.ShowModal;
end;

{ TCodeEmiter }

procedure TCodeEmiter.emitBlock(out_: TStringBuilder; lines: TStringList;
  meta: String);
var
  s:string;

  procedure exportlines;
  var
    sstream: TStringStream;
  begin
    LibraryForm.SynExporterHTML.Options:=LibraryForm.SynExporterHTML.Options-[heoWinClipHeader];
    LibraryForm.SynExporterHTML.ExportAll(lines);
    try
      sstream:=TStringStream.Create('');
      LibraryForm.SynExporterHTML.SaveToStream(sstream);
      out_.Append(sstream.DataString);
    finally
      if assigned(sstream) then freeandnil(sstream);
    end;
  end;

begin
  with LibraryForm do case meta of
    'vhdl':
      begin
        SynExporterHTML.Highlighter:=TSynVHDLSyn.Create(LibraryForm);
        exportlines;
      end;
    'html':
      begin
        SynExporterHTML.Highlighter:=TSynHTMLSyn.Create(LibraryForm);
        exportlines;
      end;
    'fpc','pas','pascal':
      begin
        SynExporterHTML.Highlighter:=TSynFreePascalSyn.Create(LibraryForm);
        exportlines;
      end;
    'cpp','c++','c':
      begin
        SynExporterHTML.Highlighter:=TSynCppSyn.Create(LibraryForm);
        exportlines;
      end;
    'py','python':
      begin
        SynExporterHTML.Highlighter:=TSynPythonSyn.Create(LibraryForm);
        exportlines;
      end;
     'ini':
       begin
        SynExporterHTML.Highlighter:=TSynIniSyn.Create(LibraryForm);
        exportlines;
       end
    else
      begin
        if meta='' then   out_.append('<pre><code>')
        else out_.append('<pre><code class="'+meta+'">');
        for s in lines do
        begin
          TUtils.appendValue(out_,s,0,Length(s));
          out_.append(#10);
        end;
        out_.append('</code></pre>'#10);
      end;
  end;
end;

{ TLibraryForm }

procedure TLibraryForm.LV_SnippetsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Color:=ItemColor(Item);
{$IFDEF LINUX}
//Workaround to ListView.Canvas.Font in GTK
  if Item.SubItems[1]<>'=' then
  begin
    DefaultDraw:=False;
    Sender.Canvas.Brush.Style:=bsClear;
    Sender.Canvas.TextOut(Item.Left+5, Item.Top+3, Item.Caption);
  end;
{$ENDIF}
end;

procedure TLibraryForm.LV_SnippetsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  f,fname:string;
  l:TListItem;
begin
  L:=LV_Snippets.Selected;
  if (L=nil) or (LV_Snippets.Items.Count=0) then exit;
  f:=L.SubItems[0];
  if FileExists(f) then SnpDescription.Lines.LoadFromFile(f);
  fname:=ExtractFileName(f);
  SnpVersionEd.text:=GetVersionFrom(SnippetsDir+PathDelim+fname);
  B_AddtoSnippets.Enabled:=(L.SubItems[1]='N') or (L.SubItems[1]='U');
end;

procedure TLibraryForm.MenuItem1Click(Sender: TObject);
var
  L:TListItem;
  d:string;
begin
  L:=nil;
  Case LibraryPages.ActivePageIndex of
    1 : L:=LV_IPCores.Selected;
    2 : L:=LV_Programs.Selected;
    3 : L:=LV_Snippets.Selected;
  end;
  if (L=nil) then exit;
  Case LibraryPages.ActivePageIndex of
    1 : d:=LibraryDir+L.Caption;
    2 : d:=ProgramsDir;
    3 : d:=SnippetsDir;
  else d:='';
  end;
  Info('MenuItem1Click','Try to open folder : '+d);
  if DirectoryExists(d) then OpenDocument(d);
end;


procedure TLibraryForm.URL_IpCoreClick(Sender: TObject);
begin
  OpenURL(URL_IpCore);
end;

procedure TLibraryForm.ProcessGetFile(UrlValue,ZipFile:string;PB:TProgressBar;status:TLibDwStatus);
var DwT:TDownloadThread;
begin
  PB.Style:=pbstMarquee;
  Application.ProcessMessages;
  SB.SimpleText:='Downloading file '+ZipFile;
  if UrlSolveRedir(UrlValue) then
  begin
    DeleteFile(ConfigDir+ZipFile);
    DwT:=TDownloadThread.create(UrlValue+Ed_SBARepoZipFile.Text,ConfigDir+ZipFile);
    DwT.OnDownloaded:=@dwTerminate;
    LibDwStatus:=status;
    DwT.start;
  end else ShowMessage('Remote repository is offline');
end;

procedure TLibraryForm.B_SBAbaseSurfClick(Sender: TObject);
begin
  OpenURL(Ed_SBAbase.Text);
end;

procedure TLibraryForm.B_SBAbaseGetClick(Sender: TObject);
begin
  ProcessGetFile(Ed_SBAbase.Text,cSBABaseZipFile,PB_SBABase,GetBase);
end;

procedure TLibraryForm.B_SBAlibraryGetClick(Sender: TObject);
begin
  ProcessGetFile(Ed_SBAlibrary.Text,cSBAlibraryZipFile,PB_SBALibrary,GetLibrary);
end;

procedure TLibraryForm.B_SBAlibrarySurfClick(Sender: TObject);
begin
  OpenURL(Ed_SBAlibrary.Text);
end;

procedure TLibraryForm.B_SBAprogramsGetClick(Sender: TObject);
begin
  ProcessGetFile(Ed_SBAprograms.Text,cSBAprogramsZipFile,PB_SBAprograms,Getprograms);
end;

procedure TLibraryForm.B_SBAprogramsSurfClick(Sender: TObject);
begin
  OpenURL(Ed_SBAprograms.Text);
end;

procedure TLibraryForm.B_SBAsnippetsGetClick(Sender: TObject);
begin
  ProcessGetFile(Ed_SBAsnippets.Text,cSBAsnippetsZipFile,PB_SBAsnippets,Getsnippets);
end;

procedure TLibraryForm.B_SBAsnippetsSurfClick(Sender: TObject);
begin
  OpenURL(Ed_SBAsnippets.Text);
end;

procedure TLibraryForm.Ed_SBAlibraryButtonClick(Sender: TObject);
begin
  Ed_SBAlibrary.text:='http://sbalibrary.accesus.com';
end;

procedure TLibraryForm.Ed_SBAprogramsButtonClick(Sender: TObject);
begin
  Ed_SBAprograms.Text:='http://sbaprograms.accesus.com';
end;

procedure TLibraryForm.Ed_SBAsnippetsButtonClick(Sender: TObject);
begin
  Ed_SBAsnippets.Text:='http://sbasnippets.accesus.com'
end;

procedure TLibraryForm.FormCreate(Sender: TObject);
begin
  if not CheckNetworkConnection then ShowMessage('Network connection not available.');
//  isNetworkEnabled:=true;
  if not GetConfigValues then exit;
  {$IFDEF DEBUG}
  caption:='SBA Library Manager v'+GetFileVersion+' DEBUG mode';
  info('TMainForm.FormCreate',caption);
  {$ELSE}
  caption:='SBA Library Manager v'+GetFileVersion;
  {$ENDIF}
  SB.SimpleText:='Config file: '+ConfigFile;
  IniStor.IniFileName:=ConfigFile;
  IniStor.IniSection:='LibraryMan';
  IpCoreList:=TStringList.Create;
  SnippetsList:=TStringList.Create;
  ProgramsList:=TStringList.Create;
  UpdateLists;
  UpdateLocalLists;
  LibraryPages.ActivePageIndex:=0;
  {$IFDEF LINUX}
  //BUG:Workaround to correct an exception when the focus return to "update repositories" page-
  Ed_SBAbase.Enabled:=false;
  {$ENDIF}
  PrgDescription.Font.Size:=7;
  PrgDescription.Font.Quality:=fqCleartype;
  SnpDescription.Font.Size:=7;
  SnpDescription.Font.Quality:=fqCleartype;
  IniStor.WriteString('OpenAt',DateTimeToStr(Now));
end;

procedure TLibraryForm.FormDestroy(Sender: TObject);
begin
  Info('TLibraryForm','FormDestroy');
  if assigned(IpCoreList) then FreeAndNil(IpCoreList);
  if assigned(SnippetsList) then FreeAndNil(SnippetsList);
  if assigned(ProgramsList) then FreeAndNil(ProgramsList);
end;

function TLibraryForm.ItemColor(Item: TListItem):TColor;
var Icolor:TColor;
begin
  case Item.SubItems[1] of
    'U': Icolor:=clBlue;
    '=': Icolor:=clBlack;
    'N': Icolor:=clGreen;
  else Icolor:=clRed;
  end;
  result:=Icolor;
end;

procedure TLibraryForm.LV_IPCoresCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Color:=ItemColor(Item);
{$IFDEF LINUX}
//Workaround to ListView.Canvas.Font in GTK
  if Item.SubItems[1]<>'=' then
  begin
    DefaultDraw:=False;
    Sender.Canvas.Brush.Style:=bsClear;
    Sender.Canvas.TextOut(Item.Left+5, Item.Top+3, Item.Caption);
  end;
{$ENDIF}
end;

procedure TLibraryForm.LV_IPCoresSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  f,fname,path,Img:string;
  l:TListItem;
  Ini:TIniFile;
begin
  CoreImagePanel.Image.Clear;
  IpCoreDescription.Clear;
  L_TitleIpCore.Caption:='';
  IpCoreDataSheet:='';
  URL_IpCore:='';
  L:=LV_IPCores.Selected;
  if (L=nil) or (LV_IPCores.Items.Count=0) then exit;
  B_AddtoLibrary.Enabled:=(L.SubItems[1]='N') or (L.SubItems[1]='U');
  f:=L.SubItems[0];
  if f<>'' then
  try
    Ini:=TINIFile.Create(f);
    Path:=ExtractFilePath(f);
    fname:=ExtractFileNameOnly(f);
    IpCoreDescription.Caption:=Ini.ReadString('MAIN','Description','') + LineEnding + LineEnding + 'Version: '+Ini.ReadString('MAIN','Version','0.0.1');
    L_TitleIpCore.Caption:=Ini.ReadString('MAIN','Title','');
    URL_IpCore:=Ini.ReadString('MAIN','RepositoryURL','');
    IpCoreDataSheet:=Path+Ini.ReadString('MAIN','DataSheet','readme.md');
    Img:=Path+Ini.ReadString('MAIN','Image','image.png');
    LibVersionEd.text:=GetIniVersion(LibraryDir+fname+PathDelim+fname+'.ini')
  finally
    Ini.free;
  end;
  try
    CoreImagePanel.LoadFromFile(Img);
  except
    ON E:Exception do InfoErr('TLibraryForm.LV_IPCoresSelectItem',E.Message)
  end;
end;

procedure TLibraryForm.LV_ProgramsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Color:=ItemColor(Item);
{$IFDEF LINUX}
//Workaround to ListView.Canvas.Font in GTK
  if Item.SubItems[1]<>'=' then
  begin
    DefaultDraw:=False;
    Sender.Canvas.Brush.Style:=bsClear;
    Sender.Canvas.TextOut(Item.Left+5, Item.Top+3, Item.Caption);
  end;
{$ENDIF}
end;

procedure TLibraryForm.LV_ProgramsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  f,fname:string;
  l:TListItem;
begin
  L:=LV_Programs.Selected;
  if (L=nil) or (LV_Programs.Items.Count=0) then exit;
  f:=L.SubItems[0];
  if f<>'' then PrgDescription.Lines.LoadFromFile(f);
  fname:=ExtractFileName(f);
  PrgVersionEd.text:=GetVersionFrom(ProgramsDir+PathDelim+fname);
  B_AddtoPrograms.Enabled:=(L.SubItems[1]='N') or (L.SubItems[1]='U');
end;

procedure TLibraryForm.B_AddtoLibraryClick(Sender: TObject);
var
  L:TListItem;
  f,d:string;
begin
  L:=LV_IPCores.Selected;
  if (L=nil) or (LV_IPCores.Items.Count=0) then exit;
  f:=ExtractFilePath(L.SubItems[0]);
  d:=AppendPathDelim(LibraryDir+L.Caption);
  try
    if DirectoryExistsUTF8(d) then DirDelete(d);
    if not CopyDirTree(f,d,[cffCreateDestDirectory,cffPreserveTime]) then
      ShowMessage('The IPCore folder could not be copied to the local library.');
  except
    on E:Exception do ShowMessage(E.Message);
  end;
  GetAllFileNamesOnly(LibraryDir,'*.ini',IpCoreList);
  UpdateIPCoresList;
  LV_IPCores.Invalidate;
  B_AddtoLibrary.Enabled:=IpCoreList.IndexOf(L.Caption)=-1;
end;

procedure TLibraryForm.B_AddtoProgramsClick(Sender: TObject);
var
  L:TListItem;
  f,d:string;
begin
  L:=LV_Programs.Selected;
  if (L=nil) or (LV_Programs.Items.Count=0) then exit;
  f:=L.SubItems[0];
  d:=ProgramsDir+L.Caption+'.prg';
  try
    if not CopyFile(f,d) then
      ShowMessage('The Program could not be copied to the local library.');
  except
    on E:Exception do Info('TLibraryForm.B_AddtoProgramsClick',E.Message);
  end;
  GetAllFileNamesOnly(ProgramsDir,'*.prg',ProgramsList);
  UpdateProgramsList;
  LV_Programs.Invalidate;
  B_AddtoPrograms.Enabled:=ProgramsList.IndexOf(L.Caption)=-1;
end;

procedure TLibraryForm.B_AddtoSnippetsClick(Sender: TObject);
var
  L:TListItem;
  f,d:string;
begin
  L:=LV_Snippets.Selected;
  if (L=nil) or (LV_Snippets.Items.Count=0) then exit;
  f:=L.SubItems[0];
  d:=SnippetsDir+L.Caption+'.snp';
  try
    if not CopyFile(f,d) then
      ShowMessage('The Snippet could not be copied to the local library.');
  except
    on E:Exception do Info('TLibraryForm.B_AddtoSnippetsClick',E.Message);
  end;
  GetAllFileNamesOnly(SnippetsDir,'*.snp',SnippetsList);
  UpdateSnippetsList;
  LV_Snippets.Invalidate;
  B_AddtoSnippets.Enabled:=SnippetsList.IndexOf(L.Caption)=-1;
end;

procedure TLibraryForm.B_OpenDSClick(Sender: TObject);
begin
  OpenDataSheet(IpCoreDatasheet);
end;

function TLibraryForm.EndGetBase:boolean;
begin
  result:=false;
  if FileSize(ConfigDir+cSBABaseZipFile)<1 then
  begin
    SB.SimpleText:='Invalid or missing zip file';
    ShowMessage('Was not possible to get the main base files from the repository');
    PB_SBABase.Style:=pbstNormal;
    exit(false);
  end;
  SB.SimpleText:='Unziping file '+cSBABaseZipFile;
  if UnZip(ConfigDir+cSBABaseZipFile,ConfigDir+'temp') then
  begin
    info('TLibraryForm.EndGetBase','Unziping file and copy '+cSBABaseZipFile);
    SB.SimpleText:='';
    DirDelete(SBAbaseDir);
    result:=(not DirectoryExistsUTF8(SBAbaseDir)) and
            RenameFile(ConfigDir+'temp'+PathDelim+DefSBAbaseDir+PathDelim,SBAbaseDir);
  end;
  PB_SBABase.Style:=pbstNormal;
  if result then ShowMessage('The new main base files are ready.')
  else ShowMessage('There was an error trying to copy base folder.');
end;

procedure TLibraryForm.EndGetLibrary;
begin
  if EndGet(cSBAlibraryZipFile,DefLibraryDir) then
  begin
    UpdateIPCoresList;
    ShowMessage('The new IPCore library files are ready.');
  end;
  PB_SBAlibrary.Style:=pbstNormal;
end;

procedure TLibraryForm.EndGetPrograms;
begin
  if EndGet(cSBAprogramsZipFile,DefProgramsDir) then
  begin
    UpdateProgramsList;
    ShowMessage('The new programs files are ready.');
  end;
  PB_SBAprograms.Style:=pbstNormal;
end;

procedure TLibraryForm.EndGetSnippets;
begin
  if EndGet(cSBAsnippetsZipFile,DefSnippetsDir) then
  begin
    UpdateSnippetsList;
    ShowMessage('The new Snippets library files are ready.');
  end;
  PB_SBAsnippets.Style:=pbstNormal;
end;

//Common EndGet function for all repo request
function TLibraryForm.EndGet(zfile,defdir:string):boolean;
var ZipMainFolder:String;
begin
  result:=false;
  if FileSize(ConfigDir+zfile)<1 then
  begin
    SB.SimpleText:='Invalid or missing zip file';
    ShowMessage('Was not possible to get the files from the repository');
    exit;
  end;
  SB.SimpleText:='Unziping file '+zfile;
{ TODO : Extraer la ruta principal del zip para ser usado al extraer librerías de diferentes fuentes o ramas (branchs) establecer un criterio: Siempre las librerías deben empaquetarse en el zip dentro de un directorio.}
  ZipMainFolder:=GetZipMainFolder(ConfigDir+zfile);
  if (ZipMainFolder<>'') and UnZip(ConfigDir+zFile,ConfigDir+'temp') then
  begin
    SB.SimpleText:='Unziping successful';
    if DirReplace(ConfigDir+'temp'+PathDelim+ZipMainFolder,ConfigDir+'temp'+PathDelim+DefDir) then
    begin
      SB.SimpleText:='New items loaded from remote repository';
      if (Trim(Ed_SBARepoZipFile.Text)<>'') and (Ed_SBARepoZipFile.Items.IndexOf(Ed_SBARepoZipFile.Text)=-1) then
      begin
        if Ed_SBARepoZipFile.Items.Count=10 then
        Ed_SBARepoZipFile.Items.Delete(Ed_SBARepoZipFile.Items.Count-1);
        Ed_SBARepoZipFile.Items.Insert(0,Ed_SBARepoZipFile.Text);
      end;
      result:=true;
    end else SB.SimpleText:='There was an error updating folders';
  end else SB.SimpleText:='There was an error unziping';
end;

function TLibraryForm.GetIniVersion(f:string):string;
var ini:TIniFile;
begin
  if FileExistsUTF8(f) then
  try
    ini:=TIniFile.Create(f);
    result:=ini.ReadString('MAIN', 'Version', '0.0.1');
  finally
    if assigned(ini) then FreeAndNil(ini);
  end else result:='0.0.0';
end;

procedure TLibraryForm.AddItemToIPCoresFilter(FileIterator: TFileIterator);
var
  Data:TListViewDataItem;
  v:integer;
begin
  Data.Data := nil;
  SetLength(Data.StringArray,3);
  Data.StringArray[0]:=ExtractFileNameWithoutExt(FileIterator.FileInfo.Name);
  Data.StringArray[1]:=FileIterator.FileName;
  v:=VCmpr(GetIniVersion(FileIterator.FileName),GetIniVersion(LibraryDir+Data.StringArray[0]+PathDelim+Data.StringArray[0]+'.ini'));
  if IpCoreList.IndexOf(Data.StringArray[0])=-1 then
    Data.StringArray[2]:='N'  // The item is new do not exists in local library
  else if v>0 then Data.StringArray[2]:='U' // the item is a new version of the one in the local library
    else if v=0 then Data.StringArray[2]:='=';  // the item is the same as local library
  IPCoresFilter.Items.Add(Data);
end;

procedure TLibraryForm.AddItemToProgramsFilter(FileIterator: TFileIterator);
var
  Data:TListViewDataItem;
  lversion,rversion:string;
  v:integer;
begin
  Data.Data := nil;
  SetLength(Data.StringArray,3);
  Data.StringArray[0]:=ExtractFileNameWithoutExt(FileIterator.FileInfo.Name);
  Data.StringArray[1]:=FileIterator.FileName;
  lversion:=GetVersionFrom(ProgramsDir+FileIterator.FileInfo.Name);
  rversion:=GetVersionFrom(FileIterator.FileName);
  v:=VCmpr(rversion,lversion);
  if ProgramsList.IndexOf(Data.StringArray[0])=-1 then
    Data.StringArray[2]:='N'  // The item is new do not exists in local library
  else if v>0 then Data.StringArray[2]:='U' // the item is a new version of the one in the local library
    else if v=0 then Data.StringArray[2]:='=';  // the item is the same as local library
  ProgramsFilter.Items.Add(Data);
end;

procedure TLibraryForm.AddItemToSnippetsFilter(FileIterator: TFileIterator);
var
  Data:TListViewDataItem;
  lversion,rversion:string;
  v:integer;
begin
  Data.Data := nil;

  //SetLength(Data.StringArray,2);
  //Data.StringArray[0]:=ExtractFileNameWithoutExt(FileIterator.FileInfo.Name);
  //Data.StringArray[1]:=FileIterator.FileName;

  SetLength(Data.StringArray,3);
  Data.StringArray[0]:=ExtractFileNameWithoutExt(FileIterator.FileInfo.Name);
  Data.StringArray[1]:=FileIterator.FileName;
  lversion:=GetVersionFrom(SnippetsDir+FileIterator.FileInfo.Name);
  rversion:=GetVersionFrom(FileIterator.FileName);
  v:=VCmpr(rversion,lversion);
  if SnippetsList.IndexOf(Data.StringArray[0])=-1 then
    Data.StringArray[2]:='N'  // The item is new do not exists in local library
  else if v>0 then Data.StringArray[2]:='U' // the item is a new version of the one in the local library
    else if v=0 then Data.StringArray[2]:='=';  // the item is the same as local library
  SnippetsFilter.Items.Add(Data);
end;

function TLibraryForm.LookupFilterItem(S:string; LV:TListViewDataList):integer;
Var
  i:Integer;
  Data:TStringArray;
begin
  result:=-1; i:=0;
  while (result=-1) and (i<LV.Count) do
  begin
    Data:=LV[i].StringArray;
    if Data[0]=S then result:=i else inc(i);
  end;
end;

procedure TLibraryForm.UpdateIpCoresList;
var
  S:String;
  Data:TListViewDataItem;
begin
  IpCoresFilter.Items.Clear;
  SearchForFiles(ConfigDir+'temp'+PathDelim+DefLibraryDir, '*.ini',@AddItemToIpCoresFilter);
  For S in IpCoreList do if LookupFilterItem(S,IPCoresFilter.Items)=-1 then
  begin
    Data.Data := nil;
    SetLength(Data.StringArray,3);
    Data.StringArray[0]:=S;
    Data.StringArray[1]:=LibraryDir+S+PathDelim+S+'.ini';
    Data.StringArray[2]:='L'; //The item in library is local and do not exist into the repository
    IPCoresFilter.Items.Add(Data);
  end;
  IpCoresFilter.InvalidateFilter;
end;

procedure TLibraryForm.UpdateProgramsList;
var
  S:String;
  Data:TListViewDataItem;
begin
  ProgramsFilter.Items.Clear;
  SearchForFiles(ConfigDir+'temp'+PathDelim+DefProgramsDir, '*.prg',@AddItemToProgramsFilter);
  For S in ProgramsList do if LookupFilterItem(S,ProgramsFilter.Items)=-1 then
  begin
    Data.Data := nil;
    SetLength(Data.StringArray,2);
    Data.StringArray[0]:=S;
    Data.StringArray[1]:=ProgramsDir+S+'.vhd';
    ProgramsFilter.Items.Add(Data);
  end;
  ProgramsFilter.InvalidateFilter;
end;

procedure TLibraryForm.UpdateSnippetsList;
var
  S:String;
  Data:TListViewDataItem;
begin
  SnippetsFilter.Items.Clear;
  SearchForFiles(ConfigDir+'temp'+PathDelim+DefSnippetsDir, '*.snp',@AddItemToSnippetsFilter);
  For S in SnippetsList do if LookupFilterItem(S,SnippetsFilter.Items)=-1 then
  begin
    Data.Data := nil;
    SetLength(Data.StringArray,2);
    Data.StringArray[0]:=S;
    Data.StringArray[1]:=SnippetsDir+S+'.snp';
    SnippetsFilter.Items.Add(Data);
  end;
  SnippetsFilter.InvalidateFilter;
end;

procedure TLibraryForm.UpdateLocalLists;
begin
  UpdateIpCoresList;
  UpdateProgramsList;
  UpdateSnippetsList
end;

procedure TLibraryForm.dwTerminate;
var
  PS:TLibDwStatus;
  S:String;
begin
  PS:=LibDwStatus;
  LibDwStatus:=Idle;
  case PS of
    GetBase: EndGetBase;
    GetLibrary: EndGetLibrary;
    GetPrograms: EndGetPrograms;
    GetSnippets: EndGetSnippets;
  end;
  WriteStr(S,PS);
  Info('TLibraryForm.dwTerminate',S);
end;

function TLibraryForm.Md2Html(fi:string):string;
var
  md:TMarkdownProcessor=nil;
  fo,fn:string;
  html:TStringList;
begin
  result:=fi;
  fo:=extractFilePath(fi);
  fn:=extractFileNameOnly(fi)+'.html';
  try
    html := TStringList.Create;
    md := TMarkdownProcessor.createDialect(mdCommonMark);
    md.UnSafe := false;
    md.config.codeBlockEmitter:=TCodeEmiter.Create;
    fo:=IfThen(DirectoryIsWritable(fo),fo+fn,GetTempDir+fn);
    try
      html.Text := md.processFile(fi);
      if html.Text<>'' then
      begin
        html.Text:=CSSDecoration+html.Text;
        html.SaveToFile(fo);
        result:=fo;
      end;
    except
      ShowMessage('Can not create or process the temp html file');
    end;
  finally
    if assigned(md) then md.Free;
    if assigned(html) then html.Free;
  end;
end;

function TLibraryForm.Md2Html(s, fi: string): string;
var
  md:TMarkdownProcessor=nil;
  fo,fn:string;
  html:TStringList;
begin
  result:='';
  fn:=extractFileNameOnly(fi)+'.tmd.html';
  fo:=extractFilePath(fi);
  fo:=IfThen(DirectoryIsWritable(fo),fo+fn,TempFolder+fn);
  try
    html := TStringList.Create;
    md := TMarkdownProcessor.createDialect(mdCommonMark);
    md.UnSafe := false;
    md.config.codeBlockEmitter:=TCodeEmiter.Create;
    try
      html.Text := md.process(s);
      if html.Text<>'' then
      begin
        html.Text:=CSSDecoration+html.Text;
        html.SaveToFile(fo);
        result:=fo;
      end;
    except
      ShowMessage('Can not create or process the temp html file: '+fo);
    end;
  finally
    if assigned(md) then md.Free;
    if assigned(html) then html.Free;
  end;
end;

procedure TLibraryForm.OpenDataSheet(f:string);
var
  ftype:string;
begin
  ftype:=ExtractFileExt(f);
  case lowerCase(ftype) of
    '.markdown','.mdown','.mkdn',
    '.md','.mkd','.mdwn',
    '.mdtxt','.mdtext','.text',
    '.rmd':
      begin
        OpenURL(Md2Html(f));
      end;
    '.htm','.html':OpenURL(f);
  else
    OpenDocument(f);
  end;
end;

end.

