unit ushowlspmessage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel,
  LazHelpHTML, RichMemo, HtmlView, MarkdownProcessor, MarkdownUtils, LCLType,
  ValEdit, Grids;

type

  { TFLSPMessage }

  TFLSPMessage = class(TForm)
    HtmlViewer: THtmlViewer;
    VLECompletion: TValueListEditor;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure VLECompletionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

  public
    Message: String;
    MessageList: TStringList;
    LSPKey: String;
  end;

var
  FLSPMessage: TFLSPMessage;

implementation

{$R *.lfm}

procedure TFLSPMessage.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    HTMLViewer.Visible := False;
    VLECompletion.Visible := False;
    Close;
  end;
end;

procedure TFLSPMessage.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var MouseX, MouseY: Integer;
begin
  MouseX := Mouse.CursorPos.X;
  MouseY := Mouse.CursorPos.Y;

  if not (MouseX > Left) or not (MouseX < Left + Width) or not (MouseY > Top) or not (MouseY < Top + Height) then
  begin
    Close;
  end;
end;

procedure TFLSPMessage.FormShow(Sender: TObject);
var markdown: TMarkdownProcessor;
begin
  if Length(message) > 0 then
  begin
    markdown := TMarkdownProcessor.createDialect(mdCommonMark);
    HTMLViewer.Clear;
    HTMLViewer.DefFontName := Screen.SystemFont.Name;
    HTMLViewer.DefFontSize := Screen.SystemFont.Size;
    HTMLViewer.LoadFromString(markdown.Process(message));
    HTMLViewer.Visible := True;
  end;

  if MessageList.Count > 0 then
  begin
    VLECompletion.Strings.Assign(MessageList);
    VLECompletion.Visible := True;
  end;
end;

procedure TFLSPMessage.VLECompletionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    LSPKey := VLECompletion.Cells[0, VLECompletion.Row];
    ModalResult := mrOk;
  end;
end;

end.

