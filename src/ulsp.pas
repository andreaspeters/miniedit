unit uLSP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, Sockets, netdb, baseunix, RegExpr, Process;
type
  TLSP = class(TThread)
  private
    Language: String;
    Init: Boolean;
    HoverSupport: Boolean;
    Connected: Boolean;
    FSocket: TSocket;
    FileName: String;
    FilePath: String;
    procedure Connect;
    procedure RunLSPServer;
    function Send(Params: TJSONObject; const method: String): TJSONData;
    function ReceiveDataUntilZero:String;
  protected
    procedure Execute; override;
  public
    ServerPort: Integer;
    ServerExec: String;
    ServerParameter: TStringList;
    Message: String;
    MessageList: TStringList;
    procedure Initialize(const AFilePath: String);
    procedure Initialized;
    procedure AddView(const AFileName: String);
    procedure OpenFile(const AFileName: String);
    procedure Hover(const Line, Character: Integer);
    procedure Completion(const Line, Character: Integer);
    procedure SetLanguage(const ALanguage: String);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TLSP.Create;
begin
  inherited Create(True);
  Init := False;
  Stop := False;
  HoverSupport := False;
  FreeOnTerminate := True;
  MessageList := TStringList.Create;
  ServerParameter := TStringList.Create;
end;

destructor TLSP.Destroy;
begin
  Connected := False;
  if FSocket < 0 then
    fpShutdown(FSocket, SHUT_RDWR);

  MessageList.Free;
  inherited Destroy;
end;

procedure TLSP.Execute;
var Response, Key, Value: String;
    ResponseJSON: TJSONObject;
    i: Integer;
begin
  try
    while (not Terminated) do
    begin
      if not Connected then
        Connect;
      Response := ReceiveDataUntilZero;
      if Length(Response) > 0 then
      begin
        try
          if GetJSON(Response).JSONType = jtObject then
          begin
            ResponseJSON := TJSONObject(GetJSON(Response));
            if ResponseJSON.FindPath('result.capabilities') <> nil then
            begin
              Init := True;
              Initialized;
              AddView(FileName);
            end;
            if ResponseJSON.FindPath('result.capabilities.hoverProvider') <> nil then
              HoverSupport := ResponseJSON.FindPath('result.capabilities.hoverProvider').AsBoolean;
            if ResponseJSON.FindPath('error') <> nil then
              if ResponseJSON.FindPath('error.code').AsInteger = 0 then
                OpenFile(FileName);
            if ResponseJSON.FindPath('result.contents.value') <> nil then
              Message := ResponseJSON.FindPath('result.contents.value').AsString;
            if ResponseJSON.FindPath('result.items') <> nil then
            begin
              if ResponseJSON.FindPath('result.items').Count > 0 then
                for i := 0 to ResponseJSON.FindPath('result.items').Count - 1 do
                begin
                  Key := ResponseJSON.FindPath('result.items').Items[i].FindPath('label').AsString;
                  Value := ResponseJSON.FindPath('result.items').Items[i].FindPath('detail').AsString;
                  MessageList.Add(Key + '=' + Value);
                end;
            end;
          end;
        except
          on E: Exception do
          begin
            {$IFDEF UNIX}
            writeln('JSON Error: ' + E.Message);
            {$ENDIF}
          end;
        end;
      end;
      sleep(100);
    end;
  except
    on E: Exception do
    begin
      {$IFDEF UNIX}
      writeln('Receive Data Error: ', E.Message);
      {$ENDIF}
    end;
  end;
  WaitFor;
end;

function TLSP.ReceiveDataUntilZero:String;
var Buffer: Byte;
    ContentLength, BytesRead, i: Integer;
    Line: String;
    Found: Boolean;
    Regex: TRegExpr;
begin
  if FSocket <= 0 then
    Exit;

  Result := '';
  Line := '';
  Found := False;
  ContentLength := 0;
  BytesRead := 0;
  repeat
    BytesRead := fpRead(FSocket, Buffer, 1);
    if BytesRead > 0 then
    begin
      if Buffer = 10 then
      begin
        Regex := TRegExpr.Create;
        Regex.Expression := '^Content-Length: (\d+).*';
        Regex.ModifierI := False;
        if Regex.Exec(Line) then
        begin
          ContentLength := StrToInt(RegEx.Match[1]);
          Found := True;
        end;
      end
      else
      begin
        Line := Line + Chr(Buffer);
      end;
    end;
  until (BytesRead = 0) or (Found);

  if ContentLength = 0 then
    Exit;

  i := 0;
  Line := '';
  repeat
    BytesRead := fpRead(FSocket, Buffer, 1);
    if BytesRead > 0 then
    begin
      Line := Line + Chr(Buffer);
    end;
    inc(i);
  until i-2 = ContentLength;

  if Length(Line) > 0 then
  begin
    Result := Line;
  end;
end;

procedure TLSP.RunLSPServer;
var run: TProcess;
begin
  run := TProcess.Create(nil);
  try
    run.Executable := ServerExec;
    run.Parameters := ServerParameter;

    run.Options := [poNoConsole];
    run.Execute;
  except
  end;
  Sleep(200);
end;

procedure TLSP.Connect;
var Addr: TInetSockAddr;
    Flags: Integer;
begin
  if ServerPort <= 0 then
    Exit;

  FSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if FSocket = -1 then
  begin
    write('Failed to create socket.');
    Exit;
  end;

  Addr.sin_family := AF_INET;

  Addr.sin_port := htons(ServerPort);
  Addr.sin_addr := StrToNetAddr('127.0.0.1');

  if fpConnect(FSocket, @Addr, SizeOf(Addr)) < 0 then
  begin
    //Disconnect;
    {$IFDEF UNIX}
    write('Failed to connect to LSP server: ' + IntToStr(ServerPort));
    {$ENDIF}
    Exit;
  end;
  Flags := FpFcntl(FSocket, F_GETFL, 0);
  FpFcntl(FSocket, F_SETFL, Flags or O_NONBLOCK);

  Connected := True;
end;

procedure TLSP.SetLanguage(const ALanguage: String);
begin
  case LowerCase(ALanguage) of
    'go':
    begin
     Language := 'go';
     ServerPort := 37374;
     ServerExec := 'gopls';
     ServerParameter.Add('-listen=:' + IntToStr(ServerPort));
    end;
    'python':
    begin
     Language := 'python';
     ServerPort := 37375;
     ServerExec := 'pylsp';
     ServerParameter.Add('--tcp');
     ServerParameter.Add('--port=' + IntToStr(ServerPort));
    end
  else
  end;

  if Length(Language) > 0 then
    RunLSPServer;
end;

procedure TLSP.Initialize(const AFilePath: String);
var Params: TJSONObject;
begin
  if (Length(AFilePath) <= 0) then
    Exit;

  FilePath := AFilePath;

  Params := TJSONObject.Create;
  Params.Add('rootUri', 'file://'+FilePath);
  Params.Add('rootPath', FilePath);
  Params.Add('trace', 'verbose');

  Send(Params, 'initialize');
end;

procedure TLSP.Initialized;
var Params: TJSONObject;
begin
  Params := TJSONObject.Create;

  Send(Params, 'initialized');
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

procedure TLSP.Completion(const Line, Character: Integer);
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
  Position.Add('character', Character - 1);
  Context.Add('triggerKind', 1);

  Params.Add('textDocument', TextDoc);
  Params.Add('position', Position);
  Params.Add('context', Context);

  Send(Params, 'textDocument/completion');
end;

function TLSP.Send(Params: TJSONObject; const method: String): TJSONData;
var RequestText, SendString: string;
    RequestJSON: TJSONObject;
    Data: TBytes;
begin
  // try to connect
  if not Connected then
    Connect;

  RequestJSON := TJSONObject.Create;
  try
    RequestJSON.Add('jsonrpc', '2.0');
    RequestJSON.Add('id', 1);
    RequestJSON.Add('method', method);
    RequestJSON.Add('params', Params);

    RequestText := RequestJSON.AsJSON;
    SendString := 'Content-Length: ' + IntToStr(Length(RequestText)+1) + #10#10 + RequestText + #10;
    Data := TEncoding.UTF8.GetBytes(SendString);
    fpSend(FSocket, @Data[0], Length(Data), 0);
  except
    on E: Exception do
    begin
      {$IFDEF UNIX}
      writeln('Send Data Error: ', E.Message);
      {$ENDIF}
    end;
  end;
  RequestJSON.Free;
  Result := nil;
end;

end.

