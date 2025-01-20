unit ushowlspmessage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel,
  LazHelpHTML, RichMemo, HtmlView, MarkdownProcessor, MarkdownUtils, LCLType;

type

  { TFLSPMessage }

  TFLSPMessage = class(TForm)
    BPDefaultButtons: TButtonPanel;
    HtmlViewer: THtmlViewer;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private

  public
    Message: String;
  end;

var
  FLSPMessage: TFLSPMessage;

implementation

{$R *.lfm}

procedure TFLSPMessage.CloseButtonClick(Sender: TObject);
begin
  ModalResult := mrClose;
end;

procedure TFLSPMessage.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TFLSPMessage.FormShow(Sender: TObject);
var markdown: TMarkdownProcessor;
begin
  markdown := TMarkdownProcessor.createDialect(mdCommonMark);
  HTMLViewer.DefFontName := Screen.SystemFont.Name;
  HTMLViewer.DefFontSize := Screen.SystemFont.Size;
  HTMLViewer.LoadFromString(markdown.Process(message));
end;

end.

