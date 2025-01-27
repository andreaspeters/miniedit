{$I codegen.inc}
unit UCmd;

interface

uses
  Classes, SysUtils, Controls, Menus, uCmdBox;

type
  TCmd = class(TCmdBox)
  private
    FPopupMenu: TPopupMenu;
    procedure CreatePopupMenu;
    procedure cmdBoxClose(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  umain;

{ TCmd }

constructor TCmd.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreatePopupMenu;
end;

destructor TCmd.Destroy;
begin
  FPopupMenu.Free;
  inherited Destroy;
end;

procedure TCmd.CreatePopupMenu;
var
  miClose: TMenuItem;
begin
  FPopupMenu := TPopupMenu.Create(Self);
  FPopupMenu.Images := fMain.imgListSmall;

  // Menuitem "Close"
  miClose := TMenuItem.Create(FPopupMenu);
  miClose.Caption := 'Close CMD';
  miClose.ImageIndex := 11;
  miClose.OnClick := @cmdBoxClose;

  FPopupMenu.Items.Add(miClose);

  PopupMenu := FPopupMenu;
end;

procedure TCmd.cmdBoxClose(Sender: TObject);
begin
  Visible := False;
end;

end.

