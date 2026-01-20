unit MEHighlighterJavaScript;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter;

type

  { TMEHighlighterJavaScript }

  TMEHighlighterJavaScript = class(TSynFacilSyn)
  private
    fKeyWordList : TStringList;
    tnLiteral    : Integer;

  protected
    function IsFilterStored: Boolean; override;
    function GetSampleSource: string; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function GetLanguageName: string; override;
  end;

const
  SYNS_FilterJavaScript = 'JavaScript (ME) (*.js)|*.js';

implementation

uses
  SynFacilBasic, SynEditStrConst;

const
  SYNS_LangJavaScript = 'JavaScript (ME)';

  JavaScriptKeyWords =
    'break,case,catch,class,const,continue,debugger,default,delete,do,else,' +
    'export,extends,finally,for,function,if,import,in,instanceof,let,new,' +
    'return,super,switch,this,throw,try,typeof,var,void,while,with,yield';

  JavaScriptLiterals =
    'true,false,null,undefined,NaN,Infinity';

{ TMEHighlighterJavaScript }

function TMEHighlighterJavaScript.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterJavaScript;
end;

function TMEHighlighterJavaScript.GetSampleSource: string;
begin
  Result :=
    '// JavaScript sample' + LineEnding +
    'function greet(name) {' + LineEnding +
    '  let user = "Andreas";' + LineEnding +
    '  console.log(greet(user));' + LineEnding +
    '}';
end;

constructor TMEHighlighterJavaScript.Create(AOwner: TComponent);
var
  I: Integer;
begin
  fKeyWordList := TStringList.Create;
  fKeyWordList.Delimiter := ',';
  fKeyWordList.StrictDelimiter := True;

  inherited Create(AOwner);

  ClearMethodTables;
  ClearSpecials;

  { Identifier definition }
  DefTokIdentif('[A-Za-z_$]', '[A-Za-z0-9_$]*');

  { Keywords }
  fKeyWordList.DelimitedText := JavaScriptKeyWords;
  for I := 0 to fKeyWordList.Count - 1 do
    AddKeyword(fKeyWordList[I]);

  { Literals }
  tnLiteral := NewTokType(SYNS_AttrDataType);
  fKeyWordList.Clear;
  fKeyWordList.DelimitedText := JavaScriptLiterals;
  for I := 0 to fKeyWordList.Count - 1 do
    AddIdentSpec(fKeyWordList[I], tnLiteral);

  fKeyWordList.Free;

  { Strings }
  DefTokDelim('"','"', tnString);
  DefTokDelim('''','''', tnString);
  DefTokDelim('`','`', tnString, tdMulLin, True);

  { Comments }
  DefTokDelim('//','', tnComment);
  DefTokDelim('/\*','\*/', tnComment, tdMulLin, True);

  { Numbers }
  DefTokContent('[0123456789]','[0-9]*', tnNumber);
  DefTokContent('0x','[0-9a-fA-F]*', tnNumber);

  fDefaultFilter := SYNS_FilterJavaScript;

  Rebuild;
  SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMEHighlighterJavaScript.Destroy;
begin
  inherited Destroy;
end;

class function TMEHighlighterJavaScript.GetLanguageName: string;
begin
  Result := SYNS_LangJavaScript;
end;

end.

