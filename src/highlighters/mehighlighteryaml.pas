unit MEHighlighterYAML;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter;

Type

    { TMEHighlighterYAML }

    TMEHighlighterYAML = Class(TSynFacilSyn)
      Private
        fKeyWordList                      : TStringList;

      Protected
        function IsFilterStored: Boolean; override;
        function GetSampleSource: string; override;

      Public
        Constructor Create(AOwner: TComponent); Override;
        Destructor Destroy; Override;

        class function GetLanguageName: string; override;
    end;

Const
     SYNS_FilterYAML                 = 'YAML files (*.yaml;*.yml)|*.yaml;*.yml';
implementation

Uses SynFacilBasic, SynEditStrConst;

Const
     SYNS_LangYAML                   = 'YAML';

     YAMLKeyWords                    = 'true,false,null,yes,no';

{ TMEHighlighterYAML }

function TMEHighlighterYAML.IsFilterStored: Boolean;
begin
 Result := fDefaultFilter <> SYNS_FilterYAML;
end;

function TMEHighlighterYAML.GetSampleSource: string;
begin
  Result := '# Sample YAML file' + #13#10 +
            'version: 1.0' + #13#10 +
            'application:' + #13#10 +
            '  name: ExampleApp' + #13#10 +
            '  settings:' + #13#10 +
            '    theme: dark' + #13#10 +
            '    notifications: true' + #13#10 +
            'users:' + #13#10 +
            '  - name: John Doe' + #13#10 +
            '    role: admin' + #13#10 +
            '  - name: Jane Smith' + #13#10 +
            '    role: user';
end;

constructor TMEHighlighterYAML.Create(AOwner: TComponent);
 Var I : Word;
begin
 fKeyWordList := TStringList.Create;
 fKeyWordList.Delimiter := ',';
 fKeyWordList.StrictDelimiter := True;

 fKeyWordList.DelimitedText := YAMLKeyWords;

 Inherited Create(AOwner);

 ClearMethodTables;
 ClearSpecials;

 DefTokIdentif('[A-Za-z_]', '[A-Za-z0-9_]*');

 // Keywords
 For I := 0 To fKeyWordList.Count - 1 Do
  AddKeyword(fKeyWordList[I]);

 fKeyWordList.Free;

 // Define string delimiters
 DefTokDelim('"','"', tnString);
 DefTokDelim('''','''', tnString);

 // Comments
 DefTokDelim('#','', tnComment);

 // Numbers
 DefTokContent('[0123456789]','[0-9]*', tnNumber);
 DefTokContent('0x','[0-9a-f]*', tnNumber);

 fDefaultFilter := SYNS_FilterYAML;

 Rebuild;

 SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMEHighlighterYAML.Destroy;
begin
  inherited Destroy;
end;

class function TMEHighlighterYAML.GetLanguageName: string;
begin
 Result := SYNS_LangYAML;
end;

end.


