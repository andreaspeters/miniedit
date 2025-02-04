unit usettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ButtonPanel,
  Buttons, Config;

type

  { TFSettings }

  TFSettings = class(TForm)
    BPDefault: TButtonPanel;
    LEHexEditor: TLabeledEdit;
    LECompileCommand: TLabeledEdit;
    OPSelectFile: TOpenDialog;
    SPChooseDirectory: TSpeedButton;
    SPChooseDirectory1: TSpeedButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure ChooseCompileCommand(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ChooseHexEditor(Sender: TObject);
  private

  public

  end;

var
  FSettings: TFSettings;

implementation

{$R *.lfm}

{ TFSettings }

procedure TFSettings.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TFSettings.ChooseCompileCommand(Sender: TObject);
begin
  if OPSelectFile.Execute then
    LECompileCommand.Caption := OPSelectFile.FileName;
end;

procedure TFSettings.FormShow(Sender: TObject);
begin
  LEHexEditor.Caption := ConfigObj.HexEditor;
  LECompileCommand.Caption := ConfigObj.CompileCommand;
end;

procedure TFSettings.OKButtonClick(Sender: TObject);
begin
  ConfigObj.HexEditor := LEHexEditor.Caption;
  ConfigObj.CompileCommand := LECompileCommand.Caption;
  Close;
end;

procedure TFSettings.ChooseHexEditor(Sender: TObject);
begin
  if OPSelectFile.Execute then
    LEHexEditor.Caption := OPSelectFile.FileName;
end;

end.

