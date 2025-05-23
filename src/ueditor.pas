{$I codegen.inc}
unit ueditor;

{$IFDEF WINDOWS}
  {$DEFINE NEEDCLOSEBTN}
{$ENDIF}

interface

uses
  Classes, SysUtils, Controls, Dialogs, Buttons, ComCtrls, LCLProc, LCLType, LCLIntf,
  SynEditTypes, SynEdit, SynGutter, SynGutterMarks, SynGutterLineNumber, LazUtilities,
  SynPluginMultiCaret, SynPluginSyncroEdit, SynEditKeyCmds, ExtCtrls, HTMLView,
  SynEditMouseCmds, SynEditLines, Stringcostants, Forms, Graphics, Config,
  uCheckFileChange, SynEditHighlighter, Clipbrd, LConvEncoding, LazStringUtils,SynBeautifier,
  ReplaceDialog, SupportFuncs, LCLVersion, SynCompletion, ucmdbox, ucmdboxcustom, ucmdboxthread, ulsp;

type

  TEditor = class;
  TEditorTabSheet = class;
  TEditorFactory = class;

  TTextLevel = (tomSelection, tomLines, tomFullText);
  TTextOperationLevel = set of TTextLevel;

const
  DefaultOperationLevel = [tomSelection, tomLines];

var
  LineEndings : array[TSynLinesFileLineEndType] of string = (lineending,'',#13#10,#13,#10);

type
  TTextOperation = function(const Param: string): string;



  { TEditorFactory }

  TOnBeforeClose = procedure(Editor: TEditor; var Cancel: boolean) of object;
  TOnEditorEvent = procedure(Editor: TEditor) of object;
  TOnSearchReplaceEvent= procedure (Sender:TObject; const ASearch, AReplace: string; AOptions: TMySynSearchOptions) of object;

  TEditor = class(TSynEdit)
  private
    FFileName: TFilename;
    FFilePath: String;
    FOnSearchReplace: TOnSearchReplaceEvent;
    FSheet: TEditorTabSheet;
    FUntitled: boolean;
    fCaretPos: TPoint;
    MultiCaret: TSynPluginMultiCaret;
    SyncEdit: TSynPluginSyncroEdit;
    fOldDiskEncoding: string;
    FDiskEncoding: String;
    fDiskLineEndingType : TSynLinesFileLineEndType;
    fOldDiskLineEndingType : TSynLinesFileLineEndType;
    procedure CreateDefaultGutterParts;
    procedure GetDialogPosition(AWidth, AHeight: integer; out _Left, _Top: integer);
    function GetDiskEncoding: string;
    function GetLineEndingType: TSynLinesFileLineEndType;
    function GuessLineEndType(AString: string): TSynLinesFileLineEndType;
    procedure OnReplace(Sender: TObject; const ASearch, AReplace: string; Line, Column: integer; var _Action: TSynReplaceAction);
    procedure QuickSort(L, R: integer; CompareFn: TStringsSortCompare);
    procedure SetDiskEncoding(AValue: string);
    procedure SetFileName(AValue: TFileName);
    procedure SetFilePath(AValue: String);
    procedure SetLineEndingType(AValue: TSynLinesFileLineEndType);
    procedure SetOnSearcReplace(AValue: TOnSearchReplaceEvent);
    procedure SetText(NewText: string);
    procedure SetUntitled(AValue: boolean);
  protected
    procedure SetHighlighter(const Value: TSynCustomHighlighter); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Sheet: TEditorTabSheet read FSheet;
    property OnSearchReplace: TOnSearchReplaceEvent read FOnSearchReplace write SetOnSearcReplace;
    //-- Helper functions//
    procedure SetLineText(Index: integer; NewText: string);
    // -- File handling//
    property FileName: TFileName read FFileName write SetFileName;
    property FilePath: String read FFilePath write SetFilePath;
    property Untitled: boolean read FUntitled write SetUntitled;
    property DiskEncoding:string read GetDiskEncoding write SetDiskEncoding;
    property LineEndingType: TSynLinesFileLineEndType read GetLineEndingType write SetLineEndingType;
    procedure LoadFromFile(AFileName: TFileName);
    procedure Sort(Ascending: boolean);
    procedure TextOperation(Operation: TTextOperation; const Level: TTextOperationLevel = DefaultOperationLevel);
    procedure PushPos;
    procedure PopPos;
    function Save: boolean;
    function SaveAs(AFileName: TFileName): boolean;
  end;

  { TEditorTabSheet }

  TEditorTabSheet = class(TTabSheet)
  private
    FEditor: TEditor;
    FPreview: THtmlViewer;
    FLSP: TLSP;
    FMessageBox: TPageControl;
    FLSPBox: TCmdBoxCustom;
    FCMDBox: TCmdBoxCustom;
  protected
    procedure DoShow; override;

  public
    FCmdBoxThread: TCmdBoxThread;
    property MessageBox: TPageControl read FMessageBox;
    property LSP: TLSP read FLSP;
    property LSPBox: TCmdBoxCustom read FLSPBox;
    property CMDBox: TCmdBoxCustom read FCMDBox;
    property Editor: TEditor read FEditor;
    property Preview: THtmlViewer read FPreview write FPreview;
    property CmdBoxThread: TCmdBoxThread read FCmdBoxThread;
    //--//
  end;



  TEditorFactory = class(TPageControl)
  private
    FOnBeforeClose: TOnBeforeClose;
    FOnNewEditor: TOnEditorEvent;
    FonStatusChange: TStatusChangeEvent;
    fUntitledCounter: integer;
    FWatcher: TFileWatcher;
    function GetCurrentEditor: TEditor;
    function GetCurrenTCmdBoxThread: TCmdBoxThread;
    function GetCurrentLSP: TLSP;
    function GetCurrenTCmdBox: TCmdBoxCustom;
    function GetCurrentLSPBox: TCmdBoxCustom;
    function GetCurrentMessageBox: TPageControl;
    function CreateEmptyFile(AFileName: TFileName): boolean;
    function CreateMessageTab(const AName: String; ABox: TPageControl):TCmdBoxCustom;
    procedure SetOnBeforeClose(AValue: TOnBeforeClose);
    procedure SetOnNewEditor(AValue: TOnEditorEvent);
    procedure ShowHintEvent(Sender: TObject; HintInfo: PHintInfo);
    procedure OnFileChange(Sender: TObject; FileName: TFileName; Data: Pointer; State: TFWStateChange);
    procedure EditorOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SetCurrentCmdBoxThread(AThread: TCmdBoxThread);
  protected
    procedure DoChange; override;
    procedure DragOver(Source: TObject; X,Y: Integer; State: TDragState;
                       var Accept: Boolean); override;

  public
    property CurrentEditor: TEditor read GetCurrentEditor;
    property CurrenTCmdBoxThread: TCmdBoxThread read GetCurrenTCmdBoxThread write SetCurrentCmdBoxThread;
    property CurrentLSP: TLSP read GetCurrentLSP;
    property CurrentLSPBox: TCmdBoxCustom read GetCurrentLSPBox;
    property CurrentCmdBox: TCmdBoxCustom read GetCurrentCmdBox;
    property CurrentMessageBox: TPageControl read GetCurrentMessageBox;
    property OnStatusChange: TStatusChangeEvent read FonStatusChange write FOnStatusChange;
    property OnBeforeClose: TOnBeforeClose read FOnBeforeClose write SetOnBeforeClose;
    property OnNewEditor: TOnEditorEvent read FOnNewEditor write SetOnNewEditor;
    //--//
    procedure DoCloseTabClicked(APage: TCustomPage); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    function AddEditor(FileName: TFilename = ''; BrowsingPath: String = ''): TEditor;
    function CloseEditor(Editor: TEditor; Force: boolean = False): boolean;
    function CloseAll(KeepCurrent:boolean=false): boolean;
    function CloseAfter: boolean;
    function CloseBefore: boolean;
    function SaveAll: boolean;
    procedure DoCheckFileChanges;
    procedure ReloadHighLighters;
    procedure ChangeOptions(Option: TSynEditorOption; Add: boolean);
    //{$IF LCL_FULLVERSION>=2000400}
    //function TabRect(AIndex: Integer): TRect; reintroduce;
    //{$ENDIF}
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    {$IFDEF NEEDCLOSEBTN}
    procedure PaintWindow(DC: HDC); override;
    {$ENDIF}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses umain;

{ TEditorTabSheet }

procedure TEditorTabSheet.DoShow;
begin
  inherited DoShow;

end;

{ TEditor }

procedure TEditor.SetFileName(AValue: TFileName);
var ext: String;
begin
  if FFileName = AValue then
    Exit;

  FFileName := AValue;
  if FFileName <> EmptyStr then
  begin
    FUntitled := False;
    Highlighter := ConfigObj.getHighLighter(ExtractFileExt(fFileName));

    case LowerCase(ExtractFileExt(fFileName)) of
      '.conf': ext := '.ini';
      '.toml': ext := '.ini';
    else
      ext := ExtractFileExt(fFileName);
    end;

    Highlighter := ConfigObj.getHighLighter(ext);
    FSheet.Caption := ExtractFileName(fFileName);
    FFilePath := ExtractFilePath(fFileName);

{$IFDEF NEEDCLOSEBTN}
     // reserve spaces for emulated close button
      + Space(6)
{$ENDIF}
    ;
  end
  else
    FUntitled := True;
end;

procedure TEditor.SetFilePath(AValue: String);
begin
  if Length(AValue) > 0 then
    if FFilePath = AValue then
      Exit;

  FFilePath := AValue;
end;

procedure TEditor.SetLineEndingType(AValue: TSynLinesFileLineEndType);
begin
  fDiskLineEndingType := AValue;
  Modified := true;
end;

procedure TEditor.SetOnSearcReplace(AValue: TOnSearchReplaceEvent);
begin
  if FOnSearchReplace = AValue then Exit;
  FOnSearchReplace := AValue;
end;

procedure TEditor.SetUntitled(AValue: boolean);
begin
  if FUntitled = AValue then
    Exit;

  FUntitled := AValue;
  if FUntitled then
    FFileName := EmptyStr;
end;

procedure TEditor.SetHighlighter(const Value: TSynCustomHighlighter);
begin
  inherited SetHighlighter(Value);
  DoOnStatusChange([]);
end;

constructor TEditor.Create(AOwner: TComponent);
  procedure DeleteKeyStroke(keys:TSynEditKeyStrokes;Code: word; SS: TShiftState);
  var
   id : Integer;
  begin
      id := keys.FindKeycode(code,ss);
      if id <> - 1 then
        keys.Delete(id);
  end;

begin

  inherited Create(AOwner);
  TabWidth := NUMBEROFSPACEFORTAB;
  Options := Options + [eoAltSetsColumnMode];
  MouseOptions := MouseOptions + [emCtrlWheelZoom, emRightMouseMovesCursor];

  DeleteKeyStroke(Keystrokes,ord('N'),[ssCtrl]);

  CreateDefaultGutterParts;

  multicaret := TSynPluginMultiCaret.Create(self);
  DeleteKeyStroke(MultiCaret.KeyStrokes,ord('N'),[ssCtrl]);

  multicaret.EnableWithColumnSelection := True;
  multicaret.DefaultMode := mcmMoveAllCarets;
  multicaret.DefaultColumnSelectMode := mcmCancelOnCaretMove;

  SyncEdit := TSynPluginSyncroEdit.Create(self);
  SyncEdit.Editor := self;
  SyncEdit.CaseSensitive := False;
  Gutter.Visible:= ConfigObj.ShowRowNumber;

  OnReplaceText := @OnReplace;

end;

destructor TEditor.Destroy;
begin
  MultiCaret.Free;
  SyncEdit.Free;
  inherited Destroy;
end;


procedure TEditor.SetLineText(Index: integer; NewText: string);
begin
  TextBetweenPoints[Point(1, Index + 1), PhysicalToLogicalPos(Point(Length(Lines[Index]) + 1, Index + 1))] := NewText;
end;

procedure TEditor.SetText(NewText: string);
begin
  TextBetweenPoints[Point(1, 1), PhysicalToLogicalPos(Point(Length(Lines[Lines.Count - 1]) + 1, Lines.Count))] := NewText;
end;

function TEditor.GuessLineEndType(AString: string) : TSynLinesFileLineEndType;
var
  i: Integer;
begin
  result := sfleSystem;
  i := 1;
  while i <= length(AString) do begin
    if AString[i] in [#10,#13] then begin
      if AString[i]=#10 then result := sfleLf
      else if (i < length(AString)) and (AString[i+1]=#10) then result := sfleCrLf
      else result := sfleCr;
      break;
    end;
    inc(i);
  end;
end;

procedure TEditor.LoadFromFile(AFileName: TFileName);
var
  fStream: TFileStream;
  s: RawByteString='';
  wSize: integer;
  b:boolean;
  Error: Integer;
begin
  SetFileName(AFileName);
  SetFilePath(ExtractFilePath(AFileName));
  fStream := nil;
  try
    fStream := TFileStream.Create(FFileName, fmOpenRead,fmShareDenyNone);

    wSize := fStream.Size;
    SetLength(s, wSize);
    if wSize > 0 then
      fStream.Read(s[1], wSize);
    FDiskEncoding := NormalizeEncoding(GuessEncoding(s));

    S := ConvertEncodingToUTF8(s,FDiskEncoding, b);

    fDiskLineEndingType:=GuessLineEndType(S);
    if fDiskLineEndingType = sfleSystem then
      fDiskLineEndingType:=GuessLineEndType(LineEnding);
    Lines.Text := S;

    fOldDiskEncoding := FDiskEncoding;
    fOldDiskLineEndingType := fDiskLineEndingType;


  Except
    on e: EFOpenError do
      begin
        Error := GetLastOSError;
        MessageDlg(RSError, Format(RSCannotSave, [fFileName, Error, SysErrorMessage(Error)]), mtError, [mbRetry, mbCancel, mbIgnore], 0)
      end
    else raise;

  end;
  DoOnStatusChange([]);

  if Assigned(fStream) then
    fStream.free;

end;

procedure TEditor.Sort(Ascending: boolean);
var
  f: TStringsSortCompare;
begin
  f := @CompareStr;
  QuickSort(0, Lines.Count - 1, f);
end;

function TEditor.Save: boolean;
begin
  Result := SaveAs(FFileName);
  TEditorFactory(Sheet.Owner).FWatcher.Update(FFileName);
  if Sheet.FLSP <> nil then
  begin
    Sheet.FLSP.Resume;
    Sheet.FLSP.Reload;
  end;
end;

function TEditor.SaveAs(AFileName: TFileName): boolean;
var
  Retry: boolean;
  s: RawByteString='';
  fStream: TFileStream;
  b: boolean;
  Error: integer;
begin
  repeat
    Retry := False;
    try
      if FFileName <> EmptyStr then
        TEditorFactory(Sheet.Owner).FWatcher.RemoveFile(FFileName);
      SetFileName(AFileName);
      SetFilePath(ExtractFilePath(AFileName));
      s:= Lines.Text;

      if fDiskLineEndingType <> GuessLineEndType(LineEnding) then
        s:= ChangeLineEndings(s,LineEndings[fDiskLineEndingType]);

      if FDiskEncoding <> EncodingUTF8 then
        s:= ConvertEncodingFromUTF8(S, FDiskEncoding, b);

      fStream:= TFileStream.Create(FFileName, fmOpenWrite+fmCreate);
      try
        fStream.Write(S[1], Length(s));
      finally
        FreeAndNil(fStream);
      end;
      TEditorFactory(Sheet.Owner).FWatcher.AddFile(FFileName, Self);
      Result := True;
      FUntitled := False;
      Modified := False;
    except
      Result := False;
    end;

    if not Result then
    begin
      Error := GetLastOSError;
      case MessageDlg(RSError, Format(RSCannotSave, [fFileName, Error, SysErrorMessage(Error)]), mtError, [mbRetry, mbCancel, mbIgnore], 0) of
        mrAbort: Result := False;
        mrIgnore: Result := True;
        mrRetry: Retry := True;
      end;
    end;
  until not Retry;

end;

function TEditorFactory.CreateEmptyFile(AFileName: TFileName): boolean;
var
  fs: TFileStream;
  Retry: boolean;
begin
  repeat
    Retry := False;
    try
      fs := TFileStream.Create(AFileName, fmCreate);
      fs.Free;
      Result := True;
    except
      Result := False;
    end;

    if not Result then
    begin
      case MessageDlg(RSError, Format(RSCannotCreate, [AFileName]), mtError, [mbRetry, mbAbort], 0) of
        mrAbort: Result := False;
        mrRetry: Retry := True;
      end;
    end;
  until not Retry;

end;

procedure TEditorFactory.OnFileChange(Sender: TObject; FileName: TFileName; Data: Pointer; State: TFWStateChange);
var
  ed: TEditor;
  dlgText: string;
begin
  ed := TEditor(Data);
  case State of
    fwscModified:
    begin
      if ed.Modified then
        dlgText := RSReloadModified
      else
        dlgText := RSReloadsimple;

      if MessageDlg(RSReload, Format(dlgText, [FileName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        ed.PushPos;
        ed.LoadFromFile(FileName);
        ed.Modified := False;
        ed.PopPos;
      end
      else
        ed.Modified := True;

    end;
    fwscDeleted:
    begin
      if MessageDlg(RSReload, Format(RSKeepDeleted, [FileName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        ed.Modified := True;
        FWatcher.Update(FileName);
      end
      else
        CloseEditor(Ed, True);
    end;
  end;
  FWatcher.Update(FileName);
end;

procedure TEditor.CreateDefaultGutterParts;
var
  SpecialAttr: TFontAttributes;
  DefaultAttr: TFontAttributes;
  j: integer;
begin
  DefaultAttr := ConfigObj.ReadFontAttributes('Schema/Default/Gutter/', FontAttributes());
  SpecialAttr := ConfigObj.ReadFontAttributes('Schema/Default/LineNumber/', FontAttributes());
  Gutter.Color := DefaultAttr.Background;

  for j := 0 to Gutter.Parts.Count - 1 do
  begin
    if gutter.Parts[j] is TSynGutterMarks then
    begin
      gutter.Parts[j].MarkupInfo.BeginUpdate;
      gutter.Parts[j].MarkupInfo.Background := DefaultAttr.Background;
      gutter.Parts[j].MarkupInfo.Foreground := DefaultAttr.Foreground;
      gutter.Parts[j].MarkupInfo.Style := DefaultAttr.Styles;
      gutter.Parts[j].MarkupInfo.EndUpdate;
    end;

    if (gutter.Parts[j] is TSynGutterLineNumber) or
      (gutter.Parts[j] is TSynGutterSeparator) then
    begin
      gutter.Parts[j].MarkupInfo.BeginUpdate;
      gutter.Parts[j].MarkupInfo.Background := SpecialAttr.Background;
      gutter.Parts[j].MarkupInfo.Foreground := SpecialAttr.Foreground;
      gutter.Parts[j].MarkupInfo.Style := SpecialAttr.Styles;
      gutter.Parts[j].MarkupInfo.EndUpdate;
    end;
  end;

end;

function TEditor.GetDiskEncoding: string;
begin
   //if FDiskEncoding = EncodingUCS2LE then
   //  Result := 'UTF16LE'
   //else
   //if FDiskEncoding = EncodingUCS2BE then
   //  Result := 'UTF16BE'
   //else
   Result := FDiskEncoding;

end;

function TEditor.GetLineEndingType: TSynLinesFileLineEndType;
begin
  result := fDiskLineEndingType;
end;

procedure TEditor.QuickSort(L, R: integer; CompareFn: TStringsSortCompare);
var
  Pivot, vL, vR: integer;
begin
  //if ExchangeItems is override call that, else call (faster) ExchangeItemsInt
  if R - L <= 1 then
  begin // a little bit of time saver
    if L < R then
      if CompareFn(Lines[L], Lines[R]) > 0 then
        Lines.Exchange(L, R);
    Exit;
  end;

  vL := L;
  vR := R;

  Pivot := L + Random(R - L); // they say random is best

  while vL < vR do
  begin
    while (vL < Pivot) and (CompareFn(Lines[vL], Lines[Pivot]) <= 0) do
      Inc(vL);

    while (vR > Pivot) and (CompareFn(Lines[vR], Lines[Pivot]) > 0) do
      Dec(vR);

    Lines.Exchange(vL, vR);

    if Pivot = vL then // swap pivot if we just hit it from one side
      Pivot := vR
    else if Pivot = vR then
      Pivot := vL;
  end;

  if Pivot - 1 >= L then
    QuickSort(L, Pivot - 1, CompareFn);
  if Pivot + 1 <= R then
    QuickSort(Pivot + 1, R, CompareFn);
end;

procedure TEditor.SetDiskEncoding(AValue: string);
begin
  if FDiskEncoding = AValue then Exit;
  FDiskEncoding := AValue;
  DoOnStatusChange([]);
end;

procedure TEditor.TextOperation(Operation: TTextOperation; const Level: TTextOperationLevel = DefaultOperationLevel);
var
  i: integer;
  tmpst: TStringList;
begin

  if (tomSelection in Level) and SelAvail then
  begin
    tmpst := TStringList.Create;
    tmpst.Text := SelText;
    for i := 0 to tmpst.Count - 1 do
      tmpst[i] := Operation(tmpst[i]);
    SelText := copy(tmpst.Text, 1, Length(tmpst.Text) - Length(LineEnding));
  end
  else
  if (tomLines in Level) then
  begin
    BeginUpdate(True);
    try
      for i := 0 to Lines.Count - 1 do
      begin
        SetLineText(i, Operation(Lines[i]));
      end;

    finally
      EndUpdate;
    end;
  end
  else
  begin
    BeginUpdate(True);
    try
      //   for i := 0 to Lines.Count - 1 do
      begin
        SetText(Operation(Text));
      end;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TEditor.PushPos;
begin
  fCaretPos := CaretXY;
end;

procedure TEditor.PopPos;
begin
  CaretXY := fCaretPos;
end;

procedure TEditor.GetDialogPosition(AWidth, AHeight: integer;
  out _Left, _Top: integer);
var
  P: TPoint;
  ABounds: TRect;
begin
  P := ClientToScreen(Point(CaretXPix, CaretYPix));
  ABounds := Screen.MonitorFromPoint(P).WorkareaRect;
  _Left := ClientOrigin.X + (AWidth - AWidth) div 2;
  _Top := P.Y - AHeight - 3 * LineHeight;
  if _Top < ABounds.Top + 10 then
    _Top := P.Y + 2 * LineHeight;
  if _Top + AHeight > ABounds.Bottom then
    _Top := (ABounds.Bottom + ABounds.Top - AHeight) div 2;
  if _Top < ABounds.Top then _Top := ABounds.Top;
end;


procedure TEditor.OnReplace(Sender: TObject; const ASearch, AReplace:
  string; Line, Column: integer; var _Action: TSynReplaceAction);

  function Shorten(const s: string): string;
  const
    MAX_LEN=300;
  begin
    Result:=s;
    if Length(Result)>MAX_LEN then
      Result:=LeftStr(Result, MAX_LEN)+'...';
  end;

var a,x,y:integer;
  AText:AnsiString;
begin

  AText:=Format(lisUEReplaceThisOccurrenceOfWith,[Shorten(ASearch),LineEnding,Shorten(AReplace)]);

  GetDialogPosition(300,150,X,Y);
  a:=MessageDlgPos(AText,mtconfirmation,
            [mbYes,mbYesToAll,mbNo,mbCancel],0,X,Y);

  case a of
    mrYes:   _Action :=raReplace;
    mrNo :   _Action :=raSkip;
    mrAll,mrYesToAll: _Action :=raReplaceAll;
  else
    _Action:=raCancel;
  end;
end;


{ TEditorFactory }

function TEditorFactory.GetCurrentEditor: TEditor;
begin
  Result := nil;
  if (PageCount > 0) and (ActivePageIndex >= 0) then
    Result := TEditorTabSheet(ActivePage).Editor;

end;

function TEditorFactory.GetCurrentCmdBoxThread: TCmdBoxThread;
begin
  Result := nil;
  if (PageCount > 0) and (ActivePageIndex >= 0) then
    Result := TEditorTabSheet(ActivePage).CmdBoxThread;
end;

procedure TEditorFactory.SetCurrentCmdBoxThread(AThread: TCmdBoxThread);
begin
  if (PageCount > 0) and (ActivePageIndex >= 0) then
    TEditorTabSheet(ActivePage).FCmdBoxThread := AThread;
end;



function TEditorFactory.GetCurrentLSP: TLSP;
begin
  Result := nil;
  if (PageCount > 0) and (ActivePageIndex >= 0) then
    Result := TEditorTabSheet(ActivePage).FLSP;
end;

function TEditorFactory.GetCurrentLSPBox: TCmdBoxCustom;
begin
  Result := nil;
  if (PageCount > 0) and (ActivePageIndex >= 0) then
    Result := TEditorTabSheet(ActivePage).FLSPBox;
end;

function TEditorFactory.GetCurrentCmdBox: TCmdBoxCustom;
begin
  Result := nil;
  if (PageCount > 0) and (ActivePageIndex >= 0) then
    Result := TEditorTabSheet(ActivePage).FCMDBox;
end;

function TEditorFactory.GetCurrentMessageBox: TPageControl;
begin
  Result := nil;
  if (PageCount > 0) and (ActivePageIndex >= 0) then
    Result := TEditorTabSheet(ActivePage).FMessageBox;
end;

procedure TEditorFactory.SetOnBeforeClose(AValue: TOnBeforeClose);
begin
  if FOnBeforeClose = AValue then
    Exit;
  FOnBeforeClose := AValue;
end;

procedure TEditorFactory.SetOnNewEditor(AValue: TOnEditorEvent);
begin
  if FOnNewEditor = AValue then
    Exit;
  FOnNewEditor := AValue;
end;

procedure TEditorFactory.DoChange;
var Node: TFileTreeNode;
    i: Integer;
begin
  inherited DoChange;
  //  Hint := TEditorTabSheet(ActivePage).Editor.FileName;
  if Assigned(OnStatusChange) then
    OnStatusChange(GetCurrentEditor, [scCaretX, scCaretY, scModified, scInsertMode]);

  // select the current editors file in filetreeview
  fMain.FilesTree.MultiSelect := False;
  for i := 0 to fMain.FilesTree.Items.Count - 1 do
  begin
    Node := TFileTreeNode(fMain.FilesTree.Items[i]);
    if Assigned(Node) then
      if Node.FullPath = GetCurrentEditor.FileName then
      begin
        fMain.FilesTree.Items[i].Selected := True;
        Break;
      end;
  end;

  TEditorTabSheet(ActivePage).Editor.SetFocus;
end;

procedure TEditorFactory.DragDrop(Source: TObject; X, Y: Integer);
var
  r:TRect;
  i:Integer;
begin
  inherited DragDrop(Source, X, Y);
  if (Source is TPageControl) then
   for i := 0 to PageCount - 1 do
   begin
     r := TabRect(i);
     if r.Contains(Point(X, Y)) then
     begin
       if ActivePage.PageIndex <> i then
         ActivePage.PageIndex := i;
       Exit;
     end;
   end;
end;

procedure TEditorFactory.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited DragOver(Source, X, Y, State, Accept);
  if (Source is TPageControl) then Accept := True;
end;

procedure TEditorFactory.DoCloseTabClicked(APage: TCustomPage);
begin
  inherited DoCloseTabClicked(APage);
  if Assigned(APage) and (APage is TEditorTabSheet) then
    CloseEditor(TEditorTabSheet(APage).FEditor);
end;



function TEditorFactory.AddEditor(FileName: TFilename = ''; BrowsingPath: String = ''): TEditor;
var
  Sheet: TEditorTabSheet;
  Box: TPageControl;
  i: integer;
  DefaultAttr: TFontAttributes;
  Beauty: TSynBeautifier;
  FileType: TSynCustomHighlighter;
begin
  result := nil;
  if FileName <> EmptyStr then
  begin
    // do not reopen same file
    for i := 0 to PageCount - 1 do
    begin
      Sheet := TEditorTabSheet(Pages[i]);
      if Sheet.Editor.FileName = FileName then
      begin
        ActivePageIndex := i;
        exit;
      end;
    end;

    if (FileName <> EmptyStr) and not FileExists(FileName) then
    begin
      case MessageDlg('', format(RSAskFileCreation, [FileName]), mtConfirmation, [mbYes, mbNo], 0) of
        mrNo: Exit;
        mrYes: if not CreateEmptyFile(FileName) then
            Exit;
      end;
    end;

    // try to reuse an empty sheet
    for i := 0 to PageCount - 1 do
    begin
      Sheet := TEditorTabSheet(Pages[i]);
      if (Sheet.Editor.Untitled) and not Sheet.Editor.Modified then
      begin
        Beauty := TSynBeautifier.Create(Sheet);
        Beauty.IndentType := sbitConvertToTabOnly;
        Beauty.AutoIndent := True;

        Sheet.DoubleBuffered := DoubleBuffered;
        Sheet.Editor.Beautifier := Beauty;
        Sheet.Editor.BlockIndent := 0;
        Sheet.Editor.BlockTabIndent := 0;
        Sheet.Editor.DoubleBuffered := DoubleBuffered;
        Sheet.Editor.LoadFromfile(FileName);
        Sheet.Editor.Options := [eoBracketHighlight,eoGroupUndo,eoScrollPastEol,eoTrimTrailingSpaces];
        Sheet.Editor.Options2 := [eoFoldedCopyPaste,eoOverwriteBlock,eoAcceptDragDropEditing];
        FileType := ConfigObj.getHighLighter(ExtractFileExt(FileName));
        if Assigned(FileType) then
        begin
          // create lsp thread
          if not Assigned(Sheet.FLSP) then
            Sheet.FLSP := TLSP.Create;
          Sheet.LSP.Start;
          Sheet.LSP.SetLanguage(FileType.LanguageName);

          if Length(ExtractFilePath(FileName)) <= 0 then
            Sheet.LSP.Initialize(GetCurrentDir, BrowsingPath)
          else
            Sheet.LSP.Initialize(ExtractFilePath(FileName), BrowsingPath);
          Sheet.LSP.OpenFile(FileName);

          // create message box
          if not Assigned(Sheet.FMessageBox) then
            Sheet.FMessageBox := TPageControl.Create(Self);

          Sheet.Editor.OnKeyDown := @EditorOnKeyDown;
        end;
        ChangeOptions(eoShowSpecialChars, ConfigObj.ShowSpecialChars);
        FWatcher.AddFile(FileName, Sheet.Editor);
        ActivePageIndex := i;
        exit;
      end;
    end;
  end;

  Sheet := TEditorTabSheet.Create(Self);
  Sheet.DoubleBuffered := DoubleBuffered;
  Sheet.PageControl := Self;

  // sbitSpace,
  // sbitCopySpaceTab,        - copy indent as it is on previous line.
  // sbitPositionCaret,
  // sbitConvertToTabSpace,   - convert to tabs, fill with spcaces if needed
  // sbitConvertToTabOnly     - convert to tabs, even if shorter
  Beauty := TSynBeautifier.Create(Sheet);
  Beauty.IndentType := sbitConvertToTabSpace;
  Beauty.AutoIndent := True;

  Result := TEditor.Create(Sheet);
  Result.DoubleBuffered := DoubleBuffered;
  Result.BlockIndent := 0;
  Result.BlockTabIndent := 0;
  Result.RightEdge := 80;
  Result.RightEdgeColor := clSilver;
  Result.Options := [eoBracketHighlight,eoGroupUndo,eoScrollPastEol,eoTrimTrailingSpaces];
  Result.Options2 := [eoFoldedCopyPaste,eoOverwriteBlock,eoAcceptDragDropEditing];
  Result.Font.Quality := fqCleartypeNatural;
  Result.Gutter.Color := clBtnFace;
  Result.Beautifier := Beauty;
  Result.OnKeyDown := @EditorOnKeyDown;

  // create tabsheet for run, debug, lsp and so on messages
  Box := TPageControl.Create(fMain.PSSMessageBox);
  Box.Parent := fMain.PSSMessageBox;
  Box.Align := alClient;
  Box.Visible := False;

  Sheet.FMessageBox := Box;

  Sheet.FCMDBox := CreateMessageTab('Compile Output', Box);
  Sheet.FLSPBox := CreateMessageTab('LSP Message', Box);

  Sheet.FCmdBoxThread := TCmdBoxThread.Create;

  Result.Font.Assign(ConfigObj.Font);
  DefaultAttr := ConfigObj.ReadFontAttributes('Schema/Default/Text/', FontAttributes());

  Result.FSheet := Sheet;

  Result.Align := alClient;
  Sheet.FEditor := Result;

  Result.Font.Color := DefaultAttr.Foreground;
  Result.Font.Style := DefaultAttr.Styles;

  Result.Color := DefaultAttr.Background;

  Result.OnStatusChange := OnStatusChange;
  if Assigned(OnStatusChange) then
    OnStatusChange(Result, [scCaretX, scCaretY, scModified, scInsertMode]);

  Result.Parent := Sheet;
  if FileName = EmptyStr then
  begin
    Sheet.Caption := Format(RSNewFile, [fUntitledCounter])
{$IFDEF NEEDCLOSEBTN}
// reserve spaces for emulated close button
      + Space(6)
{$ENDIF}
    ;
    Result.FUntitled := True;
    Inc(fUntitledCounter);
    Text := EmptyStr;
  end
  else
  begin
    ChangeOptions(eoShowSpecialChars, ConfigObj.ShowSpecialChars);
    Result.LoadFromfile(FileName);
    FileType := ConfigObj.getHighLighter(ExtractFileExt(FileName));
    if Assigned(FileType) then
    begin
      // create lsp thread
      if not Assigned(Result.Sheet.FLSP) then
        Result.Sheet.FLSP := TLSP.Create;

      Result.Sheet.LSP.Start;
      Result.Sheet.LSP.SetLanguage(FileType.LanguageName);

      if Length(ExtractFilePath(FileName)) <= 0 then
       Result.Sheet.LSP.Initialize(GetCurrentDir, BrowsingPath)
      else
        Result.Sheet.LSP.Initialize(ExtractFilePath(FileName), BrowsingPath);
      Result.Sheet.LSP.OpenFile(FileName);
    end;
    FWatcher.AddFile(FileName, Result);
  end;

  ActivePage := Sheet;

  if Assigned(FOnNewEditor) then
    FOnNewEditor(Result);

end;


function TEditorFactory.CreateMessageTab(const AName: String; ABox: TPageControl):TCmdBoxCustom;
var Tab: TTabSheet;
    Box: TCmdBoxCustom;
begin
  Tab := TTabSheet.Create(ABox);
  Tab.Caption := AName;
  Tab.PageControl := ABox;
  Tab.Visible := True;

  Box := TCmdBoxCustom.Create(Tab);
  Box.Parent := Tab;
  Box.Align := alClient;
  Box.EscapeCodeType := esctAnsi;
  Box.Font.Assign(ConfigObj.Font);
  Box.Font.Size := Box.Font.Size - 2;
  Box.Visible := True;

  Result := Box;
end;

procedure TEditorFactory.EditorOnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var Ed: TEditor;
begin
  Ed := GetCurrentEditor;
  if not Assigned(Ed) then
    Exit;

  if (Key = VK_OEM_MINUS) and (Shift = [ssAlt]) then
  begin
    Ed.Sheet.LSP.Resume;
    Ed.Sheet.LSP.Hover(Ed.CaretY, Ed.CaretX);
  end;

  if (Key = VK_OEM_PERIOD) and (Shift = [ssAlt]) then
  begin
    Ed.Sheet.LSP.Resume;
    Ed.Sheet.LSP.Change(Ed.Text);
    Ed.Sheet.LSP.Completion(Ed.CaretY, Ed.CaretX, 1)
  end;
end;

function TEditorFactory.CloseEditor(Editor: TEditor; Force: boolean = False): boolean;
var
  Sheet: TEditorTabSheet;
  Cancel: boolean;
begin
  Result := True;
  // if last tab in unused
  if (PageCount = 1) and Editor.Untitled and not Editor.Modified and not ConfigObj.AppSettings.CloseWithLastTab then
    exit;

  Cancel := False;
  if Assigned(FOnBeforeClose) and not Force then
    FOnBeforeClose(Editor, Cancel);

  if (not Cancel) or Force then
  begin
    Sheet := Editor.FSheet;
    if Assigned(Sheet.LSP) then
      Sheet.LSP.Stop;
    Editor.PopupMenu := nil;
    FWatcher.RemoveFile(Editor.FileName);
    Application.ReleaseComponent(Editor);
    Application.ReleaseComponent(Sheet);
    Application.ProcessMessages;
    if (PageCount = 0) and not ConfigObj.AppSettings.CloseWithLastTab then
      AddEditor();
  end
  else
    Result := False;

end;

function TEditorFactory.CloseAll(KeepCurrent:boolean=false): boolean;
var
  i: integer;
begin
  Result := True;
  for i := PageCount - 1 downto 0 do
    begin
      if KeepCurrent and (I = ActivePageIndex) then
        continue;

      if not CloseEditor(TEditorTabSheet(Pages[i]).Editor) then
      begin
        Result := False;
        break;
      end;

    end;
end;

function TEditorFactory.CloseBefore: boolean;
var
  i: integer;
begin
  Result := True;
  for i := ActivePageIndex - 1 downto 0 do
    begin
      if not CloseEditor(TEditorTabSheet(Pages[i]).Editor) then
      begin
        Result := False;
        break;
      end;

    end;
end;

function TEditorFactory.CloseAfter: boolean;
var
  i: integer;
begin
  Result := True;
  for i := PageCount - 1 downto ActivePageIndex + 1 do
    begin
      if not CloseEditor(TEditorTabSheet(Pages[i]).Editor) then
      begin
        Result := False;
        break;
      end;

    end;
end;

function TEditorFactory.SaveAll: boolean;
var
  i: integer;
begin
  Result := True;
  for i := PageCount - 1 downto 0 do
    if not TEditorTabSheet(Pages[i]).Editor.Save then
    begin
      Result := False;
      break;
    end;

end;

procedure TEditorFactory.DoCheckFileChanges;
begin
  FWatcher.CheckFiles;
end;

procedure TEditorFactory.ChangeOptions(Option: TSynEditorOption; Add:boolean);
var
 i: integer;
 ed: TEditor;
begin
    for i := PageCount - 1 downto 0 do
    begin
      ed := TEditorTabSheet(Pages[i]).Editor;
      if Add then
        ed.Options := ed.Options + [Option]
      else
        ed.Options := ed.Options - [Option];
    end;
end;

procedure TEditorFactory.ReloadHighLighters;
var
  i, j: integer;
  fhg: TSynCustomHighlighter;
  DefaultAttr: TFontAttributes;
  DefaultAttrGutter: TFontAttributes;
  SpecialAttrGutter: TFontAttributes;
  ed: TEditor;
begin
  DefaultAttr := ConfigObj.ReadFontAttributes('Schema/Default/Text/', FontAttributes());
  DefaultAttrGutter := ConfigObj.ReadFontAttributes('Schema/Default/Gutter/', FontAttributes());
  SpecialAttrGutter := ConfigObj.ReadFontAttributes('Schema/Default/LineNumber/', FontAttributes());

  for i := PageCount - 1 downto 0 do
  begin
    ed := TEditorTabSheet(Pages[i]).Editor;
    ed.Font.Color := DefaultAttr.Foreground;
    ed.Font.Style := DefaultAttr.Styles;
    ed.Color := DefaultAttr.Background;
    ed.Gutter.Color := DefaultAttrGutter.Background;

    if assigned(Ed.Highlighter) then
    begin
      fhg := ed.Highlighter;
      ed.Highlighter := nil;
      ed.Highlighter := fhg;
    end;

    for j := 0 to ed.Gutter.Parts.Count - 1 do
    begin
      if ed.gutter.Parts[j] is TSynGutterMarks then
      begin
        ed.gutter.Parts[j].MarkupInfo.BeginUpdate;
        ed.gutter.Parts[j].MarkupInfo.Background := DefaultAttrGutter.Background;
        ed.gutter.Parts[j].MarkupInfo.Foreground := DefaultAttrGutter.Foreground;
        ed.gutter.Parts[j].MarkupInfo.Style := DefaultAttrGutter.Styles;
        ed.gutter.Parts[j].MarkupInfo.EndUpdate;
      end;

      if (ed.gutter.Parts[j] is TSynGutterLineNumber) or
        (ed.gutter.Parts[j] is TSynGutterSeparator) then
      begin
        ed.gutter.Parts[j].MarkupInfo.BeginUpdate;
        ed.gutter.Parts[j].MarkupInfo.Background := SpecialAttrGutter.Background;
        ed.gutter.Parts[j].MarkupInfo.Foreground := SpecialAttrGutter.Foreground;
        ed.gutter.Parts[j].MarkupInfo.Style := SpecialAttrGutter.Styles;
        ed.gutter.Parts[j].MarkupInfo.EndUpdate;
      end;

      ed.InvalidateGutter;
      ed.invalidate;
    end;
  end;

end;

procedure TEditorFactory.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  {$IFDEF NEEDCLOSEBTN}
  r: TRect;
  h: Integer;
  {$ENDIF}
  i: integer;

begin
  if Button = mbMiddle then
  begin
    i := IndexOfTabAt(Point(X, Y));
    if i >= 0 then
      CloseEditor(TEditorTabSheet(Page[i]).Editor);
    Exit;
  end;
  if (Button = mbLeft) then
  begin
    i := IndexOfTabAt(Point(X, Y));
    {$IFDEF NEEDCLOSEBTN}
    r := TabRect(i);
    h := (r.Bottom - r.Top);
    if (X > r.right - h) and (Y > r.bottom - h) then
      begin
       CloseEditor(TEditorTabSheet(Page[i]).Editor);
       Invalidate;
      end
    else
    {$ENDIF}
      BeginDrag(False, 20);
  end;
end;

{$IFDEF NEEDCLOSEBTN}
procedure TEditorFactory.PaintWindow(DC: HDC);
var
  r: TRect;
  i, h, h2: integer;
  c: Tcanvas;
  offs:integer;
begin
  inherited PaintWindow(DC);
  c := TCanvas.Create;
  c.Handle := dc;
  offs := Scale96ToScreen(16);

  for i := 0 to PageCount - 1 do
  begin
    r := TabRect(i);
    h := (r.Bottom - r.Top - offs) div 2;
    h2 := offs + h;
    Images.DrawForPPI(c, r.Right - h2, r.Top + h, 7, 16, Screen.PixelsPerInch,1);
  end;
  c.Free;
end;

{$ENDIF}

procedure TEditorFactory.ShowHintEvent(Sender: TObject; HintInfo: PHintInfo);
var
  Tab: integer;

begin
  if (PageCount = 0) or (HintInfo = nil) then
    Exit;
  Tab := IndexOfTabAt(ScreenToClient(Mouse.CursorPos));

  if Tab < 0 then
    Exit;

  HintInfo^.HintStr := TEditorTabSheet(Pages[Tab]).Editor.FileName;

end;


constructor TEditorFactory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoubleBuffered := true;
  FWatcher := TFileWatcher.Create;
  FWatcher.OnFileStateChange := @OnFileChange;
  fUntitledCounter := 0;
  Options := Options + [nboShowCloseButtons];
  OnShowHint := @ShowHintEvent;
end;

destructor TEditorFactory.Destroy;
begin
  FWatcher.Free;
  inherited Destroy;
end;



end.
