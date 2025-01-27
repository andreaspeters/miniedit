unit ushowlspmessage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Config,
  HtmlView, MarkdownProcessor, MarkdownUtils, LCLType, LCLIntf,
  ValEdit, Grids, StdCtrls, HtmlGlobals;

type

  { TFLSPMessage }

  TFLSPMessage = class(TForm)
    HtmlViewer: THtmlViewer;
    LSearchText: TLabel;
    VLECompletion: TValueListEditor;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseLeave(Sender: TObject);
    procedure HtmlViewerHotSpotClick(Sender: TObject; const SRC: ThtString;
      var Handled: Boolean);
    procedure ShowMessageList(const MessageList: TStringList);
    procedure ShowMessage(const Message: String);
  private
  public
    LSPKey: String;
  end;

var
  FLSPMessage: TFLSPMessage;
  FilterText: String;

implementation

{$R *.lfm}

procedure TFLSPMessage.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var i: Integer;
    KeyName: String;
    KeyChar: String;
begin
  if Key = VK_ESCAPE then
  begin
    HTMLViewer.Visible := False;
    VLECompletion.Visible := False;
    Close;
  end;
  if Key = VK_RETURN then
  begin
    LSPKey := VLECompletion.Cells[0, VLECompletion.Row];
    FilterText := '';
    ModalResult := mrOk;
  end;

  if Key = VK_BACK then
  begin
    Delete(FilterText, Length(FilterText), 1);
    LSearchText.Caption := FilterText;
    Exit;
  end;

  if Key in [VK_A..VK_Z, VK_0..VK_9] then
  begin
    KeyChar := LowerCase(Chr(Key));
    if ssShift in Shift then
      KeyChar := Chr(Key);

    FilterText := FilterText + KeyChar;
    LSearchText.Caption := FilterText;
    if VLECompletion.RowCount > 0 then
      for i := 1 to VLECompletion.RowCount - 1 do
      begin
          KeyName := VLECompletion.Cells[0, i];
          if Pos(FilterText, KeyName) = 1 then
          begin
            VLECompletion.Row := i;
            Exit;
          end;
      end;
  end;
end;

procedure TFLSPMessage.FormMouseLeave(Sender: TObject);
begin
  writeln('weg');
end;

procedure TFLSPMessage.HtmlViewerHotSpotClick(Sender: TObject;
  const SRC: ThtString; var Handled: Boolean);
begin
  if (SRC <> '') then
    OpenURL(SRC);
end;

procedure TFLSPMessage.ShowMessage(const Message: String);
var markdown: TMarkdownProcessor;
begin
  LSearchText.Caption := '';
  FilterText := '';
  HTMLViewer.Clear;
  VLECompletion.Clear;

  if Length(Message) > 0 then
  begin
    markdown := TMarkdownProcessor.createDialect(mdCommonMark);
    HTMLViewer.DefFontName := Screen.SystemFont.Name;
    HTMLViewer.DefFontSize := Screen.SystemFont.Size;
    HTMLViewer.LoadFromString(markdown.Process(message));
    HTMLViewer.Visible := True;
  end;
end;

procedure TFLSPMessage.ShowMessageList(const MessageList: TStringList);
begin
  LSearchText.Caption := '';
  FilterText := '';
  HTMLViewer.Clear;
  VLECompletion.Clear;

  if MessageList <> nil then
    if MessageList.Count > 0 then
    begin
      VLECompletion.Font := ConfigObj.Font;
      VLECompletion.Font.Size := ConfigObj.Font.Size - 1;
      VLECompletion.Visible := True;
      LSearchText.Visible := True;
      VLECompletion.Strings.Assign(MessageList);
      VLECompletion.Col := 0;
    end;
end;

end.


