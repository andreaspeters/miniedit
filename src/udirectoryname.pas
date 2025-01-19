unit udirectoryname;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ButtonPanel;

type

  { TFCreateDirectory }

  TFCreateDirectory = class(TForm)
    BPDefaultButtons: TButtonPanel;
    LEDirectoryName: TLabeledEdit;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LEDirectoryNameChange(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private

  public
    DirectoryName: String;
  end;

var
  FCreateDirectory: TFCreateDirectory;

implementation

{$R *.lfm}

{ TFCreateDirectory }

procedure TFCreateDirectory.OKButtonClick(Sender: TObject);
begin
  DirectoryName := LEDirectoryName.Caption;
  ModalResult := mrOk;
end;

procedure TFCreateDirectory.CancelButtonClick(Sender: TObject);
begin
  DirectoryName := '';
  ModalResult := mrCancel;
end;

procedure TFCreateDirectory.FormShow(Sender: TObject);
begin
  DirectoryName := '';
  LEDirectoryName.Caption := '';
end;

procedure TFCreateDirectory.LEDirectoryNameChange(Sender: TObject);
begin
  if Length(LEDirectoryName.Caption) > 0 then
    BPDefaultButtons.OKButton.Enabled := True
  else
    BPDefaultButtons.OKButton.Enabled := False;
end;

end.

