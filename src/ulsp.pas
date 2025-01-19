unit uLSP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, Sockets, netdb, baseunix, RegExpr;
type
  TLSP = class(TThread)
  private
    Language: String;
    Init: Boolean;
    HoverSupport: Boolean;
    Connected: Boolean;
    FSocket: TSocket;
    FileName: String;
    procedure Connect;
    function Send(Params: TJSONObject; const method: String): TJSONData;
    function ReceiveDataUntilZero:String;
  protected
    procedure Execute; override;
  public
    Port: Integer;
    procedure Initialize(const FFileName: String);
    procedure AddView(const FFileName: String);
    procedure OpenFile(const FFileName: String);
    procedure Hover(const Line, Character: Integer);
    procedure SetLanguage(const ALanguage: String);
    constructor Create;
  end;

implementation

constructor TLSP.Create;
begin
  inherited Create(False);
  Init := False;
  HoverSupport := False;
  FreeOnTerminate := False;
end;

procedure TLSP.Execute;
var Response: String;
    ResponseJSON: TJSONObject;
begin
  try
    while not Terminated do
    begin
      write('.');
      if not Connected then
        Connect;
      Response := ReceiveDataUntilZero;
      if Length(Response) > 0 then
      begin
        writeln(Response);
        try
          if GetJSON(Response).JSONType = jtObject then
          begin
            ResponseJSON := TJSONObject(GetJSON(Response));
            if ResponseJSON.FindPath('result.capabilities') <> nil then
            begin
              Init := True;
              AddView(FileName);
            end;
            if ResponseJSON.FindPath('result.capabilities.hoverProvider') <> nil then
              HoverSupport := ResponseJSON.FindPath('result.capabilities.hoverProvider').AsBoolean;
            if ResponseJSON.FindPath('error') <> nil then
              if ResponseJSON.FindPath('error.code').AsInteger = 0 then
                OpenFile(FileName);
          end;
        except
          {$IFDEF UNIX}
          writeln('JSON Error');
          {$ENDIF}
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
  until Found;

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


procedure TLSP.Connect;
var Addr: TInetSockAddr;
    Flags: Integer;
begin
  if Port <= 0 then
    Exit;

  FSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if FSocket = -1 then
  begin
    write('Failed to create socket.');
    Exit;
  end;

  Addr.sin_family := AF_INET;

  Addr.sin_port := htons(Port);
  Addr.sin_addr := StrToNetAddr('127.0.0.1');

  if fpConnect(FSocket, @Addr, SizeOf(Addr)) < 0 then
  begin
    //Disconnect;
    write('Failed to connect to LSP server');
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
     Port := 37374;
    end
  else
  end;
end;

procedure TLSP.Initialize(const FFileName: String);
var Params: TJSONObject;
begin
  if (Length(FFileName) <= 0) then
    Exit;

  FileName := FFileName;

  Params := TJSONObject.Create;
  Params.Add('rootUri', 'file://'+ExtractFilePath(FileName));

  Send(Params, 'initialize');
end;



procedure TLSP.AddView(const FFileName: String);
var Params: TJSONObject;
    Event: TJSONObject;
    Added: TJSONArray;
    FolderObject: TJSONObject;
begin
  if (Length(FFileName) <= 0) then
    Exit;

  FileName := FFileName;

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

procedure TLSP.OpenFile(const FFileName: String);
var Params, TextDoc: TJSONObject;
begin
  if Length(FFileName) <= 0 then
    Exit;

  FileName := FFileName;

  Params := TJSONObject.Create;
  TextDoc := TJSONObject.Create;
  TextDoc.Add('uri', 'file://'+FileName);
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
  Position.Add('line', Line - 1);
  Position.Add('character', Character - 1);

  Params.Add('textDocument', TextDoc);
  Params.Add('position', Position);

  Send(Params, 'textDocument/hover');
end;

function TLSP.Send(Params: TJSONObject; const method: String): TJSONData;
var RequestText, SendString: string;
    RequestJSON: TJSONObject;
    Data: TBytes;
begin
  // try to connect
  if not Connected then
    repeat
      Connect;
      {$IFDEF UNIX}
      writeln('Try to Reconnect with LSP Server');
      {$ENDIF}
      sleep(10);
    until Connected;

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

