{$I codegen.inc}
unit umain;

interface

uses
  Classes, SysUtils, Math, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ActnList, Menus, ComCtrls, StdActns, uEditor, LCLType, Clipbrd,
  StdCtrls, ExtCtrls, SynEditTypes, PrintersDlgs, Config, SupportFuncs,
  LazUtils, LazUTF8, uDglGoTo, SynEditPrint, simplemrumanager, SynEditLines,
  SynEdit, SynEditKeyCmds, SynCompletion, SynHighlighterCpp, replacedialog,
  lclintf, jsontools, LMessages, PairSplitter, Buttons, uCmdBox, RichMemo,
  UniqueInstance, Process, uinfo, ucmdboxthread, SynHighlighterPas,
  SynExportHTML, udirectoryname, ushowlspmessage, usettings, HtmlView,
  MarkdownProcessor, MarkdownUtils, fpjson, jsonparser, md5, uai
  {$IFDEF LCLGTK2},Gtk2{$ENDIF}
  ;

type

  { TfMain }

  TSaveMode = (smText, smRTF, smHTML);

  TFileTreeNode = class ( TTreeNode)
    public
      FullPath: string;
      isDir:    boolean;
  end;

  TfMain = class(TForm)
    actFont: TAction;
    actFullNameToClipBoard: TAction;
    actGoTo: TAction;
    actCloseAllExceptThis: TAction;
    actCloseBefore: TAction;
    actCloseAfter: TAction;
    actFindLongestLine: TAction;
    actFullScreen: TAction;
    actFileNameToClipboard: TAction;
    actCompileRun: TAction;
    actFolderNew: TAction;
    actCopyFile: TAction;
    actCutFile: TAction;
    actCompileStop: TAction;
    actBookmarkAdd: TAction;
    actBookmarkDel: TAction;
    actAI: TAction;
    actWordWrap: TAction;
    actToggleOllamaChat: TAction;
    actPreview: TAction;
    actPasteImage: TAction;
    actRestart: TAction;
    actToggleMessageBox: TAction;
    actOpenExtern: TAction;
    actPasteFile: TAction;
    actOpenProperties: TAction;
    actOpenInHexEditor: TAction;
    actUnQuote: TAction;
    FileBrowseFolder: TAction;
    FileCloseFolder: TAction;
    FileReloadFolder: TAction;
    FileOpenFolder: TAction;
    actShowRowNumber: TAction;
    actShowToolbar: TAction;
    actJSONCompact: TAction;
    actZoomIn: TAction;
    actZoomOut: TAction;
    actZoomReset: TAction;
    actToggleSpecialChar: TAction;
    FileReload: TAction;
    actPathToClipboard: TAction;
    actSQLPrettyPrint: TAction;
    actXMLCompact: TAction;
    actJSONPrettyPrint: TAction;
    actQuote: TAction;
    actLanguageNone: TAction;
    actXMLPrettyPrint: TAction;
    actTabToSpace: TAction;
    actUpperCase: TAction;
    actLowerCase: TAction;
    FilesTree: TTreeView;
    imgListFileIcons: TImageList;
    imgListSmall: TImageList;
    MenuItem100: TMenuItem;
    MenuItem101: TMenuItem;
    MenuItem102: TMenuItem;
    MenuItem103: TMenuItem;
    MenuItem104: TMenuItem;
    MenuItem105: TMenuItem;
    MenuItem106: TMenuItem;
    MenuItem107: TMenuItem;
    MenuItem108: TMenuItem;
    MenuItem109: TMenuItem;
    miToggleOllamaChat: TMenuItem;
    miPasteImage: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    MenuItem75: TMenuItem;
    MenuItem76: TMenuItem;
    miBookmarkAdd: TMenuItem;
    miBookmarkDel: TMenuItem;
    miBookmarks: TMenuItem;
    MIMessageBox: TMenuItem;
    MenuItem84: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem86: TMenuItem;
    MenuItem87: TMenuItem;
    MenuItem88: TMenuItem;
    MenuItem89: TMenuItem;
    MenuItem90: TMenuItem;
    MIShotSpecialChar: TMenuItem;
    MenuItem53: TMenuItem;
    MenuItem54: TMenuItem;
    MenuItem55: TMenuItem;
    MenuItem56: TMenuItem;
    MenuItem57: TMenuItem;
    MenuItem58: TMenuItem;
    MenuItem59: TMenuItem;
    MenuItem60: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem77: TMenuItem;
    MenuItem78: TMenuItem;
    MenuItem79: TMenuItem;
    MenuItem80: TMenuItem;
    MenuItem81: TMenuItem;
    MenuItem82: TMenuItem;
    MenuItem83: TMenuItem;
    MenuItem95: TMenuItem;
    MenuItem96: TMenuItem;
    MenuItem97: TMenuItem;
    MenuItem98: TMenuItem;
    MenuItem99: TMenuItem;
    N5: TMenuItem;
    MenuItem94: TMenuItem;
    N4: TMenuItem;
    MenuItem91: TMenuItem;
    MenuItem92: TMenuItem;
    MenuItem93: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    mnuLineEndings: TMenuItem;
    mnuCRLF: TMenuItem;
    MenuItem67: TMenuItem;
    MenuItem68: TMenuItem;
    MenuItem69: TMenuItem;
    MenuItem70: TMenuItem;
    MenuItem71: TMenuItem;
    MenuItem72: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    mnuLF: TMenuItem;
    mnuCR: TMenuItem;
    mnuNone: TMenuItem;
    mnuLanguage: TMenuItem;
    mnuTabs: TMenuItem;
    PairSplitter1: TPairSplitter;
    PairSplitter2: TPairSplitter;
    PairSplitter3: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide3: TPairSplitterSide;
    PairSplitterSide4: TPairSplitterSide;
    PSSEditor: TPairSplitterSide;
    PSSMessageBox: TPairSplitterSide;
    pumFileTree: TPopupMenu;
    PairSplitterSide2: TPairSplitterSide;
    pumTabs: TPopupMenu;
    PrintDialog1: TPrintDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    Separator3: TMenuItem;
    Separator4: TMenuItem;
    Separator5: TMenuItem;
    Separator6: TMenuItem;
    Separator7: TMenuItem;
    SortAscending: TAction;
    actPrint: TAction;
    SortDescending: TAction;
    FileSaveAll: TAction;
    actTrimTrailing: TAction;
    actTrim: TAction;
    ActCompressSpaces: TAction;
    actTrimLeading: TAction;
    AppProperties: TApplicationProperties;
    FileCloseAll: TAction;
    FileSave: TAction;
    FileExit: TAction;
    FontDialog: TFontDialog;
    HelpAbout: TAction;
    FileClose: TAction;
    FileNew: TAction;
    EditRedo: TAction;
    ActionList: TActionList;
    EditCopy: TEditCopy;
    EditCut: TEditCut;
    EditDelete: TEditDelete;
    EditPaste: TEditPaste;
    EditSelectAll: TEditSelectAll;
    EditUndo: TEditUndo;
    FileOpen: TFileOpen;
    FileSaveAs: TFileSaveAs;
    imgListBig: TImageList;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    mnuCleanRecent: TMenuItem;
    mnuReopenAllRecent: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    mnuOpenRecent: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mnuMain: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    pumEdit: TPopupMenu;
    SaveDialog: TSaveDialog;
    SearchFind: TAction;
    SearchFindPrevious: TAction;
    SearchFindNext: TAction;
    SearchReplace: TAction;
    splLeftBar: TSplitter;
    StatusBar: TStatusBar;
    MainToolbar: TToolBar;
    SynExporterHTML1: TSynExporterHTML;
    Timer1: TTimer;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    TBCompileStop: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    TBCompileRun: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton2: TToolButton;
    ToolButton20: TToolButton;
    ToolButton3: TToolButton;
    tbbClose: TToolButton;
    tbbCloseAll: TToolButton;
    tbbSepClose: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    Bookmarks: TStringList;
    UniqueInstance1: TUniqueInstance;
    procedure actAIExecute(Sender: TObject);
    procedure actBookmarkAddExecute(Sender: TObject);
    procedure actBookmarkDelExecute(Sender: TObject);
    procedure actCompileStopExecute(Sender: TObject);
    procedure actFolderNewExecute(Sender: TObject);
    procedure actCloseAfterExecute(Sender: TObject);
    procedure actCloseAllExceptThisExecute(Sender: TObject);
    procedure actCloseBeforeExecute(Sender: TObject);
    procedure ActCompressSpacesExecute(Sender: TObject);
    procedure actCopyFileExecute(Sender: TObject);
    procedure actCutFileExecute(Sender: TObject);
    procedure actFileNameToClipboardExecute(Sender: TObject);
    procedure actFindLongestLineExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure actFullNameToClipBoardExecute(Sender: TObject);
    procedure actFullScreenExecute(Sender: TObject);
    procedure actGoToExecute(Sender: TObject);
    procedure actCompileRunExecute(Sender: TObject);
    procedure actJSONCompactExecute(Sender: TObject);
    procedure ActionListUpdate(AAction: TBasicAction; var Handled: boolean);
    procedure actJSONPrettyPrintExecute(Sender: TObject);
    procedure actJumpFileTreeExecute(Sender: TObject);
    procedure actLanguageNoneExecute(Sender: TObject);
    procedure actOpenExternExecute(Sender: TObject);
    procedure actOpenInHexEditorExecute(Sender: TObject);
    procedure actOpenPropertiesExecute(Sender: TObject);
    procedure actPasteFileExecute(Sender: TObject);
    procedure actPasteImageExecute(Sender: TObject);
    procedure actPathToClipboardExecute(Sender: TObject);
    procedure actPreviewExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actQuoteExecute(Sender: TObject);
    procedure actRestartExecute(Sender: TObject);
    procedure actToggleMessageBoxExecute(Sender: TObject);
    procedure actToggleOllamaChatExecute(Sender: TObject);
    procedure actUnQuoteExecute(Sender: TObject);
    procedure actWordWrapExecute(Sender: TObject);
    procedure EditDeleteExecute(Sender: TObject);
    procedure FileBrowseFolderExecute(Sender: TObject);
    procedure FileCloseFolderExecute(Sender: TObject);
    procedure FileReloadFolderExecute(Sender: TObject);
    procedure actShowRowNumberExecute(Sender: TObject);
    procedure actShowToolbarExecute(Sender: TObject);
    procedure actSQLPrettyPrintExecute(Sender: TObject);
    procedure actTabToSpaceExecute(Sender: TObject);
    procedure actToggleSpecialCharExecute(Sender: TObject);
    procedure actTrimExecute(Sender: TObject);
    procedure actTrimLeadingExecute(Sender: TObject);
    procedure actTrimTrailingExecute(Sender: TObject);
    procedure actXMLCompactExecute(Sender: TObject);
    procedure actXMLPrettyPrintExecute(Sender: TObject);
    procedure actZoomInExecute(Sender: TObject);
    procedure actZoomOutExecute(Sender: TObject);
    procedure actZoomResetExecute(Sender: TObject);
    procedure AppPropertiesActivate(Sender: TObject);
    procedure AppPropertiesDropFiles(Sender: TObject; const FileNames: array of String);
    procedure EditCopyExecute(Sender: TObject);
    procedure EditCutExecute(Sender: TObject);
    procedure EditPasteExecute(Sender: TObject);
    procedure EditRedoExecute(Sender: TObject);
    procedure EditSelectAllExecute(Sender: TObject);
    procedure FileCloseAllExecute(Sender: TObject);
    procedure FileCloseExecute(Sender: TObject);
    procedure FileExitExecute(Sender: TObject);
    procedure FileNewExecute(Sender: TObject);
    procedure FileOpenAccept(Sender: TObject);
    procedure FileOpenBeforeExecute(Sender: TObject);
    procedure FileOpenFolderExecute(Sender: TObject);
    procedure FileReloadExecute(Sender: TObject);
    procedure FileSaveAsAccept(Sender: TObject);
    procedure FileSaveExecute(Sender: TObject);
    procedure FilesTreeCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure FilesTreeDblClick(Sender: TObject);
    procedure FilesTreeExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure FilesTreeGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure FilesTreeGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure FilesTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FilesTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FilesTreeSelectionChanged(Sender: TObject);
    procedure FindDialogClose(Sender: TObject; var CloseAction:TCloseAction);
    procedure FontDialogApplyClicked(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormKeyPressDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure actLowerCaseExecute(Sender: TObject);
    procedure mnuCleanRecentClick(Sender: TObject);
    procedure mnuReopenAllRecentClick(Sender: TObject);
    procedure mnuLineEndingsClick(Sender: TObject);
    procedure mnuCRClick(Sender: TObject);
    procedure mnuCRLFClick(Sender: TObject);
    procedure mnuLFClick(Sender: TObject);
    procedure mnuTabsClick(Sender: TObject);
    procedure ReplaceDialogFind(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);
    procedure SearchFindAccept(Sender: TObject);
    procedure SearchFindExecute(Sender: TObject);
    procedure SearchFindNextExecute(Sender: TObject);
    procedure SearchFindPreviousExecute(Sender: TObject);
    procedure SearchReplaceExecute(Sender: TObject);
    procedure SortAscendingExecute(Sender: TObject);
    procedure SortDescendingExecute(Sender: TObject);
    procedure actUpperCaseExecute(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CliParams(aParams: TStringList);
    procedure DoOnBookmarkClick(Sender: TObject);
    procedure UniqueInstance1OtherInstance(Sender: TObject;
      ParamCount: Integer; const Parameters: array of String);
    function GetSelectedFileTreePath:String;
  private
    EditorFactory: TEditorFactory;
    MRU: TMRUMenuManager;
    FindText, ReplaceText: string;
    FileToCopy: TFileTreeNode;
    MoveFile: Boolean;
    SynOption: TMySynSearchOptions;
    prn: TSynEditPrint;
    ReplaceDialog: TCustomReplaceDialog;
    rect: TRect;
    ws : TWindowState;
    BrowsingPath: string;
    EditorSplitterPos: Integer;
    CompileRun: TProcess;

    function AskFileName(Editor: TEditor): boolean;
    procedure ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);

    function EditorAvalaible: boolean; inline;
    function GetCurrentGitBranchFromHead: string;
    procedure BeforeCloseEditor(Editor: TEditor; var Cancel: boolean);
    procedure ExpandNode(NodeDir: TFileTreeNode; const Path: string);
    procedure LoadDir(Path: string);
    procedure mnuLangClick(Sender: TObject);
    procedure mnuThemeClick(Sender: TObject);
    procedure EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure RecentFileEvent(Sender: TObject; const AFileName: string; const AData: TObject);
    procedure NewEditor(Editor: TEditor);
    procedure ShowTabs(Sender: TObject);
  public
    { public declarations }
  end;

var
  fMain: TfMain;


implementation

uses lclproc, Stringcostants, SynEditExport;

{$R *.lfm}

const
  IDX_IMG_MODIFIED = 3;
  IDX_IMG_STANDARD = 13;

{ TfMain }

procedure TfMain.FileExitExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfMain.FileCloseExecute(Sender: TObject);
begin
  if EditorAvalaible then
    EditorFactory.CloseEditor(EditorFactory.CurrentEditor);
end;

procedure TfMain.EditRedoExecute(Sender: TObject);
begin
  if EditorAvalaible then
    EditorFactory.CurrentEditor.Redo;
end;

procedure TfMain.EditSelectAllExecute(Sender: TObject);
begin
   SendMessage (GetFocus, LM_CHAR, VK_CONTROL+VK_A, 0);
end;

procedure TfMain.EditCopyExecute(Sender: TObject);
begin
  SendMessage (GetFocus, LM_COPY, 0, 0);
end;

procedure TfMain.EditCutExecute(Sender: TObject);
begin
  SendMessage (GetFocus, LM_CUT, 0, 0);
end;

procedure TfMain.EditPasteExecute(Sender: TObject);
begin
  SendMessage (GetFocus, LM_Paste, 0, 0);
end;

procedure TfMain.ContextPopup(Sender: TObject; MousePos: TPoint;var Handled: Boolean);
begin
  if not EditorAvalaible then
    exit;

  EditorFactory.ActivePageIndex := EditorFactory.IndexOfTabAt(MousePos);

  if EditorFactory.ActivePageIndex > -1 then
    begin
      Handled:=true;
      MousePos:=EditorFactory.ClientToScreen(MousePos);
      pumTabs.PopupComponent:=EditorFactory.CurrentEditor;
      pumTabs.PopUp(MousePos.X,MousePos.Y);
    end;

end;

procedure TfMain.ActionListUpdate(AAction: TBasicAction; var Handled: boolean);
var
  Avail: boolean;
  ed: TEditor;
begin
  Avail := EditorAvalaible;
  Ed := EditorFactory.CurrentEditor;
  EditRedo.Enabled := Avail and Ed.CanRedo;
  EditUndo.Enabled := Avail and Ed.CanUndo;
  FileSave.Enabled := Avail and Ed.Modified;
  FileReload.Enabled := Avail and not Ed.Untitled;
  EditCopy.Enabled := Avail and ed.SelAvail;
  EditCut.Enabled := Avail and ed.SelAvail;
  actFullNameToClipBoard.Enabled := Avail and not ed.Untitled;
  actFileNameToClipboard.Enabled := Avail and not ed.Untitled;
  actPathToClipboard.Enabled := Avail and not ed.Untitled;
  FileBrowseFolder.Enabled := Avail and not ed.Untitled;
  actGoTo.Enabled := Avail and (ed.Lines.Count > 0);
  actCloseAfter.Enabled := EditorFactory.PageCount > EditorFactory.PageIndex;
  actCloseBefore.Enabled := EditorFactory.PageIndex > 0;

  Handled := True;
end;

procedure TfMain.actJSONPrettyPrintExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@FormatJSON, [tomFullText]);
  Ed.Highlighter := ConfigObj.getHighLighter('.json');
end;

procedure TfMain.actJumpFileTreeExecute(Sender: TObject);
begin

end;

procedure TfMain.actLanguageNoneExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.Highlighter := nil;
end;

procedure TfMain.actOpenExternExecute(Sender: TObject);
var Node: TFileTreeNode;
begin
  if not Assigned(FilesTree.Selected) then
    Exit;

  Node := TFileTreeNode(FilesTree.Selected);
  if not Assigned(Node) then
     Exit;

  if Node.isDir then
    Exit;

  if FileExists(Node.FullPath) then
    OpenDocument(Node.FullPath);
end;

procedure TfMain.actOpenInHexEditorExecute(Sender: TObject);
var
  run: TProcess;
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;

  run := TProcess.Create(nil);
  try
    run.Executable := ConfigObj.HexEditor;
    run.Parameters.Add(Ed.FileName);
    run.CurrentDirectory := BrowsingPath;

    run.Options := [poNoConsole, poNewProcessGroup];
    run.Execute;
  except
    run.Free;
  end;
end;

procedure TfMain.actOpenPropertiesExecute(Sender: TObject);
begin
  FSettings.Show;
end;



procedure TfMain.actPathToClipboardExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  Ed := EditorFactory.CurrentEditor;
  Clipboard.AsText := ExtractFilePath(Ed.FileName);
end;

procedure TfMain.actPreviewExecute(Sender: TObject);
var Ed, Preview: TEditor;
    Exporter: TSynCustomExporter;
    HtmlStream: TStringStream;
    markdown: TMarkdownProcessor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;

  Exporter := SynExporterHTML1;
  Exporter.Highlighter := Ed.Highlighter;
  HtmlStream := TStringStream.Create('');

  Exporter.ExportAll(Ed.Lines);
  Exporter.SaveToStream(HtmlStream);

  Preview := EditorFactory.AddEditor();
  Preview.Visible := True;
  Preview.Sheet.Preview := THtmlViewer.Create(Preview.Sheet);
  Preview.Sheet.Preview.Visible := True;
  Preview.Sheet.Preview.Enabled := True;
  Preview.Sheet.Preview.Align := alClient;
  Preview.Sheet.Preview.Parent := Preview.Sheet;
  Preview.Sheet.Preview.LoadFromString(HtmlStream.DataString);

  if LowerCase(Ed.Highlighter.GetLanguageName()) = 'markdown' then
  begin
    markdown := TMarkdownProcessor.createDialect(mdCommonMark);
    Preview.Sheet.Preview.LoadFromString(markdown.Process(HtmlStream.DataString));
  end
  else
    Preview.Sheet.Preview.LoadFromString(HtmlStream.DataString);
end;

procedure TfMain.actPrintExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  Ed := EditorFactory.CurrentEditor;
  prn.SynEdit := Ed;
  if PrintDialog1.Execute then
    prn.Print;
end;

procedure TfMain.actQuoteExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@QuotedStr, [tomLines]);
end;

procedure TfMain.actRestartExecute(Sender: TObject);
var
  Process: TProcess;
begin
  Process := TProcess.Create(nil);
  try
    Process.Executable := ParamStr(0);
    Process.Execute;
    Halt(0);
  finally
    Process.Free;
  end;
end;

procedure TfMain.actToggleMessageBoxExecute(Sender: TObject);
begin
  actToggleMessageBox.Checked := not actToggleMessageBox.Checked;
  MIMessageBox.Checked := actToggleMessageBox.Checked;

  if not Assigned(EditorFactory.CurrentMessageBox) then
    Exit;

  if actToggleMessageBox.Checked then
  begin
    EditorFactory.CurrentMessageBox.Visible := True;
    PairSplitter2.Position := PairSplitterSide2.Height - 250;
    EditorSplitterPos := 250;
  end
  else
  begin
    EditorFactory.CurrentMessageBox.Visible := False;
    PairSplitter2.Position := PairSplitterSide2.Height;
    EditorSplitterPos := 0;
  end
end;

procedure TfMain.actToggleOllamaChatExecute(Sender: TObject);
begin
  actToggleOllamaChat.Checked := not actToggleOllamaChat.Checked;
  miToggleOllamaChat.Checked := actToggleOllamaChat.Checked;

  if actToggleOllamaChat.Checked then
    PairSplitter3.Position := PairSplitter3.Position - 400
  else
    PairSplitter3.Position := Width - PairSplitterSide1.Width - 10;
end;

function ExtractQuotedStr(const S: string): string;
var tmp : pchar ;
begin
tmp:= pchar(trim(s));
result := AnsiExtractQuotedStr(tmp,'''');
end ;

procedure TfMain.actUnQuoteExecute(Sender: TObject);
var
  Ed: TEditor;

begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@ExtractQuotedStr, [tomLines]);
end;

procedure TfMain.EditDeleteExecute(Sender: TObject);
var Path: String;
    Node: TFileTreeNode;
    i: Integer;
begin
  if FilesTree.Selected = nil then
    Exit;

  Node := TFileTreeNode(FilesTree.Selected);

  Path := GetSelectedFileTreePath;

  // Delete Directory
  if Node.IsDir then
  begin
    ShowMessage('Delete a directory is not supported');
    Exit;
  end;

  // Delete File
  if MessageDlg('Sure you want delete this file?', mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
  begin
    if FileExists(Path) then
    begin
      for i := 0 to EditorFactory.PageCount - 1 do
      begin
        if TEditorTabSheet(EditorFactory.Pages[i]).Editor.FileName = Path then
        begin
          EditorFactory.CloseEditor(TEditorTabSheet(EditorFactory.Pages[i]).Editor);
          Break;
        end
      end;

      if DeleteFile(Path) then
          Node.Delete
      else
        ShowMessage('Could not delete file.');
    end
    else
      ShowMessage('File does not exist.');
  end;
end;

function TfMain.GetSelectedFileTreePath:String;
var
  Node: TTreeNode;
  Path: string;
begin
  Result := '';
  if FilesTree.Selected = nil then
    Exit;

  Node := FilesTree.Selected;
  Path := Node.Text;

  while Node.Parent <> nil do
  begin
    Node := Node.Parent;
    Path := Node.Text + PathDelim + Path;
  end;

  Result := BrowsingPath+PathDelim+Path;
end;

procedure TfMain.UniqueInstance1OtherInstance(Sender: TObject;
  ParamCount: Integer; const Parameters: array of String);
var str, dir: String;
   Editor: TEditor;
begin
  if ParamCount > 0 then
  begin
    str := Parameters[0];
    if DirectoryExists(str) then
    begin
      dir := str;
      if dir = '.' then
        dir := GetCurrentDir;
      LoadDir(dir)
    end
    else
    begin
      Editor := EditorFactory.AddEditor(str);
      if Assigned(Editor) then
      begin
        Editor.FilePath := ExtractFilePath(str);
        if Length(Editor.FilePath) <= 0 then
          Editor.FilePath := GetCurrentDir;
      end;
    end;
  end;
end;


procedure TfMain.FileBrowseFolderExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  LoadDir(ExtractFileDir(Ed.FileName));
end;

procedure TfMain.FileCloseFolderExecute(Sender: TObject);
begin
  splLeftBar.Visible := false;
end;

procedure TfMain.FileReloadFolderExecute(Sender: TObject);
begin
  LoadDir(BrowsingPath);
end;

procedure TfMain.actShowRowNumberExecute(Sender: TObject);
var
  i: Integer;
begin
  actShowRowNumber.Checked := not actShowRowNumber.Checked;

  for i := 0 to EditorFactory.PageCount - 1 do
    TEditorTabSheet(EditorFactory.Pages[i]).Editor.Gutter.Visible := actShowRowNumber.Checked;

  ConfigObj.ShowRowNumber:=actShowRowNumber.Checked;
end;

procedure TfMain.actShowToolbarExecute(Sender: TObject);
begin
  actShowToolbar.Checked := not actShowToolbar.Checked;
  ConfigObj.ShowToolbar := actShowToolbar.Checked;
  MainToolbar.Visible := ConfigObj.ShowToolbar;
end;

procedure TfMain.actWordWrapExecute(Sender: TObject);
var Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@WordWrapText, [tomFullText]);
end;


procedure TfMain.actFileNameToClipboardExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  Ed := EditorFactory.CurrentEditor;
  Clipboard.AsText := ExtractFileName(Ed.FileName);
end;

procedure TfMain.actSQLPrettyPrintExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@FormatSQL, [tomFullText]);
  Ed.Highlighter := ConfigObj.getHighLighter('.sql');
end;

procedure TfMain.actTabToSpaceExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@TabsToSpace);
end;

procedure TfMain.actToggleSpecialCharExecute(Sender: TObject);
begin
  actToggleSpecialChar.Checked := not actToggleSpecialChar.Checked;
  EditorFactory.ChangeOptions(eoShowSpecialChars, actToggleSpecialChar.Checked);
  MIShotSpecialChar.Checked := actToggleSpecialChar.Checked;
  ConfigObj.ShowSpecialChars := actToggleSpecialChar.Checked;
end;

procedure TfMain.actTrimExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@Trim);

end;

procedure TfMain.actTrimLeadingExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@TrimLeft);

end;

procedure TfMain.actTrimTrailingExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@TrimRight);

end;

procedure TfMain.actXMLCompactExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@CompactXML, [tomFullText]);
end;

procedure TfMain.actXMLPrettyPrintExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@FormatXML, [tomFullText]);
  Ed.Highlighter := ConfigObj.getHighLighter('.xml');
end;

procedure TfMain.actZoomInExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.ExecuteCommand(ecZoomIn,#0,nil);

end;

procedure TfMain.actZoomOutExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.ExecuteCommand(ecZoomout,#0,nil);

end;

procedure TfMain.actZoomResetExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.ExecuteCommand(ecZoomNorm,#0,nil);

end;


procedure TfMain.AppPropertiesActivate(Sender: TObject);
begin
  EditorFactory.DoCheckFileChanges;
end;

procedure TfMain.AppPropertiesDropFiles(Sender: TObject; const FileNames: array of String);
var
  i :Integer;
begin
  for i:= Low(FileNames) to High(FileNames) do
    EditorFactory.AddEditor(FileNames[i])
end;

procedure TfMain.actFontExecute(Sender: TObject);
var
  i: integer;
begin
  if Assigned(ConfigObj.Font) then
    FontDialog.Font.Assign(ConfigObj.Font);
  if FontDialog.Execute then
  begin
    for i := 0 to EditorFactory.PageCount - 1 do
      TEditorTabSheet(EditorFactory.Pages[i]).Editor.Font.Assign(FontDialog.Font);
    ConfigObj.Font.Assign(FontDialog.Font);
    ConfigObj.Dirty := true;
  end;
end;

procedure TfMain.actFullNameToClipBoardExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  Ed := EditorFactory.CurrentEditor;
  Clipboard.AsText := Ed.FileName;
end;

procedure TfMain.actFullScreenExecute(Sender: TObject);
begin

  if WindowState <> wsFullScreen then
  begin
    ws := WindowState;
    rect := BoundsRect;
    MainToolbar.Visible := false;
    Menu:= nil;
    {$IFDEF WINDOWS}
    BorderStyle := bsNone;
    {$ENDIF}
    WindowState:=wsFullScreen;
    Application.ProcessMessages;
    WindowState:=wsFullScreen;
  end
  else
  begin
    MainToolbar.Visible := true;
    Menu:= mnuMain;
    {$IFDEF WINDOWS}
    BorderStyle := bsSizeable;
    {$ENDIF}
    WindowState:= ws;
    BoundsRect := rect;

  end;
end;

procedure TfMain.actGoToExecute(Sender: TObject);
begin
  with TdlgGoTo.Create(Self) do
  begin
    Editor := EditorFactory.CurrentEditor;
    ShowModal;
    Free;
  end;

end;

procedure TfMain.actCompileRunExecute(Sender: TObject);
var CmdBox: TCmdBox;
    i: Integer;
begin
  if not EditorAvalaible then
    exit;

  if not Assigned(EditorFactory.CurrentCmdBox) then
    Exit;

  if not Assigned(EditorFactory.CurrentCmdBoxThread) then
    Exit;

  CmdBox := EditorFactory.CurrentCmdBox;

  MIMessageBox.Checked := True;
  actToggleMessageBox.Checked := True;
  if EditorSplitterPos = 0 then
  begin
    PairSplitter2.Position := PairSplitterSide2.Height - 250;
    EditorSplitterPos := 250;
  end;

  CompileRun := TProcess.Create(nil);
  try
    CompileRun.Executable := ConfigObj.CompileCommand;
    CmdBox.font := ConfigObj.Font;

    CompileRun.CurrentDirectory := BrowsingPath;

    for i := 0 to GetEnvironmentVariableCount - 1 do
    begin
      CMDBox.Writeln(GetEnvironmentString(i));
      CompileRun.Environment.Add(GetEnvironmentString(i));
    end;

    CmdBox.Writeln(#13#10#27'[32m'+'>>>' + CompileRun.Executable + '<<<'+#27'[0m'#13#10);

    CompileRun.Options := [poUsePipes, poStderrToOutPut];
    CompileRun.Execute;

    EditorFactory.CurrentCmdBoxThread := TCmdBoxThread.Create;
    EditorFactory.CurrentCmdBoxThread.Command := CompileRun;
    EditorFactory.CurrentCmdBoxThread.Start;
    TBCompileStop.Enabled := True;
    TBCompileRun.Enabled := False;
  except
    CompileRun.Free;
  end;
end;

procedure TfMain.actJSONCompactExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@CompactJson, [tomFullText]);
end;

procedure TfMain.ActCompressSpacesExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@RemoveSpacesInExcess);

end;

procedure TfMain.actPasteFileExecute(Sender: TObject);
var Node: TFileTreeNode;
begin
  if not Assigned(FileToCopy) then
    Exit;

  if not Assigned(FilesTree.Selected) then
  begin
    // copy to filetrees root directory
    if not CopyFile(FileToCopy.FullPath, BrowsingPath+PathDelim+ExtractFileName(FileToCopy.FullPath)) then
      ShowMessage('Could not copy file.');
    if MoveFile then
    begin
      if not DeleteFile(FileToCopy.FullPath) then
        ShowMessage('Could not delete file.');
    end;
    Node := TFileTreeNode(FilesTree.Items.AddChild(nil,ExtractFileName(FileToCopy.FullPath)));
    Node.FullPath := BrowsingPath+PathDelim+ExtractFileName(FileToCopy.FullPath);
    Node.isDir := False;
    Node.HasChildren := False;
  end
  else
  begin
    // copy into a subdirectory
    Node := TFileTreeNode(FilesTree.Selected);
    if not Assigned(Node) then
       Exit;

    if Node.isDir then
    begin
      if FileExists(FileToCopy.FullPath) then
      begin
        if not CopyFile(FileToCopy.FullPath, GetSelectedFileTreePath+PathDelim+ExtractFileName(FileToCopy.FullPath)) then
          ShowMessage('Could not copy file.');
        if MoveFile then
        begin
          if not DeleteFile(FileToCopy.FullPath) then
            ShowMessage('Could not delete file.');

          if Assigned(Node.Parent) then
          begin
            ExpandNode(TFileTreeNode(Node.Parent), ExtractFilePath(FileToCopy.FullPath));
            Node.Parent.Expand(false);
          end
          else
            FileReloadFolderExecute(Sender);
        end;
      end;

      Node.DeleteChildren;
      ExpandNode(Node, GetSelectedFileTreePath);
      Node.Expand(false);
    end;
  end;
  actPasteFile.Enabled := False;
  actCutFile.Enabled := False;
  MoveFile := False;
  FileToCopy := nil;
end;

procedure TfMain.actPasteImageExecute(Sender: TObject);
var Bitmap: TBitmap;
    SavePath, SaveName, FilePath: String;
    Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;

  if Clipboard.HasFormat(CF_Bitmap) then
  begin
    try
      Bitmap := TBitmap.Create;
      Bitmap.LoadFromClipboardFormat(CF_Bitmap);

      FilePath := BrowsingPath;
      if Length(Ed.FilePath) > 0 then
        FilePath := Ed.FilePath;

      SavePath := Format('%s%svx_images',[FilePath, PathDelim]);
      if not DirectoryExists(SavePath) then
        CreateDir(SavePath);

      SaveName := Format('clipboard_%s.bmp', [FormatDateTime('yyyymmddhhnnss', Now)]);
      SavePath := Format('%s%s%s', [SavePath, PathDelim, SaveName]);
      Bitmap.SaveToFile(SavePath);

      if Assigned(Ed.Highlighter) then
        if LowerCase(Ed.Highlighter.GetLanguageName()) = 'markdown' then
          Ed.InsertTextAtCaret(Format('![%s](vx_images%s%s)',[SaveName, PathDelim, SaveName]));
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;

  if Assigned(Bitmap) then
    Bitmap.Free;
end;

procedure TfMain.actCopyFileExecute(Sender: TObject);
var Node: TFileTreeNode;
begin
  if not Assigned(FilesTree.Selected) then
    Exit;

  Node := TFileTreeNode(FilesTree.Selected);
  if not Assigned(Node) then
     Exit;

  if Node.isDir then
    Exit;

  FileToCopy := Node;
  actPasteFile.Enabled := True;
end;

procedure TfMain.actCutFileExecute(Sender: TObject);
begin
  MoveFile := True;
  actCopyFileExecute(Sender);
end;

procedure TfMain.actFindLongestLineExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@RemoveSpacesInExcess);
end;

procedure TfMain.actCloseAllExceptThisExecute(Sender: TObject);
begin
  EditorFactory.CloseAll(true);
end;

procedure TfMain.actCloseAfterExecute(Sender: TObject);
begin
  EditorFactory.CloseAfter
end;

procedure TfMain.actFolderNewExecute(Sender: TObject);
var Path: String;
    CreateDirectory: TFCreateDirectory;
begin
  if not Assigned(FilesTree.Selected) then
    Exit;

  CreateDirectory := TFCreateDirectory.Create(Self);
  if CreateDirectory.ShowModal = mrOk then
  begin
    Path := ExtractFilePath(GetSelectedFileTreePath)+PathDelim+CreateDirectory.DirectoryName;
    if DirectoryExists(Path) then
    begin
      ShowMessage('Directory already exist');
    end
    else
    begin
      if CreateDir(Path) then
        LoadDir(BrowsingPath)
      else
        ShowMessage('Could not create directory');
    end;
  end;


end;

procedure TfMain.actCompileStopExecute(Sender: TObject);
begin
  if CompileRun.Running then
  begin
    CompileRun.Terminate(1);
    if Assigned(EditorFactory.CurrentCmdBox) then
      EditorFactory.CurrentCmdBox.Write(#13#10#27'[31m'+'>>Stop<<'+#27'[0m'#13#10);
    CompileRun.Free;
  end;
end;

procedure TfMain.actBookmarkAddExecute(Sender: TObject);
var i: Integer;
    found: Boolean;
    m: TMenuItem;
begin
  found := False;

  if not Assigned(Bookmarks) then
    Bookmarks := TStringList.Create;

  for i :=  0 to Bookmarks.Count -1 do
  begin
    if Bookmarks[i] = BrowsingPath then
      found := True;
  end;

  if not found then
  begin
    Bookmarks.Add(BrowsingPath);

    m := TMenuItem.Create(Self);
    m.OnClick:=@DoOnBookmarkClick;
    m.Caption:=BrowsingPath;

    miBookmarks.Add(m);

    ConfigObj.WriteStrings('Bookmarks', 'Item', Bookmarks);
  end;
end;

procedure TfMain.actAIExecute(Sender: TObject);
begin
  if not Assigned(EditorFactory.CurrentEditor) then
    Exit;

  fAI.Editor := EditorFactory.CurrentEditor;
  fAI.Show;
end;

procedure TfMain.actBookmarkDelExecute(Sender: TObject);
var i: Integer;
begin
  if not Assigned(Bookmarks) then
    Exit;

  for i :=  0 to Bookmarks.Count -1 do
  begin
    if Bookmarks[i] = BrowsingPath then
    begin
      miBookmarks.Delete(i);
      Bookmarks.Delete(i);
      Exit;
    end;
  end;
end;

procedure TfMain.DoOnBookmarkClick(Sender: TObject);
var bm: string;
begin
  with (Sender as TMenuItem) do
    bm:=Caption;

  if Length(bm) > 0 then
    LoadDir(bm);
end;

procedure TfMain.actCloseBeforeExecute(Sender: TObject);
begin
  EditorFactory.CloseBefore;
end;

procedure TfMain.FileCloseAllExecute(Sender: TObject);
begin
  EditorFactory.CloseAll;
end;

procedure TfMain.FileNewExecute(Sender: TObject);
begin
  EditorFactory.AddEditor();
end;

procedure TfMain.FileOpenAccept(Sender: TObject);
var
  i: integer;
begin

  for i := 0 to FileOpen.Dialog.Files.Count - 1 do
  begin
    EditorFactory.AddEditor(FileOpen.Dialog.Files[i], BrowsingPath);
    MRU.AddToRecent(FileOpen.Dialog.Files[i]);
  end;

end;

procedure TfMain.FileOpenBeforeExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  Ed := EditorFactory.CurrentEditor;
  if EditorAvalaible and (not Ed.Untitled) then
    FileOpen.Dialog.InitialDir := ExtractFilePath(Ed.FileName);

end;

procedure TfMain.FileOpenFolderExecute(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
    begin
      LoadDir(SelectDirectoryDialog1.FileName);
    end;
end;

procedure TfMain.FileReloadExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  Ed := EditorFactory.CurrentEditor;
  if Ed.Untitled then
    exit;

  if Ed.Modified then
    if MessageDlg(RSReload, Format(RSReloadFile, [ed.FileName]), mtConfirmation, [mbYes, mbNo], 0) = mrno then
      exit;

  ed.PushPos;
  ed.LoadFromFile(ed.FileName);
  ed.Modified := False;
  ed.PopPos;
end;

procedure TfMain.FileSaveAsAccept(Sender: TObject);
var
  Editor: TEditor;
begin
  Editor := EditorFactory.CurrentEditor;

  // if AskFileName(Editor) then

  Editor.SaveAs(FileSaveAs.Dialog.FileName);
  MRU.AddToRecent(FileSaveAs.Dialog.FileName);
  FileReloadFolderExecute(Sender);
end;

procedure TfMain.FileSaveExecute(Sender: TObject);
var
  Editor: TEditor;
begin
  Editor := EditorFactory.CurrentEditor;
  if Editor.Untitled then
  begin
    if not AskFileName(Editor) then
    begin
      Exit;
    end;
    FileReloadFolderExecute(Sender);
  end;
  Editor.Save;

  ConfigObj.WriteStrings('Recent', 'Files', MRU.Recent);
end;

procedure TfMain.FindDialogClose(Sender: TObject; var CloseAction:TCloseAction);
begin
  self.BringToFront;
end;

procedure TfMain.FontDialogApplyClicked(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to EditorFactory.PageCount - 1 do
    TEditorTabSheet(EditorFactory.Pages[i]).Editor.Font.Assign(FontDialog.Font);

  ConfigObj.Font.Assign(FontDialog.Font);
end;

procedure TfMain.FormActivate(Sender: TObject);
begin
  //ActionList.State := asNormal;
  if Assigned(EditorFactory) and assigned(EditorFactory.CurrentEditor) then
    EditorFactory.CurrentEditor.SetFocus;
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if Assigned(EditorFactory) and (EditorFactory.PageCount > 0) then
    CanClose := EditorFactory.CloseAll
  else
    CanClose := True;
end;

procedure TfMain.CliParams(aParams: TStringList);
var
  str, dir: string;
  Editor: TEditor;
begin
  for str in aParams do
  begin
    if copy(str, 1, 2) <> '--' then
    begin
      if DirectoryExists(str) then
      begin
        dir := str;
        if dir = '.' then
          dir := GetCurrentDir;
        LoadDir(dir)
      end
      else
      begin
        Editor := EditorFactory.AddEditor(str);
        if Assigned(Editor) then
        begin
          Editor.FilePath := ExtractFilePath(str);
          if Length(Editor.FilePath) <= 0 then
            Editor.FilePath := GetCurrentDir;

          LoadDir(Editor.FilePath);
          if Assigned(Editor) and not Editor.Untitled then
            MRU.AddToRecent(str);
        end;
      end;
    end;
  end;
  Application.BringToFront;
  ShowOnTop;
end;

procedure TfMain.FormCreate(Sender: TObject);
var i: integer;
    mnuBookmark, CurrMenu, mnuLang: TMenuItem;
    CurrLetter, SaveLetter: string;
    ParamList: TstringList;

begin
  MRU := TMRUMenuManager.Create(Self);
  MRU.MenuItem := mnuOpenRecent;
  MRU.OnRecentFile := @RecentFileEvent;
  MRU.MaxRecent := 15;
  MRU.Recent.Clear;

  Bookmarks := TStringList.Create;

  actShowRowNumber.Checked:=ConfigObj.ShowRowNumber;
  actShowToolbar.Checked:=ConfigObj.ShowToolbar;
  actToggleSpecialChar.Checked:=ConfigObj.ShowSpecialChars;

  ConfigObj.ReadStrings('Recent', 'Files', MRU.Recent);
  ConfigObj.ReadStrings('Bookmarks', 'Item', Bookmarks);

  for i :=  0 to Bookmarks.Count - 1do
  begin
    mnuBookmark := TMenuItem.Create(Self);
    mnuBookmark.Caption:=Bookmarks[i];
    mnuBookmark.OnClick:=@DoOnBookmarkClick;

    miBookmarks.Add(mnuBookmark);
  end;

  MRU.ShowRecentFiles;
  ReplaceDialog := TCustomReplaceDialog.Create(self);
  with ReplaceDialog do
    begin
      OnClose := @FindDialogClose;
//      Options := [ssoReplace, ssoEntireScope];
      OnFind := @ReplaceDialogFind;
      OnReplace := @ReplaceDialogReplace;
    end;

  EditorFactory := TEditorFactory.Create(Self);
  EditorFactory.Align := alClient;
  EditorFactory.OnStatusChange := @EditorStatusChange;
  EditorFactory.OnBeforeClose := @BeforeCloseEditor;
  EditorFactory.OnNewEditor := @NewEditor;
  EditorFactory.OnContextPopup := @ContextPopup;
  EditorFactory.Images := imgListBig;
  EditorFactory.Parent := PSSEditor;

  // Parameters
  FileOpen.Dialog.Filter := configobj.GetFiters;

  prn := TSynEditPrint.Create(Self);
  prn.Colors := True;

  SaveLetter := '';
  for i := 0 to HIGHLIGHTERCOUNT - 1 do
  begin
    mnuLang := TMenuItem.Create(Self);
    mnuLang.Caption := ARHighlighter[i].HLClass.GetLanguageName;
    mnuLang.Tag := i;
    mnuLang.OnClick := @mnuLangClick;
    CurrLetter := UpperCase(Copy(mnuLang.Caption, 1, 1));
    if SaveLetter <> CurrLetter then
    begin
      SaveLetter := CurrLetter;
      CurrMenu := TMenuItem.Create(Self);
      CurrMenu.Caption := CurrLetter;
      mnuLanguage.Add(CurrMenu);
    end;

    CurrMenu.Add(mnuLang);
  end;

  if (ParamCount <= 0) then
    LoadDir(GetCurrentDir);

  if (Length(ConfigObj.LastDirectory) > 0) and (ParamCount <= 0) then
    LoadDir(ConfigObj.LastDirectory);

  if ParamCount > 0  then
   try
     ParamList := TStringList.Create;
     for i := 1 to ParamCount do
       ParamList.Add(ParamStr(i));
   finally
     CliParams(ParamList);
     FreeAndNil(ParamList);
   end;

  if EditorFactory.PageCount = 0 then
    FileNew.Execute;

  splLeftBar.Visible := True;
  Font := Screen.SystemFont;
end;

procedure TfMain.mnuLangClick(Sender: TObject);
var
  idx: integer;
  Ed: TEditor;

begin
  idx := TMenuItem(Sender).Tag;

  if not EditorAvalaible then
    exit;

  try
    // Reloading highlighter for some files, for example big and complex XML files,
    // could be slow, better to give feedback to user
    Screen.Cursor := crHourGlass;
    Ed := EditorFactory.CurrentEditor;
    Ed.Highlighter := ConfigObj.getHighLighter(Idx);

  finally
    Screen.Cursor :=  crDefault;
  end;

end;

procedure TfMain.mnuThemeClick(Sender: TObject);
var
  idx: integer;
begin
  idx := TMenuItem(Sender).Tag;
  TMenuItem(Sender).Checked := true;
  try
    Screen.Cursor := crHourGlass;
    ConfigObj.SetTheme(idx);
    EditorFactory.ReloadHighLighters;
  finally
    Screen.Cursor :=  crDefault;
  end;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled := False;

  FreeAndNil(EditorFactory);
  ReplaceDialog.Free;
end;

procedure TfMain.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  i: integer;
begin
  for i := Low(FileNames) to High(FileNames) do
  begin
    EditorFactory.AddEditor(FileNames[i]);
    MRU.AddToRecent(FileNames[i]);
  end;
end;

procedure TfMain.FormKeyPressDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var Ed: TEditor;
    intKey: Integer;
begin
  if (Shift = [ssAlt]) and (Key in [VK_0..VK_9]) then
  begin
    if StrToInt(Char(Key)) <= EditorFactory.PageCount then
    begin
      intKey := StrToInt(Char(Key));
      if Key = VK_0 then
        intKey := 10;
      EditorFactory.PageIndex := intKey - 1;
    end;
  end;
  if (Shift = [ssAlt]) and (Key = VK_L) then
  begin
    actGoToExecute(Self);
  end;
  if (Shift = [ssShift]) and (Key = VK_TAB) then
  begin
    if not EditorAvalaible then
    begin
      FilesTree.SetFocus;
      Exit;
    end;

    Ed := EditorFactory.CurrentEditor;
    if Assigned(Ed) then
    begin
      if FilesTree.Focused then
      begin
        Ed.SetFocus;
      end
      else
        FilesTree.SetFocus;
    end;
  end;
  if (Key = VK_ESCAPE) and (FLSPMessage.Visible) then
    FLSPMessage.Close;
end;

procedure TfMain.FormResize(Sender: TObject);
begin
  ConfigObj.Dirty := true;

  if not EditorAvalaible then
    exit;

  if EditorSplitterPos = 0 then
    PairSplitter2.Position := PairSplitterSide2.Height
  else
    PairSplitter2.Position := PairSplitterSide2.Height - EditorSplitterPos;

  PairSplitter3.Position := Width - PairSplitterSide1.Width - 10;
end;

procedure TfMain.FormShow(Sender: TObject);
{$IFDEF LCLGTK2}
var GtkWidget: PGtkWidget;
{$ENDIF}
begin
  // workaround to set the correct window size und linux and gtk
  {$IFDEF LCLGTK2}
  GtkWidget := PGtkWidget(Handle);
  gtk_widget_size_request(GtkWidget, nil);
  {$ENDIF}
end;

procedure TfMain.FormWindowStateChange(Sender: TObject);
begin
  ConfigObj.Dirty := true;
end;

procedure TfMain.HelpAboutExecute(Sender: TObject);
begin
  TFInfo.Show;
end;

procedure TfMain.actUpperCaseExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@UpperCase);

end;

procedure TfMain.StatusBarResize(Sender: TObject);
var
  i: integer;
  pnlSize : integer;
begin
  pnlSize := 0;
  for i := 0 to StatusBar.Panels.Count - 1 do
    begin
      inc(pnlSize, StatusBar.Panels[i].Width);
    end;

  StatusBar.Panels[4].Width := max(4, StatusBar.Width - pnlSize - (StatusBar.BorderWidth * 2));
end;

procedure TfMain.Timer1Timer(Sender: TObject);
var LSPBox, CmdBox: TCmdBox;
    Line: String;
begin
  if not EditorAvalaible then
    Exit;

  if Assigned(ConfigObj) then
    ConfigObj.DoCheckFileChanges;

  if Assigned(CompileRun) then
    if not CompileRun.Running then
    begin
      TBCompileStop.Enabled := False;
      TBCompileRun.Enabled := True;
    end;

  if Length(EditorFactory.CurrentEditor.SelText) > 0 then
    FindText := EditorFactory.CurrentEditor.SelText;

  if Assigned(EditorFactory.CurrentMessageBox) then
  begin
    LSPBox := EditorFactory.CurrentLSPBox;
    if Assigned(LSPBox) then
    begin
      if Assigned(EditorFactory.CurrentLSP) then
      begin
        if Length(EditorFactory.CurrentLSP.OutputString) > 0 then
        begin
          LSPBox.Visible := True;
          EditorFactory.CurrentMessageBox.Visible := True;
          //if GetJSON(EditorFactory.CurrentLSP.OutputString).JSONType = jtObject then
          //begin
          //  ResponseJSON := TJSONObject(GetJSON(EditorFactory.CurrentLSP.OutputString));
          //  if Assigned(ResponseJSON.FindPath('source')) then
          //    LSPBox.Write(ResponseJSON.FindPath('source').AsString);
          //end;
          // Looks strange but we have to besure that all #CR's
          // are #CRLF
          Line := StringReplace(EditorFactory.CurrentLSP.OutputString, #10, #13#10, [rfReplaceAll]);
          LSPBox.Write(Line);
          EditorFactory.CurrentLSP.OutputString := '';
        end;
      end;
    end;

    CmdBox := EditorFactory.CurrentCmdBox;
    if Assigned(CmdBox) then
    begin
      if Assigned(EditorFactory.CurrentCmdBoxThread) then
      begin
        if Length(EditorFactory.CurrentCmdBoxThread.OutputString) > 0 then
        begin
          CmdBox.Visible := True;
          EditorFactory.CurrentMessageBox.Visible := True;
          // Looks strange but we have to besure that all #CR's
          // are #CRLF
          Line := StringReplace(EditorFactory.CurrentCmdBoxThread.OutputString, #10, #13#10, [rfReplaceAll]);
          CmdBox.Write(Line);
          EditorFactory.CurrentCmdBoxThread.OutputString := '';
        end;
      end;
    end;
  end;

  if Assigned(EditorFactory.CurrentLSP) then
  begin
    if Assigned(FLSPMessage) then
    begin
      if Length(EditorFactory.CurrentLSP.Message) > 0 then
      begin
        EditorFactory.CurrentLSP.Suspend;

        if FLSPMessage.Visible then
          FLSPMessage.Close;

        FLSPMessage.ShowOnTop;

        FLSPMessage.ShowMessage(EditorFactory.CurrentLSP.Message);
        EditorFactory.CurrentLSP.Message := '';
      end;

      if EditorFactory.CurrentLSP.MessageList.Count > 1 then
      begin
        EditorFactory.CurrentLSP.Suspend;

        FLSPMessage.ShowMessageList(EditorFactory.CurrentLSP.MessageList);

        if FLSPMessage.Visible then
          FLSPMessage.Close;

        if FLSPMessage.ShowModal = mrOk then
        begin
          EditorFactory.CurrentEditor.InsertTextAtCaret(FLSPMessage.LSPKey);
          FLSPMessage.LSPKey := '';
        end;
        EditorFactory.CurrentLSP.MessageList.Clear;
      end;
    end;
  end;
end;

procedure TfMain.actLowerCaseExecute(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  Ed.TextOperation(@LowerCase);

end;

procedure TfMain.mnuCleanRecentClick(Sender: TObject);
begin
  MRU.Recent.Clear;
  MRU.ShowRecentFiles;
  ConfigObj.WriteStrings('Recent', 'File', MRU.Recent);
end;

procedure TfMain.mnuReopenAllRecentClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to MRU.Recent.Count - 1 do
    EditorFactory.AddEditor(MRU.Recent[i]);

end;

procedure TfMain.mnuLineEndingsClick(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  case Ed.LineEndingType of
    sfleCrLf: mnuCRLF.Checked := true;
    sfleLf: mnuLF.Checked := true;
    sfleCr: mnuCR.Checked := true;
  end;
  mnuCR.Enabled := not mnuCR.Checked;
  mnuLF.Enabled := not mnuLF.Checked;
  mnuCRLF.Enabled := not mnuCRLF.Checked;

end;

procedure TfMain.mnuCRClick(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  ed.LineEndingType := sfleCr;

end;

procedure TfMain.mnuCRLFClick(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  ed.LineEndingType := sfleCrLf;
end;

procedure TfMain.mnuLFClick(Sender: TObject);
var
  Ed: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Ed := EditorFactory.CurrentEditor;
  ed.LineEndingType := sfleLf;
end;

procedure TfMain.ShowTabs(Sender: TObject);
begin
  EditorFactory.ActivePageIndex := (Sender as TMenuItem).Tag;
end;

procedure TfMain.mnuTabsClick(Sender: TObject);
var
  i: integer;
  mnuitem: TMenuItem;
begin
  mnuTabs.Clear;

  for i := 0 to EditorFactory.PageCount - 1 do
  begin
    mnuitem := TMenuItem.Create(mnuTabs);
    mnuitem.Caption := EditorFactory.Pages[i].Caption;
    mnuitem.Tag := i;
    mnuitem.OnClick := @ShowTabs;
    mnuTabs.Add(mnuitem);
  end;

end;

procedure TfMain.ReplaceDialogFind(Sender: TObject);
var
  ed: TEditor;
  Options : TMySynSearchOptions;
begin
  ed := EditorFactory.CurrentEditor;
  Options := ReplaceDialog.Options;
  Exclude(Options, ssoReplace);
  if ssoExtended in Options then
    FindText := DecodeExtendedSearch(ReplaceDialog.FindText)
  else
    FindText:= ReplaceDialog.FindText;

  if Ed.SearchReplace(FindText, '', TSynSearchOptions(Options)) = 0 then
    ShowMessage(Format(RSTextNotfound, [ReplaceDialog.FindText]))
end;

procedure TfMain.ReplaceDialogReplace(Sender: TObject);
var
  ed: TEditor;
  Options : TMySynSearchOptions;

begin

  ed := EditorFactory.CurrentEditor;
  Options := ReplaceDialog.Options;

  if ssoExtended in Options then
    begin
      FindText := DecodeExtendedSearch(ReplaceDialog.FindText);
      ReplaceText := DecodeExtendedSearch(ReplaceDialog.ReplaceText);
    end
  else
    begin
      FindText := ReplaceDialog.FindText;
      ReplaceText := ReplaceDialog.ReplaceText;
    end;

  if Ed.SearchReplace(FindText, ReplaceText, TSynSearchOptions(Options)) = 0 then
    ShowMessage(Format(RSTextNotfound, [ReplaceDialog.FindText]))
  else
  if (ssoReplace in Options) and not (ssoReplaceAll in Options) then
  begin
    Exclude(Options, ssoReplace);
    Ed.SearchReplace(FindText, '', TSynSearchOptions(Options));
  end;

  if Assigned(ed.OnSearchReplace) then
    ed.OnSearchReplace(Ed, ReplaceDialog.FindText, ReplaceDialog.ReplaceText, Options);

end;

procedure TfMain.SearchFindAccept(Sender: TObject);
begin
  if not EditorAvalaible then
    exit;

end;

function TfMain.GetCurrentGitBranchFromHead: string;
var HeadFile: string;
    HeadContent: TStringList;
begin
  Result := '';
  HeadFile := IncludeTrailingPathDelimiter(BrowsingPath) + '.git/HEAD';
  if not FileExists(HeadFile) then
    Exit;

  HeadContent := TStringList.Create;
  try
    HeadContent.LoadFromFile(HeadFile);
    if HeadContent.Count > 0 then
    begin
      if Pos('ref: ', HeadContent[0]) = 1 then
        Result := 'Git: ' + Copy(HeadContent[0], Length('ref: refs/heads/') + 1, MaxInt)
      else
        Result := 'Git: (detached HEAD)';
    end;
  finally
    HeadContent.Free;
  end;
end;


procedure TfMain.EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
var
  Editor: TEditor;
begin
  if not EditorAvalaible then
    exit;

  Editor := EditorFactory.CurrentEditor;

  if Assigned(Editor.Highlighter) then
    StatusBar.panels[0].Text := Editor.Highlighter.LanguageName
  else
    StatusBar.panels[0].Text := RSNormalText;

  StatusBar.panels[1].Text := GetCurrentGitBranchFromHead;

  if (scCaretX in Changes) or (scCaretY in Changes) then
    StatusBar.Panels[2].Text := Format(RSStatusBarPos, [Editor.CaretY, Editor.CaretX]);

  if Editor.SelAvail then
    StatusBar.Panels[3].Text := Format(RSStatusBarSel, [Editor.SelEnd - Editor.SelStart])
  else
    StatusBar.Panels[3].Text := '';

  StatusBar.Panels[4].Text := BrowsingPath;

  if (scModified in Changes) then
    if Editor.Modified then
      Editor.Sheet.ImageIndex := IDX_IMG_MODIFIED
    else
      Editor.Sheet.ImageIndex := IDX_IMG_STANDARD;

  case Editor.LineEndingType of
    sfleCrLf: StatusBar.Panels[5].Text := mnuCRLF.Caption;
    sfleLf:   StatusBar.Panels[5].Text := mnuLF.Caption;
      sfleCr:   StatusBar.Panels[5].Text := mnuCR.Caption;
    else
      StatusBar.Panels[5].Text:= '';
    end;

 StatusBar.Panels[6].Text := Editor.DiskEncoding;

 if (scInsertMode in Changes) then
    if Editor.InsertMode then
      StatusBar.Panels[7].Text := RSStatusBarInsMode
    else
      StatusBar.Panels[7].Text := RSStatusBarOvrMode;

end;

procedure TfMain.RecentFileEvent(Sender: TObject; const AFileName: string; const AData: TObject);
begin
  EditorFactory.AddEditor(AFileName);
  MRU.AddToRecent(AFileName);
end;

procedure TfMain.NewEditor(Editor: TEditor);
begin
  Editor.PopupMenu := pumEdit;
end;

procedure TfMain.SearchFindExecute(Sender: TObject);
var
  Editor: TEditor;
begin

  if not EditorAvalaible then
    exit;

  Editor := EditorFactory.CurrentEditor;
  if Editor.SelAvail and (Editor.BlockBegin.Y = Editor.BlockEnd.Y) then
    ReplaceDialog.FindText := Editor.SelText
  else
    ReplaceDialog.FindText:= Editor.GetWordAtRowCol(Editor.CaretXY);

  ReplaceDialog.Options:=ReplaceDialog.Options -  [ssoReplace, ssoReplaceAll];
  ReplaceDialog.Show;
end;

procedure TfMain.SearchFindNextExecute(Sender: TObject);
var
  sOpt: TMySynSearchOptions;
  Ed: TEditor;
begin
  Ed := EditorFactory.CurrentEditor;
  if Assigned(Ed) then
  begin
    if (FindText = EmptyStr) then
    begin
      if Ed.SelAvail and (Ed.BlockBegin.Y = Ed.BlockEnd.Y) then
        FindText := Ed.SelText;
      if (FindText = EmptyStr) then
        Exit;
    end;

    sOpt := SynOption;
    sOpt := sOpt - [ssoBackWards];
    if Ed.SearchReplace(FindText, '', TSynSearchOptions(sOpt)) = 0 then
      ShowMessage(Format(RSTextNotfound, [FindText]));
  end;

end;

procedure TfMain.SearchFindPreviousExecute(Sender: TObject);
var
  sOpt: TMySynSearchOptions;
  Ed: TEditor;
begin
  if (FindText = EmptyStr) then
    Exit;

  Ed := EditorFactory.CurrentEditor;
  if Assigned(Ed) then
  begin
    sOpt := SynOption;
    sOpt := sOpt + [ssoBackWards];
    if Ed.SearchReplace(FindText, '', TSynSearchOptions(sOpt)) = 0 then
      ShowMessage(Format(RSTextNotfound, [FindText]));
  end;

end;

procedure TfMain.SearchReplaceExecute(Sender: TObject);
var
  Editor: TEditor;
begin

  if not EditorAvalaible then
    exit;
  Editor := EditorFactory.CurrentEditor;

  if Editor.SelAvail and (Editor.BlockBegin.Y = Editor.BlockEnd.Y) then
    ReplaceDialog.FindText := Editor.SelText
  else
    ReplaceDialog.FindText:= Editor.GetWordAtRowCol(Editor.CaretXY);

  ReplaceDialog.cbReplace.Checked := true;
  ReplaceDialog.Show;

end;


procedure TfMain.SortAscendingExecute(Sender: TObject);
var
  Ed: TEditor;
begin

  Ed := EditorFactory.CurrentEditor;
  ed.BeginUpdate(True);
  try
    Ed.Sort(True);

  finally
    Ed.EndUpdate;
  end;

end;

procedure TfMain.SortDescendingExecute(Sender: TObject);
var
  Ed: TEditor;
begin

  Ed := EditorFactory.CurrentEditor;
  ed.BeginUpdate(True);
  try
    Ed.Sort(False);
  finally
    Ed.EndUpdate;
  end;

end;

function TfMain.EditorAvalaible: boolean;
begin
  Result := Assigned(EditorFactory) and Assigned(EditorFactory.CurrentEditor);
end;


  //case Dialog.SearchMode of
  //  smRegexp : begin
  //              include(SynOption, ssoRegExpr);
  //              ReplaceText := Dialog.ReplaceText;
  //             end;
  //  smNormal : begin
  //               ReplaceText := Dialog.ReplaceText;
  //             end;
  //  smExtended: begin
  //                FindText := JSONStringToString(Dialog.FindText);
  //                ReplaceText := JSONStringToString(Dialog.ReplaceText);
  //              end;
  //end;
  //


function TfMain.AskFileName(Editor: TEditor): boolean;
begin
  SaveDialog.FileName := Editor.Sheet.Caption;
  if SaveDialog.Execute then
  begin
    Editor.FileName := SaveDialog.FileName;
    Result := True;
  end
  else
  begin
    Result := False;
  end;

end;

procedure TfMain.BeforeCloseEditor(Editor: TEditor; var Cancel: boolean);
begin
  if not Editor.Modified then
    Cancel := False
  else
    case MessageDlg(Format(RSSaveChanges, [ExtractFileName(trim(Editor.Sheet.Caption))]), mtWarning,
        [mbYes, mbNo, mbCancel], 0) of
      mrYes:
      begin
        if Editor.Untitled then
          if not AskFileName(Editor) then
          begin
            Cancel := True;
            Exit;
          end;
        Cancel := not Editor.Save;
      end;
      mrNo: Cancel := False;
      mrCancel: Cancel := True;
    end;

end;

procedure TfMain.LoadDir(Path:string);
var i: Integer;
begin
  UniqueInstance1.Identifier := MD5Print(MD5String(Path));
  UniqueInstance1.Enabled := True;

  ConfigObj.LastDirectory := ExpandFileName(Path);
  splLeftBar.Visible := true;
  BrowsingPath := Path;
  FilesTree.Items.Clear;
  ExpandNode(nil,Path);

  miBookmarkAdd.Enabled := True;
  miBookmarkDel.Enabled := False;
  if Assigned(Bookmarks) then
    for i := 0 to Bookmarks.Count - 1 do
    begin
      if Bookmarks[i] = Path then
      begin
        miBookmarkAdd.Enabled := False;
        miBookmarkDel.Enabled := True;
        Exit;
      end;
    end;
end;

procedure TfMain.ExpandNode(NodeDir: TFileTreeNode; const Path:string);
var
  DirList: TstringList;
  FileList :TstringList;
  i,j: integer;
  CurrentPath: String;
  NewNode: TFileTreeNode;
begin
  DirList:=TStringList.Create;
  FileList:=TStringList.Create;
  FileList.OwnsObjects := true;
  CurrentPath:=IncludeTrailingPathDelimiter(Path);
  try
    BuildFolderList(CurrentPath, DirList);
    DirList.Sort;
    for i := 0 to DirList.Count -1 do
      begin
        NewNode:=TFileTreeNode(FilesTree.items.AddChild(NodeDir, ExtractFileName(DirList[i])));
        NewNode.FullPath:=DirList[i];
        NewNode.isDir:=True;
        NewNode.HasChildren := true;
      end;
    FileList.Clear;
    BuildFileList(IncludeTrailingPathDelimiter(CurrentPath)+AllFilesMask,
                   faAnyFile, FileList, False);
    FileList.Sort;

    for j := 0 to FileList.Count -1 do
      begin
        NewNode:=TFileTreeNode(FilesTree.items.AddChild(NodeDir, ExtractFileName(FileList[j])));
        NewNode.FullPath:=FileList[j];
        NewNode.isDir:=False;
      end;

  finally
    DirList.Free;
    FileList.Free;
  end;

//  if PathHistory.IndexOf(Path) < 0 then
//     PathIndex := PathHistory.Add(Path);

end;

procedure TfMain.FilesTreeCreateNodeClass(Sender: TCustomTreeView;
  var NodeClass: TTreeNodeClass);
begin
  NodeClass:= TFileTreeNode;
end;

procedure TfMain.FilesTreeDblClick(Sender: TObject);
var
  Node: TFileTreeNode;
begin
  Node := TFileTreeNode(FilesTree.Selected);
  if Node = nil then
     exit;

  if Node.isDir then
  begin
    if Node.Expanded then
      Node.ImageIndex := 0
    else
      Node.ImageIndex := 1;
  end
  else
    EditorFactory.AddEditor(Node.FullPath, BrowsingPath);

end;

procedure TfMain.FilesTreeExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  myNode: TFileTreeNode;
begin
myNode := TFileTreeNode(Node);
  if myNode = nil then
     exit;

  MyNode.DeleteChildren;

  if (myNode.isDir) then
    ExpandNode(MyNode, myNode.FullPath);

end;

procedure TfMain.FilesTreeGetImageIndex(Sender: TObject; Node: TTreeNode);
var myNode: TFileTreeNode;
begin
  myNode := TFileTreeNode(Node);
  if myNode = nil then
     exit;

  if (myNode.isDir) then
    if myNode.Expanded then
      myNode.ImageIndex := 0
    else
      myNode.ImageIndex := 1
  else
  begin
    case LowerCase(ExtractFileExt(myNode.FullPath)) of
      '.go':    myNode.ImageIndex := 3;
      '.cpp':   myNode.ImageIndex := 4;
      '.c++':   myNode.ImageIndex := 4;
      '.c':     myNode.ImageIndex := 5;
      '.cc':    myNode.ImageIndex := 5;
      '.h':     myNode.ImageIndex := 6;
      '.hpp':   myNode.ImageIndex := 7;
      '.hcl':   myNode.ImageIndex := 8;
      '.yaml':  myNode.ImageIndex := 9;
      '.yml':   myNode.ImageIndex := 9;
      '.json':  myNode.ImageIndex := 10;
      '.nix':   myNode.ImageIndex := 11;
      '.cmake': myNode.ImageIndex := 13;
      '.md':    myNode.ImageIndex := 14;
      '.xml':   myNode.ImageIndex := 15;
      '.tf':    myNode.ImageIndex := 16;
      '.ca':    myNode.ImageIndex := 17;
      '.cs':    myNode.ImageIndex := 18;
      '.css':   myNode.ImageIndex := 19;
      '.java':  myNode.ImageIndex := 20;
      '.pl':    myNode.ImageIndex := 22;
      '.php':   myNode.ImageIndex := 23;
      '.pdf':   myNode.ImageIndex := 24;
      '.py':    myNode.ImageIndex := 25;
      '.rb':    myNode.ImageIndex := 26;
      '.sh':    myNode.ImageIndex := 27;
      '.ps1':   myNode.ImageIndex := 27;
      '.html':  myNode.ImageIndex := 28;
      '.htm':   myNode.ImageIndex := 28;
      '.zip':   myNode.ImageIndex := 30;
      '.tar':   myNode.ImageIndex := 30;
      '.gz':    myNode.ImageIndex := 30;
      '.log':   myNode.ImageIndex := 31;
      '.tex':   myNode.ImageIndex := 35;
    else
      myNode.ImageIndex := 2;
    end;

    case LowerCase(ExtractFileName(myNode.FullPath)) of
      '.gitignore':     myNode.ImageIndex := 21;
      '.gitmodules':    myNode.ImageIndex := 21;
      '.gitattributes': myNode.ImageIndex := 21;
    end;

    case LowerCase(ChangeFileExt(ExtractFileName(myNode.FullPath), '')) of
      'makefile':      myNode.ImageIndex := 12;
      'cmake_install': myNode.ImageIndex := 13;
      'cmakelists':    myNode.ImageIndex := 13;
      'dockerfile':    myNode.ImageIndex := 29;
      'readme':        myNode.ImageIndex := 32;
      'changelog':     myNode.ImageIndex := 33;
      'contributing':  myNode.ImageIndex := 34;
    end;
  end;

end;

procedure TfMain.FilesTreeGetSelectedIndex(Sender: TObject; Node: TTreeNode);
var
  myNode: TFileTreeNode;
begin
  myNode := TFileTreeNode(Node);
  if myNode = nil then
     exit;
  myNode.SelectedIndex:=myNode.ImageIndex;
end;

procedure TfMain.FilesTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var Node: TFileTreeNode;
begin
  if Key = VK_RETURN then
  begin
    Node := TFileTreeNode(FilesTree.Selected);
    if Node = nil then
       exit;

    if Node.isDir then
      exit
    else
      begin
         EditorFactory.AddEditor(Node.FullPath, BrowsingPath);
      end;
  end;
end;

procedure TfMain.FilesTreeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var ClickedNode: TTreeNode;
begin
  ClickedNode := FilesTree.GetNodeAt(X, Y);

  if not Assigned(ClickedNode) then
  begin
    FilesTree.ClearSelection(false);
    actCopyFile.Enabled := False;
    actCutFile.Enabled := False;
    EditDelete.Enabled := False;
    actOpenExtern.Enabled := False;
  end;
end;

procedure TfMain.FilesTreeSelectionChanged(Sender: TObject);
var Node: TFileTreeNode;
begin
  Node := TFileTreeNode(FilesTree.Selected);

  if not Assigned(Node) then
    Exit;

  actCopyFile.Enabled := True;
  actCutFile.Enabled := True;
  actFolderNew.Enabled := True;
  EditDelete.Enabled := True;
  actOpenExtern.Enabled := True;
  if Node.isDir then
  begin
    actCopyFile.Enabled := False;
    actCutFile.Enabled := False;
    EditDelete.Enabled := False;
    actOpenExtern.Enabled := False;
  end;
end;


end.

