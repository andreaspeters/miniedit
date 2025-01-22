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
    OPSelectFile: TOpenDialog;
    SPChooseDirectory: TSpeedButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure SPChooseDirectoryClick(Sender: TObject);
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

procedure TFSettings.FormShow(Sender: TObject);
begin
  LEHexEditor.Caption := ConfigObj.HexEditor;
end;

procedure TFSettings.OKButtonClick(Sender: TObject);
begin
  ConfigObj.HexEditor := LEHexEditor.Caption;
  Close;
end;

procedure TFSettings.SPChooseDirectoryClick(Sender: TObject);
begin
  if OPSelectFile.Execute then
    LEHexEditor.Caption := OPSelectFile.FileName;
end;

end.

