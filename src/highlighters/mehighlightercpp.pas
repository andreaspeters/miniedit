unit MEHighlighterCPP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter, Graphics;

type

    { TMEHighlighterCPP }

    TMEHighlighterCPP = class(TSynFacilSyn)
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
  SYNS_FilterC_CPP = 'C/C++ files (*.c;*.cpp;*.h;*.hpp)|*.c;*.cpp;*.h;*.hpp';

implementation

uses
  SynFacilBasic, SynEditStrConst;

const
  SYNS_LangCPP = 'C/C++';


  CPPKeyWords = 'alignas,alignof,and,and_eq,asm,atomic_cancel,atomic_commit,'+
              'atomic_noexcept,bitand,bitor,break,case,catch,class,'+
              'compl,concept,const,consteval,constexpr,constinit,const_cast,'+
              'continue,co_await,co_return,co_yield,default,delete,'+
              'do,dynamic_cast,else,enum,explicit,export,extern,false,for,'+
              'friend,goto,if,inline,mutable,namespace,new,noexcept,not,not_eq,'+
              'nullptr,operator,or,or_eq,private,protected,public,reflexpr,'+
              'register,reinterpret_cast,requires,return,sizeof,static,'+
              'static_assert,static_cast,struct,switch,synchronized,template,'+
              'this,thread_local,throw,true,try,typedef,typeid,typename,union,'+
              'using,virtual,volatile,while,xor,xor_eq';



  CPPDataTypes = 'bool,char,char8_t,char16_t,char32_t,wchar_t,signed,unsigned,'+
                 'short,int,long,float,double,void,auto,decltype,size_t,ptrdiff_t,'+
                 'int8_t,int16_t,int32_t,int64_t,uint8_t,uint16_t,uint32_t,uint64_t,'+
                 'uintptr_t,intptr_t';

{ TMEHighlighterCPP }

function TMEHighlighterCPP.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterCPP;
end;

function TMEHighlighterCPP.GetSampleSource: string;
begin
  Result := '// Sample C/C++ code' + #13#10 +
            '#include <stdio.h>' + #13#10 +
            '#include <stdlib.h>' + #13#10 +
            '' + #13#10 +
            'int main() {' + #13#10 +
            '    printf("Hello, World!\n");' + #13#10 +
            '    return 0;' + #13#10 +
            '}';
end;

constructor TMEHighlighterCPP.Create(AOwner: TComponent);
var
  I: Word;
begin
  fKeyWordList := TStringList.Create;
  fKeyWordList.Delimiter := ',';
  fKeyWordList.StrictDelimiter := True;

  fKeyWordList.DelimitedText := CPPKeyWords;

  inherited Create(AOwner);

  ClearMethodTables;
  ClearSpecials;

  DefTokIdentif('[A-Za-z_]', '[A-Za-z0-9_]*');

  tnDataType := NewTokType(SYNS_AttrDataType);

  // Keywords
  for I := 0 to fKeyWordList.Count - 1 do
    AddKeyword(fKeyWordList[I]);

  fKeyWordList.Clear;
  fKeyWordList.DelimitedText := CPPDataTypes;

  // Data Types
  for I := 0 to fKeyWordList.Count - 1 do
    AddIdentSpec(fKeyWordList[I], tnDataType);

  fKeyWordList.Free;

  // preprocessoren
  DefTokDelim('#', '[A-Za-z]*', tnDirective);

  // Define string delimiters
  DefTokDelim('"', '"', tnString);

  // Comments
  DefTokDelim('//', '', tnComment);
  DefTokDelim('/\*', '\*/', tnComment, tdMulLin, True);

  // Numbers
  DefTokContent('[0123456789]', '[0-9]*', tnNumber);
  DefTokContent('0x', '[0-9a-fA-F]*', tnNumber);

  fDefaultFilter := SYNS_FilterCPP;

  Rebuild;

  SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMEHighlighterCPP.Destroy;
begin
  inherited Destroy;
end;

class function TMEHighlighterCPP.GetLanguageName: string;
begin
  Result := SYNS_LangCPP;
end;

end.

