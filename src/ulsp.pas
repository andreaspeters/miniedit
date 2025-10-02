unit uLSP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, RegExpr, Process, URIParser,
  syncobjs;
type
  TLSP = class(TThread)
  private
    Language: String;
    Init: Boolean;
    FileName: String;
    FilePath: String;
    FEvent: PRTLEvent;
    Pause: Boolean;
    InputStream: TMemoryStream;
    OutputStream: TMemoryStream;
    LSPServer: TProcess;
    StopIt: Boolean;
    procedure RunLSPServer;
    function Send(Params: TJSONObject; const method: String): TJSONData;
    function ReceiveData:String;
    function ExtractJSON(const s: string): string;
  protected
    procedure Execute; override;
  public
    ServerExec: String;
    ServerParameter: TStringList;
    ServerInitOptions: TJSONArray;
    ServerCR: String;
    Message: String;
    URI: String;
    LineNumber, CharacterNumber: Integer;
    MessageList: TStringList;
    OutputString: String;
    procedure Initialize(const AFilePath: String; const AWorkspacePath: String);
    procedure Initialized;
    procedure AddView(const AFileName: String);
    procedure OpenFile(const AFileName: String);
    procedure Reload;
    procedure Change(const Text: String);
    procedure Hover(const Line, Character: Integer);
    procedure Completion(const Line, Character, Trigger: Integer);
    procedure GoToDefinition(const Line, Character: Integer);
    procedure SetLanguage(const ALanguage: String);
    procedure Suspend;
    procedure Resume;
    procedure Stop;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TLSP.Create;
begin
  inherited Create(True);
  Init := False;
  FreeOnTerminate := False;
  Message := '';
  MessageList := TStringList.Create;
  ServerParameter := TStringList.Create;
  InputStream := TMemoryStream.Create;
  OutputStream := TMemoryStream.Create;
  FEvent := RTLEventCreate;
  Pause := False;
  StopIt := False;
end;

destructor TLSP.Destroy;
begin
  inherited Destroy;
end;

procedure TLSP.Stop;
begin
  if Assigned(LSPServer) then
  begin
    if LSPServer.Running then
      LSPServer.Terminate(1);
    StopIt := True;
  end;
end;

procedure TLSP.Execute;
var Response, Key, Value, tmpURI: String;
    ResponseJSON: TJSONObject;
    i: Integer;
begin
  try
    while (not StopIt) do
    begin
      if Pause then
        RTLEventWaitFor(FEvent);
      if not Assigned(LSPServer) then
      begin
        RTLEventWaitFor(FEvent);
        RunLSPServer;
        Continue
      end;
      if not LSPServer.Running then
      begin
        RTLEventWaitFor(FEvent);
        Continue;
      end;

      Response := ReceiveData;
      OutputString := Response;
      //writeln('>>>>>'+ ServerExec +'>>>>>>>>>>>>');
      //writeln(Response);
      //writeln('<<<<<<<<<<<<<<<<<');
      if Length(Response) > 0 then
      begin
        try
          if GetJSON(Response).JSONType = jtObject then
          begin
            ResponseJSON := TJSONObject(GetJSON(Response));
            if Assigned(ResponseJSON.FindPath('result.capabilities')) then
            begin
              Init := True;
              Initialized;
              AddView(FileName);
              Suspend;
            end;
            if Assigned(ResponseJSON.FindPath('method')) then
              if ResponseJSON.FindPath('method').AsString = 'window/logMessage' then
                if ResponseJSON.FindPath('params.type').AsInteger = 3 then
                  OpenFile(FileName);
            if Assigned(ResponseJSON.FindPath('result.contents.value')) then
            begin
              Message := ResponseJSON.FindPath('result.contents.value').AsString;
              Suspend;
            end;
            if Assigned(ResponseJSON.FindPath('result.items')) then
            begin
              if ResponseJSON.FindPath('result.items').Count > 0 then
                for i := 0 to ResponseJSON.FindPath('result.items').Count - 1 do
                begin
                  if Assigned(ResponseJSON.FindPath('result.items').Items[i].FindPath('label')) then
                    Key := ResponseJSON.FindPath('result.items').Items[i].FindPath('label').AsString;

                  if Assigned(ResponseJSON.FindPath('result.items').Items[i].FindPath('detail')) then
                    Value := ResponseJSON.FindPath('result.items').Items[i].FindPath('detail').AsString;
                  MessageList.Add(Key + '=' + Value);
                end;
              Suspend;
            end;
            if Assigned(ResponseJSON.FindPath('result')) then
              if Assigned(ResponseJSON.FindPath('result').Items[0]) then
                if Assigned(ResponseJSON.FindPath('result').Items[0].FindPath('uri')) then
                begin
                  tmpURI := ResponseJSON.FindPath('result').Items[0].FindPath('uri').AsString;
                  LineNumber := ResponseJSON.FindPath('result').Items[0].FindPath('range.start.line').AsInteger;
                  CharacterNumber := ResponseJSON.FindPath('result').Items[0].FindPath('range.start.character').AsInteger;
                  URIToFilename(tmpURI, URI);
                  Suspend;
                end;
          end;
        except
          on E: Exception do
            OutputString := 'JSON Error: ' + E.Message;
        end;
      end;
      sleep(10);
    end;
  except
    on E: Exception do
      OutputString := 'Receive LSP Data Error: ' + E.Message;
  end;
end;

procedure TLSP.Suspend;
begin
  Pause := True;
end;

procedure TLSP.Resume;
begin
  Pause := False;
  RTLEventSetEvent(FEvent);
end;

function TLSP.ReceiveData:String;
var Buffer: Byte;
    Line: String;
begin
  Result := '';

  if not LSPServer.Running then
    Exit;

  Line := '';
  Buffer := 0;

  repeat
    if Assigned(LSPServer.Output) then
      try
       Buffer := LSPServer.Output.ReadByte;
      except
        on E: Exception do
          OutputString := 'Exec LSP Error: ' + E.Message;
      end;

    Line := Line + Chr(Buffer);
  until Length(ExtractJSON(Line)) > 0;
  Result := ExtractJSON(Line);
end;


function TLSP.ExtractJSON(const s: string): string;
var
  i, startIndex, level: Integer;
  inString, escape: Boolean;
  ch: Char;
begin
  Result := '';
  level := 0;
  inString := False;
  escape := False;
  startIndex := 0;

  for i := 1 to Length(s) do
  begin
    ch := s[i];

    if inString then
    begin
      // Falls das vorherige Zeichen ein Escape war, überspringen wir die Prüfung
      if escape then
      begin
        escape := False;
        Continue;
      end;
      // Erkennen eines Escaped-Zeichens
      if ch = '\' then
      begin
        escape := True;
        Continue;
      end;
      // Ende des Strings
      if ch = '"' then
        inString := False;
    end
    else
    begin
      // Beginn einer Zeichenkette
      if ch = '"' then
      begin
        inString := True;
        Continue;
      end;
      // Start des JSON-Objekts
      if ch = '{' then
      begin
        if level = 0 then
          startIndex := i;
        Inc(level);
      end
      else if ch = '}' then
      begin
        Dec(level);
        // Wenn level wieder 0 erreicht, ist das JSON-Objekt vollständig
        if level = 0 then
        begin
          Result := Copy(s, startIndex, i - startIndex + 1);
          Exit;
        end;
      end;
    end;
  end;
  // Falls kein vollständiges JSON-Objekt gefunden wurde, bleibt Result leer.
end;


procedure TLSP.RunLSPServer;
var i: Integer;
begin
  if Length(ServerExec) <= 0 then
    Exit;

  LSPServer := TProcess.Create(nil);
  try
    LSPServer.Executable := ServerExec;
    LSPServer.Parameters := ServerParameter;

    for i := 0 to GetEnvironmentVariableCount - 1 do
    begin
      OutputString := OutputString + GetEnvironmentString(i) + #13#10;
      LSPServer.Environment.Add(GetEnvironmentString(i));
    end;

    LSPServer.Options := [poUsePipes, poNoConsole];
    LSPServer.Execute;
  except
    on E: Exception do
      OutputString := 'Exec LSP Server Error: ' + E.Message;
  end;
  Sleep(200);
end;

procedure TLSP.SetLanguage(const ALanguage: String);
var ext: String;
begin
  Language := '';
  {$IFDEF Windows}
    ext := '.exe';
  {$ELSE}
    ext := ''; // z. B. Linux, macOS
  {$ENDIF}

  case LowerCase(ALanguage) of
    'go':
    begin
     Language := 'go';
     ServerExec := 'gopls'+ext;
     ServerCR := #10;
    end;
    'python':
    begin
     Language := 'python';
     ServerExec := 'pylsp'+ext;
     ServerCR := #10;
    end;
    'c/c++':
    begin
     Language := 'c';
     ServerExec := 'ccls'+ext;
     ServerCR := #10;
    end;
    'pascal':
    begin
     Language := 'pascal';
     ServerExec := 'pasls'+ext;
     ServerCR := #13#10;
    end
  else
    Suspend;
  end;

  if Length(Language) > 0 then
    RunLSPServer;
end;

procedure TLSP.Initialize(const AFilePath: String; const AWorkspacePath: String);
var Params, FolderObject: TJSONObject;
    Folder: TJSONArray;
begin
  if (Length(AFilePath) <= 0) then
    Exit;

  FilePath := AFilePath;

  Params := TJSONObject.Create;

  // Einen WorkspaceFolder hinzufügen
  FolderObject := TJSONObject.Create;
  FolderObject.Add('uri', 'file://'+AWorkspacePath);
  FolderObject.Add('name', 'lsp');

  Folder := TJSONArray.Create;
  Folder.Add(FolderObject);

  Params.Add('rootUri', 'file://'+AFilePath);
  Params.Add('rootPath', FilePath);
  Params.Add('trace', 'on');
  Params.Add('workspaceFolders', Folder);



  if Assigned(ServerInitOptions) then
    Params.Add('initializationOptions', ServerInitOptions);

  Send(Params, 'initialize');
end;

procedure TLSP.Initialized;
var Params: TJSONObject;
begin
  Params := TJSONObject.Create;

  Send(Params, 'initialized');
end;

procedure TLSP.Reload;
var Params: TJSONObject;
    Changes: TJSONArray;
    FolderObject: TJSONObject;
begin
  if (Length(FileName) <= 0) then
    Exit;

  Params := TJSONObject.Create;
  Changes := TJSONArray.Create;

  // Einen WorkspaceFolder hinzufügen
  FolderObject := TJSONObject.Create;
  FolderObject.Add('uri', 'file://'+FileName);
  FolderObject.Add('type', 2);

  Changes.Add(FolderObject);
  Params.Add('changes', changes);

  Send(Params, 'workspace/didChangeWatchedFiles');
end;

procedure TLSP.Change(const Text: String);
var Params, TextDoc, FolderObject: TJSONObject;
    Changes: TJSONArray;

begin
  if (Length(FileName) <= 0) then
    Exit;

  Params := TJSONObject.Create;
  TextDoc := TJSONObject.Create;
  Changes := TJSONArray.Create;

  TextDoc.Add('uri', 'file://'+FileName);
  TextDoc.Add('version', 2);

  FolderObject := TJSONObject.Create;
  FolderObject.Add('text', Text);

  Changes.Add(FolderObject);
  Params.Add('textDocument', TextDoc);
  Params.Add('contentChanges', Changes);

  Send(Params, 'textDocument/didChange');
end;

procedure TLSP.AddView(const AFileName: String);
var Params: TJSONObject;
    Event: TJSONObject;
    Added: TJSONArray;
    FolderObject: TJSONObject;
begin
  if (Length(AFileName) <= 0) then
    Exit;

  FileName := AFileName;

  Params := TJSONObject.Create;
  Event := TJSONObject.Create;
  Added := TJSONArray.Create;

  // Einen WorkspaceFolder hinzufügen
  FolderObject := TJSONObject.Create;
  FolderObject.Add('uri', 'file://'+ExtractFilePath(FileName));
  FolderObject.Add('name', 'lsp');

  Added.Add(FolderObject);
  Event.Add('added', Added);
  Params.Add('event', Event);

  Send(Params, 'workspace/didChangeWorkspaceFolders');
end;

procedure TLSP.OpenFile(const AFileName: String);
var Params, TextDoc: TJSONObject;
    FileContent: String;
    StringList: TStringList;
begin
  if Length(AFileName) <= 0 then
    Exit;

  FileName := AFileName;

  try
    StringList := TStringList.Create;
    StringList.LoadFromFile(FileName);
    FileContent := StringList.Text;
  finally
    StringList.Free;
  end;

  Params := TJSONObject.Create;
  TextDoc := TJSONObject.Create;
  TextDoc.Add('uri', 'file://'+FileName);
  TextDoc.Add('text', FileContent);
  TextDoc.Add('languageID', Language);
  TextDoc.Add('version', 1);
  Params.Add('textDocument', TextDoc);

  Send(Params, 'textDocument/didOpen');
end;

procedure TLSP.Hover(const Line, Character: Integer);
var Params, TextDoc, Position: TJSONObject;
begin
  if Length(FileName) <= 0 then
    Exit;

  Params := TJSONObject.Create;
  TextDoc := TJSONObject.Create;
  Position := TJSONObject.Create;
  TextDoc.Add('uri', 'file://'+FileName);
  Position.Add('line', Line - 1 );
  Position.Add('character', Character - 1);

  Params.Add('textDocument', TextDoc);
  Params.Add('position', Position);

  Send(Params, 'textDocument/hover');
end;

procedure TLSP.Completion(const Line, Character, Trigger: Integer);
var Params, TextDoc, Position, Context: TJSONObject;
begin
  if Length(FileName) <= 0 then
    Exit;

  Params := TJSONObject.Create;
  TextDoc := TJSONObject.Create;
  Position := TJSONObject.Create;
  Context := TJSONObject.Create;
  TextDoc.Add('uri', 'file://'+FileName);
  Position.Add('line', Line - 1 );
  Position.Add('character', Character-1);
  Context.Add('triggerKind', Trigger);

  Params.Add('textDocument', TextDoc);
  Params.Add('position', Position);
  Params.Add('context', Context);

  Send(Params, 'textDocument/completion');
end;

procedure TLSP.GoToDefinition(const Line, Character: Integer);
var
  Params, TextDoc, Position: TJSONObject;
begin
  if Length(FileName) <= 0 then
    Exit;

  Params := TJSONObject.Create;
  TextDoc := TJSONObject.Create;
  Position := TJSONObject.Create;

  TextDoc.Add('uri', 'file://' + FileName);
  Position.Add('line', Line - 1);
  Position.Add('character', Character - 1);

  Params.Add('textDocument', TextDoc);
  Params.Add('position', Position);

  Send(Params, 'textDocument/definition');
end;

function TLSP.Send(Params: TJSONObject; const method: String): TJSONData;
var RequestText, SendString: string;
    RequestJSON: TJSONObject;
    Data: TBytes;
begin
  if not Assigned(LSPServer) then
    Exit;

  if not LSPServer.Running then
    Exit;

  Data := TBytes.Create;

  RequestJSON := TJSONObject.Create;
  try
    RequestJSON.Add('jsonrpc', '2.0');
    RequestJSON.Add('id', 1);
    RequestJSON.Add('method', method);
    RequestJSON.Add('params', Params);

    RequestText := RequestJSON.AsJSON;
    SendString := 'Content-Length: ' + IntToStr(Length(RequestText)+Length(ServerCR)) + ServerCR+ServerCR + RequestText + ServerCR;
    Data := TEncoding.UTF8.GetBytes(SendString);

    //writeln(SendString);

    InputStream.Clear;
    InputStream.Write(PChar(SendString)^, Length(SendString));
    InputStream.SaveToStream(LSPServer.Input);

  except
    on E: Exception do
      OutputString := 'Send Data Error: ' + E.Message;
  end;
  RequestJSON.Free;
  Result := nil;
end;

end.

