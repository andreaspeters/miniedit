{$I codegen.inc}
{$M+}
unit uai;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ButtonPanel,
  IdHTTP, IdGlobal, config, fpjson, jsonparser, uEditor;

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
    function ProcessText(const InputText: String): String;
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
begin
  ResponseJSON := TJSONObject(GetJSON(AJSON));
  if Assigned(ResponseJSON.FindPath('response')) then
    Editor.SelText := ProcessText(ResponseJSON.FindPath('response').AsString);

  Terminate;
end;

function TAIThread.ProcessText(const InputText: string): string;
var
  Lines, OutputLines: TStringList;
  i: Integer;
  InCodeBlock: Boolean;
  CurrentLine: string;
begin
  Lines := TStringList.Create;
  OutputLines := TStringList.Create;
  try
    Lines.Text := InputText;
    InCodeBlock := False;
    for i := 0 to Lines.Count - 1 do
    begin
      CurrentLine := Lines[i];
      // Falls die Zeile mit ``` beginnt, schalten wir den Code-Modus um
      if Pos('```', CurrentLine) = 1 then
      begin
        InCodeBlock := not InCodeBlock;
        // Die Zeile mit ``` wird nicht in das Ergebnis übernommen
        Continue;
      end;
      // Liegt der Text außerhalb eines Code-Blocks, wird ein Kommentarpräfix gesetzt
      if InCodeBlock then
        OutputLines.Add(CurrentLine);
    end;
    Result := OutputLines.Text;
  finally
    Lines.Free;
    OutputLines.Free;
  end;
end;


function TAIThread.BuildJSONMessage(const msg: String): TJSONObject;
var FJSON: TJSONObject;
begin
  FJSON := TJSONObject.Create;
  FJSON.Add('model', ConfigObj.OllamaModel);
  FJSON.Add('stream', False);
  FJSON.Add('prompt', msg);

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

