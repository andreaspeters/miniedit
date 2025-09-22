{$I codegen.inc}
{$M+}
unit uai;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ButtonPanel,
  IdHTTP, IdGlobal, config, fpjson, jsonparser, uEditor, ExtCtrls;

type
  TfAI = class;
  TAIThread = class;

type

  { TfAI }
  TfAI = class(TForm)
    bpDefaultButton: TButtonPanel;
    MAIMessage: TMemo;
    AI: TAIThread;
    Editor: TEditor;
    PaintBox1: TPaintBox;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
  public
  end;

  { TAIThread }
  TAIThread = class(TThread)
  private
    FIdHTTP: TIdHTTP;
    FURL: String;
    FMessageQueue: TThreadList; // Warteschlange (enthält PString)
    procedure ProcessJSONMessage(const AJSON: String);
    function BuildJSONMessage(const msg: String): TJSONObject;
  protected
    procedure Execute; override;
  public
    Editor: TEditor;
    constructor Create;
    destructor Destroy; override;
    /// Reihte eine Nachricht zur asynchronen Verarbeitung ein
    procedure SendMessage(const msg: String);
  end;

var
  fAI: TfAI;

implementation

uses
  umain;

{$R *.lfm}

{ TfAI }

procedure TfAI.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TfAI.FormShow(Sender: TObject);
begin
  MAIMessage.Clear;
  MAIMessage.SetFocus;
  MAIMessage.Text := Editor.SelText;
end;

procedure TfAI.OKButtonClick(Sender: TObject);
begin
  AI := TAIThread.Create;

  AI.Editor := Editor;
  AI.Start;
  AI.SendMessage(MAIMessage.Text);

  Close;
end;



{ TAIThread }

constructor TAIThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := True;

  FIdHTTP := TIdHTTP.Create;
  FIdHTTP.ConnectTimeout := 5000; // 5 Sekunden
  FIdHTTP.ReadTimeout := 30000;   // 30 Sekunden
  FIdHTTP.Request.ContentType := 'application/json';

  FURL := Format('http://%s:%s/api/generate', [ConfigObj.OllamaHostname, ConfigObj.OllamaPort]);

  FMessageQueue := TThreadList.Create;
end;

destructor TAIThread.Destroy;
begin
  FreeAndNil(FIdHTTP);
  FreeAndNil(FMessageQueue);
  inherited Destroy;
end;

procedure TAIThread.ProcessJSONMessage(const AJSON: string);
var ResponseJSON: TJSONObject;
    tmp: String;
begin
  ResponseJSON := TJSONObject(GetJSON(AJSON));
  if Assigned(ResponseJSON.FindPath('response')) then
  begin
    if Length(ResponseJSON.FindPath('response').AsString) > 0 then
    begin
      tmp := ResponseJSON.FindPath('response').ASString;
      Editor.SelText := tmp;
    end;
  end;

  Terminate;
end;

function TAIThread.BuildJSONMessage(const msg: String): TJSONObject;
var FJSON: TJSONObject;
begin
  FJSON := TJSONObject.Create;
  FJSON.Add('model', ConfigObj.OllamaModel);
  FJSON.Add('stream', False);
  FJSON.Add('prompt', msg);
  FJSON.Add('Think', True);

  Result := FJSON;
end;

procedure TAIThread.SendMessage(const msg: String);
var
  msgPtr: PString;
begin
  New(msgPtr);
  msgPtr^ := msg;
  FMessageQueue.Add(msgPtr);
end;

procedure TAIThread.Execute;
var list: TList;
    i: Integer;
    msgPtr: PString;
    json: TJSONObject;
    PostData: TStringStream;
    Response: string;
begin
  while not Terminated do
  begin
    list := FMessageQueue.LockList;
    try
      i := 0;
      while i < list.Count do
      begin
        msgPtr := PString(list[i]);

        list.Delete(i);
        json := BuildJSONMessage(msgPtr^);
        try
          PostData := TStringStream.Create(json.AsJSON, TEncoding.UTF8);
          try
            Response := FIdHTTP.Post(FURL, PostData);
            ProcessJSONMessage(Response);
          finally
            PostData.Free;
          end;
        finally
          json.Free;
          Dispose(msgPtr);
        end;
      end;
    finally
      FMessageQueue.UnlockList;
    end;
    Sleep(50); // Kurze Pause, um CPU zu schonen
  end;
end;

end.

