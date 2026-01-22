unit MEHighlighterBash;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter;

type

  { TMEHighlighterBash }

  TMEHighlighterBash = class(TSynFacilSyn)
  private
    fKeyWordList : TStringList;
    tnBuiltin    : Integer;
    tnVariable   : Integer;

  protected
    function IsFilterStored: Boolean; override;
    function GetSampleSource: string; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function GetLanguageName: string; override;
  end;

const
  SYNS_FilterBash = 'Bash scripts (*.sh)|*.sh';

implementation

uses
  SynFacilBasic, SynEditStrConst;

const
  SYNS_LangBash = 'Bash (SynFacil)';

  BashKeyWords =
    'if,then,else,elif,fi,for,while,until,do,done,in,case,esac,select,'
  + 'function,time,coproc';

  BashBuiltins =
    'echo,cd,pwd,exit,return,read,printf,export,unset,shift,source,'
  + 'alias,unalias,bind,break,continue,exec,fg,bg,jobs,kill,wait,'
  + 'test,true,false,type,hash,help,history';

{ TMEHighlighterBash }

function TMEHighlighterBash.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterBash;
end;

function TMEHighlighterBash.GetSampleSource: string;
begin
  Result :=
    '#!/bin/bash' + LineEnding +
    '' + LineEnding +
    'NAME="Andreas"' + LineEnding +
    'echo "Hello $NAME"' + LineEnding +
    '' + LineEnding +
    'if [ "$NAME" != "" ]; then' + LineEnding +
    '  echo "Name is set"' + LineEnding +
    'fi';
end;

constructor TMEHighlighterBash.Create(AOwner: TComponent);
var
  I: Integer;
begin
  fKeyWordList := TStringList.Create;
  fKeyWordList.Delimiter := ',';
  fKeyWordList.StrictDelimiter := True;

  inherited Create(AOwner);

  ClearMethodTables;
  ClearSpecials;

  { Identifier }
  DefTokIdentif('[A-Za-z_]', '[A-Za-z0-9_]*');

  { Keywords }
  fKeyWordList.DelimitedText := BashKeyWords;
  for I := 0 to fKeyWordList.Count - 1 do
    AddKeyword(fKeyWordList[I]);

  { Builtins }
  tnBuiltin := NewTokType(SYNS_AttrFunction);
  fKeyWordList.Clear;
  fKeyWordList.DelimitedText := BashBuiltins;
  for I := 0 to fKeyWordList.Count - 1 do
    AddIdentSpec(fKeyWordList[I], tnBuiltin);

  fKeyWordList.Free;

  { Variables: $VAR and ${VAR} }
  tnVariable := NewTokType(SYNS_AttrVariable);
  DefTokContent('$','[A-Za-z_][A-Za-z0-9_]*', tnVariable);
  DefTokContent('${','[A-Za-z_][A-Za-z0-9_]*}', tnVariable);

  { Strings }
  DefTokDelim('"','"', tnString);
  DefTokDelim('''','''', tnString);

  { Comments }
  DefTokDelim('#','', tnComment);

  { Numbers }
  DefTokContent('[0123456789]','[0-9]*', tnNumber);

  fDefaultFilter := SYNS_FilterBash;

  Rebuild;
  SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMEHighlighterBash.Destroy;
begin
  inherited Destroy;
end;

class function TMEHighlighterBash.GetLanguageName: string;
begin
  Result := SYNS_LangBash;
end;

end.


