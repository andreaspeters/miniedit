unit ucmdboxthread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Process;

type
  { TCmdBoxThread }

  TCmdBoxThread = class(TThread)
  private
    FBuffer: array[0..4095] of Byte;
  protected
    procedure Execute; override;
  public
    OutputString: string;
    Command: TProcess;
    constructor Create;
  end;

implementation

{ TCmdBoxThread }

constructor TCmdBoxThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
end;

procedure TCmdBoxThread.Execute;
var
  BytesRead: LongInt;
  Line: String;
begin
  while Command.Running or (Command.Output.NumBytesAvailable > 0) do
  begin
    BytesRead := Command.Output.Read(FBuffer, SizeOf(FBuffer));
    if BytesRead > 0 then
    begin
      SetString(Line, PAnsiChar(@FBuffer[0]), BytesRead);
      OutputString := OutputString + Line;
    end;
  end;
end;


end.
