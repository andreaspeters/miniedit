unit uLSP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, Sockets, netdb, baseunix, RegExpr, Process,
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
    procedure RunLSPServer;
    function Send(Params: TJSONObject; const method: String): TJSONData;
    function ReceiveData:String;
  protected
    procedure Execute; override;
  public
    ServerExec: String;
    ServerParameter: TStringList;
    Message: String;
    MessageList: TStringList;
    OutputString: String;
    procedure Initialize(const AFilePath: String);
    procedure Initialized;
    procedure AddView(const AFileName: String);
    procedure OpenFile(const AFileName: String);
    procedure Reload;
    procedure Change(const Text: String);
    procedure Hover(const Line, Character: Integer);
    procedure Completion(const Line, Character, Trigger: Integer);
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
  FreeOnTerminate := True;
  Message := '';
  MessageList := TStringList.Create;
  ServerParameter := TStringList.Create;
  InputStream := TMemoryStream.Create;
  OutputStream := TMemoryStream.Create;
  FEvent := RTLEventCreate;
  Pause := False;
end;

destructor TLSP.Destroy;
begin
  inherited Destroy;
end;

procedure TLSP.Stop;
begin
  if Assigned(LSPServer) then
    LSPServer.Free;
end;

procedure TLSP.Execute;
var Response, Key, Value: String;
    ResponseJSON: TJSONObject;
    i: Integer;
begin
  try
    while (not Terminated) do
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
      sleep(10);
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
    ContentLength, i: Integer;
    Found: Boolean;
    Regex: TRegExpr;
    Line: String;
begin
  if not LSPServer.Running then
    Exit;

  Result := '';
  Line := '';
  Found := False;
  ContentLength := 0;
  Buffer := 0;

  repeat
    if Assigned(LSPServer.Output) then
      Buffer := LSPServer.Output.ReadByte;
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
  until (LSPServer.Output.NumBytesAvailable <= 0) or (Found);

  if ContentLength = 0 then
    Exit;

  i := 0;
  Line := '';
  repeat
    Buffer := LSPServer.Output.ReadByte;
    Line := Line + Chr(Buffer);

    if Pos('Content-Type: application/vscode-jsonrpc; charset=utf8', Line) > 0 then
    begin
      Line := StringReplace(Line, 'Content-Type: application/vscode-jsonrpc; charset=utf8', '', [rfReplaceAll]);
      i := i - 2 - Length('Content-Type: application/vscode-jsonrpc; charset=utf8');
    end;
    inc(i);
  until i-2 = ContentLength;


  if Length(Line) > 0 then
  begin
    Result := Line;
  end;
end;

procedure TLSP.RunLSPServer;
begin
  if Length(ServerExec) <= 0 then
    Exit;

  LSPServer := TProcess.Create(nil);
  try
    LSPServer.Executable := ServerExec;
    LSPServer.Parameters := ServerParameter;

    LSPServer.Options := [poUsePipes, poNoConsole];
    LSPServer.Execute;
  except
    on E: Exception do
    begin
      {$IFDEF UNIX}
      writeln('Exec LSP Server Error: ', E.Message);
      {$ENDIF}
    end;
  end;
  Sleep(200);
end;

procedure TLSP.SetLanguage(const ALanguage: String);
begin
  Language := '';

  case LowerCase(ALanguage) of
    'go':
    begin
     Language := 'go';
     ServerExec := 'gopls';
    end;
    'python':
    begin
     Language := 'python';
     ServerExec := 'pylsp';
    end;
    'c/c++':
    begin
     Language := 'c';
     ServerExec := 'ccls';
    end
  else
    Suspend;
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
    SendString := 'Content-Length: ' + IntToStr(Length(RequestText)+1) + #10#10 + RequestText + #10;
    Data := TEncoding.UTF8.GetBytes(SendString);

    //writeln(SendString);

    InputStream.Clear;
    InputStream.Write(PChar(SendString)^, Length(SendString));
    InputStream.SaveToStream(LSPServer.Input);

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

