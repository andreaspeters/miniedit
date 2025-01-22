unit MEHighlighterNix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter;

Type

    { TMEHighlighterNix }

    TMEHighlighterNix = Class(TSynFacilSyn)
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
     SYNS_FilterNix                 = 'Nix files (*.nix)|*.nix';

implementation

Uses SynFacilBasic, SynEditStrConst;

Const
     SYNS_LangNix                   = 'Nix';

     NixKeyWords                    = 'let,in,if,then,else,assert,with,import,rec,'+
                                      'mkshell,buildInputs,shellHook';
     NixDataTypes                   = 'true,false,null';

{ TMEHighlighterNix }

function TMEHighlighterNix.IsFilterStored: Boolean;
begin
 Result := fDefaultFilter <> SYNS_FilterNix;
end;

function TMEHighlighterNix.GetSampleSource: string;
begin
  Result := '# Sample Nix file' + #13#10 +
            'let' + #13#10 +
            '  pkgs = import <nixpkgs> {};' + #13#10 +
            'in' + #13#10 +
            '  pkgs.mkShell {' + #13#10 +
            '    buildInputs = [ pkgs.gcc pkgs.git ];' + #13#10 +
            '    shellHook = "echo Welcome to the Nix shell!";' + #13#10 +
            '  }';
end;

constructor TMEHighlighterNix.Create(AOwner: TComponent);
 Var I : Word;
begin
 fKeyWordList := TStringList.Create;
 fKeyWordList.Delimiter := ',';
 fKeyWordList.StrictDelimiter := True;

 fKeyWordList.DelimitedText := NixKeyWords;

 Inherited Create(AOwner);

 ClearMethodTables;
 ClearSpecials;

 DefTokIdentif('[A-Za-z_]', '[A-Za-z0-9_]*');

 tnDataType := NewTokType(SYNS_AttrDataType);

 // Keywords
 For I := 0 To fKeyWordList.Count - 1 Do
  AddKeyword(fKeyWordList[I]);

 fKeyWordList.Clear;
 fKeyWordList.DelimitedText := NixDataTypes;

 // Data Types
 For I := 0 To fKeyWordList.Count - 1 Do
  AddIdentSpec(fKeyWordList[I], tnDataType);

 fKeyWordList.Free;

 // Define string delimiters
 DefTokDelim('"','"', tnString);

 // Comments
 DefTokDelim('#','', tnComment);

 // Numbers
 DefTokContent('[0123456789]','[0-9]*', tnNumber);
 DefTokContent('0x','[0-9a-f]*', tnNumber);

 fDefaultFilter := SYNS_FilterNix;

 Rebuild;

 SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMEHighlighterNix.Destroy;
begin
  inherited Destroy;
end;

class function TMEHighlighterNix.GetLanguageName: string;
begin
 Result := SYNS_LangNix;
end;

end.

