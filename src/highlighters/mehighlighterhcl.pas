unit MEHighlighterHCL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter;

Type

    { TMEHighlighterHCL }

    TMEHighlighterHCL = Class(TSynFacilSyn)
      Private
        fKeyWordList                      : TStringList;
        tnDataType                        : Integer;

      Protected
        function IsFilterStored: Boolean; override;
        function GetSampleSource: string; override;

      Public
        Constructor Create(AOwner: TComponent); Override;
        Destructor Destroy; Override;

        class function GetLanguageName: string; override;
    end;

Const
     SYNS_FilterHCL                 = 'HCL files (*.hcl;*.tf;*.tfvars)|*.hcl;*.tf;*.tfvars';

implementation

Uses SynFacilBasic, SynEditStrConst;

Const
     SYNS_LangHCL                   = 'HCL';

     HCLKeyWords                    = 'variable,source,packer,output,module,'+
                                      'provider,resource,data,terraform,build';
     HCLDataTypes                   = 'string,number,bool,list,map,set';

{ TMEHighlighterHCL }

function TMEHighlighterHCL.IsFilterStored: Boolean;
begin
 Result := fDefaultFilter <> SYNS_FilterHCL;
end;

function TMEHighlighterHCL.GetSampleSource: string;
begin
  Result := '# Sample HCL file' + #13#10 +
            'variable "example" {' + #13#10 +
            '  description = "An example variable"' + #13#10 +
            '  type        = string' + #13#10 +
            '  default     = "example value"' + #13#10 +
            '}' + #13#10 +
            '' + #13#10 +
            'resource "aws_instance" "example" {' + #13#10 +
            '  ami           = "ami-12345678"' + #13#10 +
            '  instance_type = "t2.micro"' + #13#10 +
            '  tags = {' + #13#10 +
            '    Name = "Example Instance"' + #13#10 +
            '  }' + #13#10 +
            '}';
end;

constructor TMEHighlighterHCL.Create(AOwner: TComponent);
 Var I : Word;
begin
 fKeyWordList := TStringList.Create;
 fKeyWordList.Delimiter := ',';
 fKeyWordList.StrictDelimiter := True;

 fKeyWordList.DelimitedText := HCLKeyWords;

 Inherited Create(AOwner);

 ClearMethodTables;
 ClearSpecials;

 DefTokIdentif('[A-Za-z_]', '[A-Za-z0-9_]*');

 tnDataType := NewTokType(SYNS_AttrDataType);

 // Keywords
 For I := 0 To fKeyWordList.Count - 1 Do
  AddKeyword(fKeyWordList[I]);

 fKeyWordList.Clear;
 fKeyWordList.DelimitedText := HCLDataTypes;

 // Data Types
 For I := 0 To fKeyWordList.Count - 1 Do
  AddIdentSpec(fKeyWordList[I], tnDataType);

 fKeyWordList.Free;

 // Define string delimiters
 DefTokDelim('"','"', tnString);

 // Comments
 DefTokDelim('#','', tnComment);
 DefTokDelim('//','', tnComment);
 DefTokDelim('/\*','\*/', tnComment, tdMulLin, True);

 // Numbers
 DefTokContent('[0123456789]','[0-9]*', tnNumber);
 DefTokContent('0x','[0-9a-f]*', tnNumber);

 fDefaultFilter := SYNS_FilterHCL;

 Rebuild;

 SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMEHighlighterHCL.Destroy;
begin
  inherited Destroy;
end;

class function TMEHighlighterHCL.GetLanguageName: string;
begin
 Result := SYNS_LangHCL;
end;

end.

