unit ugitdiff;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics, Process, SynEdit, StdCtrls,
  SynEditTypes;

type
  TGitDiffView = class(TPanel)
  private
    FLeftEditor: TSynEdit;
    FRightEditor: TSynEdit;
    FSplitter: TSplitter;
    FTitleLabel: TLabel;
    FLeftChanged: TBits;
    FRightChanged: TBits;
    FSyncingScroll: Boolean;
    procedure LeftStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure RightStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure LeftSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure RightSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure ConfigureEditor(Editor: TSynEdit);
    function RunGit(const WorkingDir: String; const Parameters: array of String;
      out Output: String): Boolean;
    function GetRepositoryRoot(const FileName: String): String;
    function GetRepositoryFileName(const Root, FileName: String): String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowDiff(const FileName: String);
    procedure EqualColumns;
  end;

implementation

constructor TGitDiffView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alClient;
  BevelOuter := bvNone;
  Caption := '';

  FLeftChanged := TBits.Create;
  FRightChanged := TBits.Create;

  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent := Self;
  FTitleLabel.Align := alTop;
  FTitleLabel.Height := 24;
  FTitleLabel.Layout := tlCenter;
  FTitleLabel.BorderSpacing.Left := 8;
  FTitleLabel.Caption := 'Diff';

  FLeftEditor := TSynEdit.Create(Self);
  ConfigureEditor(FLeftEditor);
  FLeftEditor.Parent := Self;
  FLeftEditor.OnSpecialLineColors := @LeftSpecialLineColors;
  FLeftEditor.OnStatusChange := @LeftStatusChange;

  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Width := 4;

  FRightEditor := TSynEdit.Create(Self);
  ConfigureEditor(FRightEditor);
  FRightEditor.Parent := Self;
  FRightEditor.OnSpecialLineColors := @RightSpecialLineColors;
  FRightEditor.OnStatusChange := @RightStatusChange;
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

procedure TGitDiffView.EqualColumns;
var
  TopOffset, AvailableWidth, ColumnWidth, AvailableHeight: Integer;
begin
  if not Assigned(FLeftEditor) or not Assigned(FRightEditor) or
    not Assigned(FSplitter) then
    Exit;
  TopOffset := FTitleLabel.Height;
  AvailableWidth := ClientWidth - FSplitter.Width;
  ColumnWidth := AvailableWidth div 2;
  AvailableHeight := ClientHeight - TopOffset;
  if (ColumnWidth <= 0) or (AvailableHeight <= 0) then
    Exit;
  FLeftEditor.SetBounds(0, TopOffset, ColumnWidth, AvailableHeight);
  FSplitter.SetBounds(ColumnWidth, TopOffset, FSplitter.Width, AvailableHeight);
  FRightEditor.SetBounds(ColumnWidth + FSplitter.Width, TopOffset,
    AvailableWidth - ColumnWidth, AvailableHeight);
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
var
  Git: TProcess;
  Buffer: TStringList;
  I: Integer;
begin
  Output := '';
  Result := False;
  Buffer := TStringList.Create;
  Git := TProcess.Create(nil);
  try
    Git.Executable := 'git';
    Git.CurrentDirectory := WorkingDir;
    for I := Low(Parameters) to High(Parameters) do
      Git.Parameters.Add(Parameters[I]);
    Git.Options := [poUsePipes, poWaitOnExit, poStderrToOutPut];
    try
      Git.Execute;
      Buffer.LoadFromStream(Git.Output);
      Output := Buffer.Text;
      Result := Git.ExitStatus = 0;
    except
      Result := False;
    end;
  finally
    Git.Free;
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

procedure TGitDiffView.ShowDiff(const FileName: String);
var
  Root, RelativeName, OldText: String;
  CurrentLines, OldLines: TStringList;
  LeftText, RightText: TStringList;
  I, MaxLines: Integer;
  CurrentExists, OldAvailable: Boolean;
begin
  FTitleLabel.Caption := 'Diff - ' + ExtractFileName(FileName);
  Root := GetRepositoryRoot(FileName);
  OldText := '';
  OldAvailable := False;
  if Root <> '' then
  begin
    RelativeName := GetRepositoryFileName(Root, FileName);
    OldAvailable := RunGit(Root, ['show', 'HEAD:' + RelativeName], OldText);
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

    MaxLines := OldLines.Count;
    if CurrentLines.Count > MaxLines then
      MaxLines := CurrentLines.Count;
    if not OldAvailable then
      OldLines.Insert(0, 'HEAD-Version nicht verfügbar: ' + OldText);
    if not CurrentExists then
      CurrentLines.Insert(0, 'Datei nicht gefunden: ' + FileName);

    MaxLines := OldLines.Count;
    if CurrentLines.Count > MaxLines then
      MaxLines := CurrentLines.Count;
    FLeftChanged.Size := MaxLines;
    FRightChanged.Size := MaxLines;

    for I := 0 to MaxLines - 1 do
    begin
      if I < OldLines.Count then
        LeftText.Add(OldLines[I])
      else
        LeftText.Add('');
      if I < CurrentLines.Count then
        RightText.Add(CurrentLines[I])
      else
        RightText.Add('');
      if (I >= OldLines.Count) or (I >= CurrentLines.Count) or
        (OldLines[I] <> CurrentLines[I]) then
      begin
        FLeftChanged[I] := I < OldLines.Count;
        FRightChanged[I] := I < CurrentLines.Count;
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

end.
