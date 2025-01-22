unit MEHighlighterPascal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter;

type

    { TMEHighlighterPascal }

    TMEHighlighterPascal = class(TSynFacilSyn)
    private
      fKeyWordList: TStringList;
      tnDataType: Integer;
      tnPreprocessor: Integer;

    protected
      function IsFilterStored: Boolean; override;
      function GetSampleSource: string; override;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      class function GetLanguageName: string; override;
    end;

const
  SYNS_FilterPascal = 'Pascal files (*.pas)|*.pas';

implementation

uses
  SynFacilBasic, SynEditStrConst;

const
  SYNS_LangPascal = 'Pascal';

  PascalKeyWords = 'and,absolute,alias,asm,begin,case,const,constructor,destructor,div,do,'+
                   'downto,else,except,exit,finally,for,forward,function,goto,if,in,'+
                   'implementation,inline,is,label,module,nil,not,object,of,operator,'+
                   'or,packed,procedure,program,property,raise,record,repeat,set,shl,'+
                   'shr,then,to,try,type,unit,uses,var,while,with';

  PascalDataTypes = 'boolean,byte,char,extended,integer,real,shortint,smallint,single,string,'+
                    'cardinal,int64,bytearray,word,ptr';

  PascalPreprocessor = 'include';

{ TMEHighlighterPascal }

function TMEHighlighterPascal.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterPascal;
end;

function TMEHighlighterPascal.GetSampleSource: string;
begin
  Result := '// Sample Pascal code' + #13#10 +
            'program HelloWorld;' + #13#10 +
            'begin' + #13#10 +
            '    writeln(''Hello, World!'');' + #13#10 +
            'end.';
end;

constructor TMEHighlighterPascal.Create(AOwner: TComponent);
var
  I: Word;
begin
  fKeyWordList := TStringList.Create;
  fKeyWordList.Delimiter := ',';
  fKeyWordList.StrictDelimiter := True;

  fKeyWordList.DelimitedText := PascalKeyWords;

  inherited Create(AOwner);

  ClearMethodTables;
  ClearSpecials;

  DefTokIdentif('[A-Za-z_]', '[A-Za-z0-9_]*');

  tnDataType := NewTokType(SYNS_AttrDataType);
  tnPreprocessor := NewTokType(SYNS_AttrPreprocessor);

  // Keywords
  for I := 0 to fKeyWordList.Count - 1 do
    AddKeyword(fKeyWordList[I]);

  fKeyWordList.Clear;
  fKeyWordList.DelimitedText := PascalDataTypes;

  // Data Types
  for I := 0 to fKeyWordList.Count - 1 do
    AddIdentSpec(fKeyWordList[I], tnDataType);

  fKeyWordList.Clear;
  fKeyWordList.DelimitedText := PascalPreprocessor;

  // Preprocessor
  for I := 0 to fKeyWordList.Count - 1 do
    AddIdentSpec(fKeyWordList[I], tnPreprocessor);

  fKeyWordList.Free;

  // Define string delimiters
  DefTokDelim('"', '"', tnString);
  DefTokDelim('''', '''', tnString);

  // Comments
  DefTokDelim('//', '', tnComment);
  DefTokDelim('{', '}', tnComment, tdMulLin, True);

  // Numbers
  DefTokContent('[0123456789]', '[0-9]*', tnNumber);
  DefTokContent('0x', '[0-9a-fA-F]*', tnNumber);

  fDefaultFilter := SYNS_FilterPascal;

  Rebuild;

  SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMEHighlighterPascal.Destroy;
begin
  inherited Destroy;
end;

class function TMEHighlighterPascal.GetLanguageName: string;
begin
  Result := SYNS_LangPascal;
end;

end.

