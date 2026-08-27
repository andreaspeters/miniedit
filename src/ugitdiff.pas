unit ugitdiff;

{$mode objfpc}{$H+}

{$R *.lfm}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics, Process, SynEdit, StdCtrls,
  SynEditTypes, LResources;

type
  TGitDiffView = class(TPanel)
  published
    FLeftEditor: TSynEdit;
    FRightEditor: TSynEdit;
    FSplitter: TSplitter;
    FMinimap: TPaintBox;
  private
    FLeftChanged: TBits;
    FRightChanged: TBits;
    FSyncingScroll: Boolean;
    FUpdatingLayout: Boolean;
    FMinimapDragging: Boolean;
    procedure LeftStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure RightStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure LeftSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure RightSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure MinimapPaint(Sender: TObject);
    procedure MinimapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MinimapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MinimapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrollToMinimapPosition(Y: Integer);
    procedure InvalidateMinimap;
    procedure ConfigureEditor(Editor: TSynEdit);
    function RunGit(const WorkingDir: String; const Parameters: array of String;
      out Output: String): Boolean;
    function GetRepositoryRoot(const FileName: String): String;
    function GetRepositoryFileName(const Root, FileName: String): String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Resize; override;
    procedure ShowDiff(const FileName: String);
    procedure EqualColumns;
  end;

implementation

type
  TDiffStringArray = array of String;
  TDiffIntegerArray = array of Integer;
  TDiffMatrix = array of TDiffIntegerArray;

constructor TGitDiffView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if not InitInheritedComponent(Self, TPanel) then
    raise EComponentError.Create('Unable to load the TGitDiffView form resource');

  FLeftChanged := TBits.Create;
  FRightChanged := TBits.Create;
  ConfigureEditor(FLeftEditor);
  ConfigureEditor(FRightEditor);
  FLeftEditor.OnSpecialLineColors := @LeftSpecialLineColors;
  FLeftEditor.OnStatusChange := @LeftStatusChange;
  FRightEditor.OnSpecialLineColors := @RightSpecialLineColors;
  FRightEditor.OnStatusChange := @RightStatusChange;
  FMinimap.OnPaint := @MinimapPaint;
  FMinimap.OnMouseDown := @MinimapMouseDown;
  FMinimap.OnMouseMove := @MinimapMouseMove;
  FMinimap.OnMouseUp := @MinimapMouseUp;
end;

procedure TGitDiffView.Resize;
begin
  inherited Resize;
  EqualColumns;
end;

procedure TGitDiffView.LeftStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if FSyncingScroll or
    not ((scTopLine in Changes) or (scLeftChar in Changes)) then
    Exit;
  FSyncingScroll := True;
  try
    if scTopLine in Changes then
      FRightEditor.TopLine := FLeftEditor.TopLine;
    if scLeftChar in Changes then
      FRightEditor.LeftChar := FLeftEditor.LeftChar;
  finally
    FSyncingScroll := False;
  end;
end;

procedure TGitDiffView.RightStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if FSyncingScroll or
    not ((scTopLine in Changes) or (scLeftChar in Changes)) then
    Exit;
  FSyncingScroll := True;
  try
    if scTopLine in Changes then
      FLeftEditor.TopLine := FRightEditor.TopLine;
    if scLeftChar in Changes then
      FLeftEditor.LeftChar := FRightEditor.LeftChar;
  finally
    FSyncingScroll := False;
  end;
end;

procedure TGitDiffView.InvalidateMinimap;
begin
  if Assigned(FMinimap) then
    FMinimap.Invalidate;
end;

procedure TGitDiffView.MinimapPaint(Sender: TObject);
var
  I, Total, Y, TopY, BottomY: Integer;
begin
  Total := FLeftChanged.Size;
  FMinimap.Canvas.Brush.Color := clBtnFace;
  FMinimap.Canvas.FillRect(FMinimap.ClientRect);
  if (Total = 0) or (FMinimap.ClientHeight = 0) then Exit;
  for I := 0 to Total - 1 do
  begin
    Y := (I * FMinimap.ClientHeight) div Total;
    if FLeftChanged[I] then
    begin
      FMinimap.Canvas.Pen.Color := RGBToColor(210, 80, 80);
      FMinimap.Canvas.Line(1, Y, (FMinimap.ClientWidth div 2) - 1, Y);
    end;
    if FRightChanged[I] then
    begin
      FMinimap.Canvas.Pen.Color := RGBToColor(70, 170, 90);
      FMinimap.Canvas.Line(FMinimap.ClientWidth div 2, Y, FMinimap.ClientWidth - 2, Y);
    end;
  end;
  TopY := ((FLeftEditor.TopLine - 1) * FMinimap.ClientHeight) div Total;
  BottomY := ((FLeftEditor.TopLine + 20) * FMinimap.ClientHeight) div Total;
  FMinimap.Canvas.Brush.Style := bsClear;
  FMinimap.Canvas.Pen.Color := clGray;
  FMinimap.Canvas.Rectangle(0, TopY, FMinimap.ClientWidth - 1, BottomY);
  FMinimap.Canvas.Brush.Style := bsSolid;
end;

procedure TGitDiffView.ScrollToMinimapPosition(Y: Integer);
var
  Total, Target: Integer;
begin
  Total := FLeftChanged.Size;
  if (Total = 0) or (FMinimap.ClientHeight = 0) then Exit;
  Target := 1 + ((Y * Total) div FMinimap.ClientHeight) - 10;
  if Target < 1 then Target := 1;
  if Target > Total then Target := Total;
  FSyncingScroll := True;
  try
    FLeftEditor.TopLine := Target;
    FRightEditor.TopLine := Target;
  finally
    FSyncingScroll := False;
  end;
  InvalidateMinimap;
end;

procedure TGitDiffView.MinimapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMinimapDragging := Button = mbLeft;
  if FMinimapDragging then ScrollToMinimapPosition(Y);
end;

procedure TGitDiffView.MinimapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FMinimapDragging and (ssLeft in Shift) then ScrollToMinimapPosition(Y);
end;

procedure TGitDiffView.MinimapMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then FMinimapDragging := False;
end;

procedure TGitDiffView.EqualColumns;
var
  AvailableWidth, ColumnWidth: Integer;
begin
  if FUpdatingLayout or not Assigned(FLeftEditor) or not Assigned(FSplitter) then
    Exit;
  AvailableWidth := ClientWidth - FSplitter.Width;
  ColumnWidth := AvailableWidth div 2;
  if ColumnWidth > 0 then
  begin
    FUpdatingLayout := True;
    try
      FLeftEditor.Width := ColumnWidth;
    finally
      FUpdatingLayout := False;
    end;
  end;
end;

destructor TGitDiffView.Destroy;
begin
  FLeftChanged.Free;
  FRightChanged.Free;
  inherited Destroy;
end;

procedure TGitDiffView.ConfigureEditor(Editor: TSynEdit);
begin
  Editor.ReadOnly := True;
  Editor.Options := [eoBracketHighlight, eoGroupUndo, eoScrollPastEol];
  Editor.Gutter.Visible := True;
  Editor.Font.Quality := fqCleartypeNatural;
end;

function TGitDiffView.RunGit(const WorkingDir: String;
  const Parameters: array of String; out Output: String): Boolean;
const
  ReadBufferSize = 8192;
  MaxGitRuntimeMs = 10000;
var
  Git: TProcess;
  Buffer: TStringList;
  OutputStream: TMemoryStream;
  ReadBuffer: array[0..ReadBufferSize - 1] of Byte;
  BytesRead: Integer;
  StartTick: QWord;
  TimedOut: Boolean;
  I: Integer;
begin
  Output := '';
  Result := False;
  TimedOut := False;
  Buffer := TStringList.Create;
  OutputStream := TMemoryStream.Create;
  Git := TProcess.Create(nil);
  try
    Git.Executable := 'git';
    Git.CurrentDirectory := WorkingDir;
    for I := Low(Parameters) to High(Parameters) do
      Git.Parameters.Add(Parameters[I]);
    Git.Options := [poUsePipes, poStderrToOutPut];
    try
      Git.Execute;
      StartTick := GetTickCount64;
      while Git.Running do
      begin
        while Git.Output.NumBytesAvailable > 0 do
        begin
          BytesRead := Git.Output.Read(ReadBuffer, SizeOf(ReadBuffer));
          if BytesRead <= 0 then
            Break;
          OutputStream.WriteBuffer(ReadBuffer, BytesRead);
        end;
        if GetTickCount64 - StartTick >= MaxGitRuntimeMs then
        begin
          TimedOut := True;
          Git.Terminate(1);
          Break;
        end;
        Sleep(1);
      end;
      while Git.Output.NumBytesAvailable > 0 do
      begin
        BytesRead := Git.Output.Read(ReadBuffer, SizeOf(ReadBuffer));
        if BytesRead <= 0 then
          Break;
        OutputStream.WriteBuffer(ReadBuffer, BytesRead);
      end;
      OutputStream.Position := 0;
      Buffer.LoadFromStream(OutputStream);
      Output := Buffer.Text;
      Result := not TimedOut and (Git.ExitStatus = 0);
    except
      Result := False;
    end;
  finally
    Git.Free;
    OutputStream.Free;
    Buffer.Free;
  end;
end;

function TGitDiffView.GetRepositoryRoot(const FileName: String): String;
var
  Output: String;
  Directory: String;
begin
  Result := '';
  Directory := ExtractFileDir(ExpandFileName(FileName));
  if RunGit(Directory, ['rev-parse', '--show-toplevel'], Output) then
    Result := Trim(Output);
end;

function TGitDiffView.GetRepositoryFileName(const Root, FileName: String): String;
begin
  Result := ExtractRelativePath(IncludeTrailingPathDelimiter(Root),
    ExpandFileName(FileName));
  Result := StringReplace(Result, PathDelim, '/', [rfReplaceAll]);
end;

procedure TGitDiffView.LeftSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
begin
  if (Line > 0) and (Line <= FLeftChanged.Size) and FLeftChanged[Line - 1] then
  begin
    Special := True;
    BG := RGBToColor(255, 220, 220);
    FG := clBlack;
  end;
end;

procedure TGitDiffView.RightSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
begin
  if (Line > 0) and (Line <= FRightChanged.Size) and FRightChanged[Line - 1] then
  begin
    Special := True;
    BG := RGBToColor(220, 255, 220);
    FG := clBlack;
  end;
end;

function NormalizeDiffLine(const Value: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Value) do
    if not (Value[I] in [' ', #9, #10, #13]) then
      Result := Result + Value[I];
end;

procedure BuildDiffSequence(const Lines: TStringList;
  out Values: TDiffStringArray; out LineNumbers: TDiffIntegerArray);
var
  I, Count: Integer;
  Normalized: String;
begin
  Count := 0;
  SetLength(Values, Lines.Count);
  SetLength(LineNumbers, Lines.Count);
  for I := 0 to Lines.Count - 1 do
  begin
    Normalized := NormalizeDiffLine(Lines[I]);
    if Normalized = '' then
      Continue;
    Values[Count] := Normalized;
    LineNumbers[Count] := I;
    Inc(Count);
  end;
  SetLength(Values, Count);
  SetLength(LineNumbers, Count);
end;

procedure TGitDiffView.ShowDiff(const FileName: String);
var
  Root, RelativeName, OldText: String;
  CurrentLines, OldLines: TStringList;
  LeftText, RightText: TStringList;
  OldSequence, CurrentSequence: TDiffStringArray;
  OldNumbers, CurrentNumbers: TDiffIntegerArray;
  LCS: TDiffMatrix;
  I, J, OldCount, CurrentCount, FallbackCount: Integer;
  CurrentExists: Boolean;
const
  MaxLCSCells: Int64 = 4000000;
begin
  Root := GetRepositoryRoot(FileName);
  OldText := '';
  if Root <> '' then
  begin
    RelativeName := GetRepositoryFileName(Root, FileName);
    RunGit(Root, ['show', 'HEAD:' + RelativeName], OldText);
  end;

  OldLines := TStringList.Create;
  CurrentLines := TStringList.Create;
  LeftText := TStringList.Create;
  RightText := TStringList.Create;
  try
    OldLines.Text := OldText;
    CurrentExists := FileExists(FileName);
    if CurrentExists then
      CurrentLines.LoadFromFile(FileName);

    BuildDiffSequence(OldLines, OldSequence, OldNumbers);
    BuildDiffSequence(CurrentLines, CurrentSequence, CurrentNumbers);
    OldCount := Length(OldSequence);
    CurrentCount := Length(CurrentSequence);
    FLeftChanged.Size := 0;
    FRightChanged.Size := 0;
    if Int64(OldCount) * Int64(CurrentCount) > MaxLCSCells then
    begin
      FallbackCount := OldLines.Count;
      if CurrentLines.Count > FallbackCount then
        FallbackCount := CurrentLines.Count;
      for I := 0 to FallbackCount - 1 do
      begin
        if I < OldLines.Count then
          LeftText.Add(OldLines[I])
        else
          LeftText.Add('');
        if I < CurrentLines.Count then
          RightText.Add(CurrentLines[I])
        else
          RightText.Add('');
        FLeftChanged.Size := FLeftChanged.Size + 1;
        FRightChanged.Size := FRightChanged.Size + 1;
        FLeftChanged[FLeftChanged.Size - 1] := False;
        FRightChanged[FRightChanged.Size - 1] := False;
        if (I >= OldLines.Count) or (I >= CurrentLines.Count) or
          (NormalizeDiffLine(OldLines[I]) <> NormalizeDiffLine(CurrentLines[I])) then
        begin
          FLeftChanged[FLeftChanged.Size - 1] := True;
          FRightChanged[FRightChanged.Size - 1] := True;
        end;
      end
    end
    else
    begin
      SetLength(LCS, OldCount + 1);
      for I := 0 to OldCount do
        SetLength(LCS[I], CurrentCount + 1);
      for I := OldCount - 1 downto 0 do
        for J := CurrentCount - 1 downto 0 do
          if OldSequence[I] = CurrentSequence[J] then
            LCS[I][J] := LCS[I + 1][J + 1] + 1
          else if LCS[I + 1][J] >= LCS[I][J + 1] then
            LCS[I][J] := LCS[I + 1][J]
          else
            LCS[I][J] := LCS[I][J + 1];

      I := 0;
      J := 0;
      while (I < OldCount) or (J < CurrentCount) do
      begin
        if (I < OldCount) and (J < CurrentCount) and
          (OldSequence[I] = CurrentSequence[J]) then
        begin
          LeftText.Add(OldLines[OldNumbers[I]]);
          RightText.Add(CurrentLines[CurrentNumbers[J]]);
          FLeftChanged.Size := FLeftChanged.Size + 1;
          FRightChanged.Size := FRightChanged.Size + 1;
          FLeftChanged[FLeftChanged.Size - 1] := False;
          FRightChanged[FRightChanged.Size - 1] := False;
          Inc(I);
          Inc(J);
        end
        else if (J < CurrentCount) and
          ((I >= OldCount) or (LCS[I][J + 1] >= LCS[I + 1][J])) then
        begin
          LeftText.Add('');
          RightText.Add(CurrentLines[CurrentNumbers[J]]);
          FLeftChanged.Size := FLeftChanged.Size + 1;
          FRightChanged.Size := FRightChanged.Size + 1;
          FLeftChanged[FLeftChanged.Size - 1] := False;
          FRightChanged[FRightChanged.Size - 1] := False;
          FRightChanged[FRightChanged.Size - 1] := True;
          Inc(J);
        end
        else
        begin
          LeftText.Add(OldLines[OldNumbers[I]]);
          RightText.Add('');
          FLeftChanged.Size := FLeftChanged.Size + 1;
          FRightChanged.Size := FRightChanged.Size + 1;
          FLeftChanged[FLeftChanged.Size - 1] := False;
          FRightChanged[FRightChanged.Size - 1] := False;
          FLeftChanged[FLeftChanged.Size - 1] := True;
          Inc(I);
        end;
      end;
    end;

    FLeftEditor.Lines.Assign(LeftText);
    FRightEditor.Lines.Assign(RightText);
    FLeftEditor.TopLine := 1;
    FRightEditor.TopLine := 1;
    FLeftEditor.Invalidate;
    FRightEditor.Invalidate;
    EqualColumns;
  finally
    OldLines.Free;
    CurrentLines.Free;
    LeftText.Free;
    RightText.Free;
  end;
end;

initialization
  RegisterClass(TLabel);
  RegisterClass(TSynEdit);
  RegisterClass(TSplitter);
  RegisterClass(TPaintBox);

end.
