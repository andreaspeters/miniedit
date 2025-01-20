unit ushowlspmessage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel,
  LazHelpHTML, RichMemo, HtmlView, MarkdownProcessor, MarkdownUtils, LCLType;

type

  { TFLSPMessage }

  TFLSPMessage = class(TForm)
    HtmlViewer: THtmlViewer;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  private

  public
    Message: String;
  end;

var
  FLSPMessage: TFLSPMessage;

implementation

{$R *.lfm}

procedure TFLSPMessage.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
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
  markdown := TMarkdownProcessor.createDialect(mdCommonMark);
  HTMLViewer.Clear;
  HTMLViewer.DefFontName := Screen.SystemFont.Name;
  HTMLViewer.DefFontSize := Screen.SystemFont.Size;
  HTMLViewer.LoadFromString(markdown.Process(message));
end;

end.

