{ <PiNote - free source code editor>

Copyright (C) <2023> <Enzo Antonio Calogiuri> <ecalogiuri(at)gmail.com>

This source is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your option)
any later version.

This code is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

A copy of the GNU General Public License is available on the World Wide Web
at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
Boston, MA 02110-1335, USA.
}
unit MySEHighlighterProtoBuf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynFacilHighlighter, SynEditHighlighter;

Type

    { TMySEHighlighterProtoBuf }

    TMySEHighlighterProtoBuf              = Class(TSynFacilSyn)
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
     SYNS_FilterProtoBuf              = 'ProtoBuf files (*.proto)|*.proto';

implementation

Uses SynFacilBasic, SynEditStrConst;

Const
     SYNS_LangProtoBuf                = 'ProtoBuf';

     ProtoBufKeyWords                 = 'message,required,optional,repeated,packed,' +
                                        'enum,default,import,public,extensions,' +
                                        'package,option,deprecated,extend';

     ProtoBufDataTypes                = 'double,float,int32,int64,uint32,uint64,' +
                                        'sint32,sint64,fixed32,fixed64,sfixed32,' +
                                        'sfixed64,bool,string,bytes';

{ TMySEHighlighterProtoBuf }

function TMySEHighlighterProtoBuf.IsFilterStored: Boolean;
begin
 Result := fDefaultFilter <> SYNS_FilterProtoBuf;
end;

function TMySEHighlighterProtoBuf.GetSampleSource: string;
begin
  Result := '//Simple test code' + #13#10 +
            'syntax = "proto3";' + #13#10 +
            '' + #13#10 +
            'package tutorial;' + #13#10 +
            '' + #13#10 +
            'option java_package = "com.example.tutorial";' + #13#10 +
            'option java_outer_classname = "AddressBookProtos";' + #13#10 +
            '' + #13#10 +
            'message Person {' + #13#10 +
            '  required string name = 1;' + #13#10 +
            '  required int32 id = 2;' + #13#10 +
            '  optional string email = 3;' + #13#10 +
            '' + #13#10 +
            '  enum PhoneType {' + #13#10 +
            '    MOBILE = 0;' + #13#10 +
            '    HOME = 1;' + #13#10 +
            '    WORK = 2;' + #13#10 +
            '  }' + #13#10 +
            '' + #13#10 +
            '  message PhoneNumber {' + #13#10 +
            '    required string number = 1;' + #13#10 +
            '    optional PhoneType type = 2 [default = HOME];' + #13#10 +
            '  }' + #13#10 +
            '' + #13#10 +
            '  repeated PhoneNumber phones = 4;' + #13#10 +
            '}';
end;

constructor TMySEHighlighterProtoBuf.Create(AOwner: TComponent);
 Var I : Word;
begin
 fKeyWordList := TStringList.Create;
 fKeyWordList.Delimiter := ',';
 fKeyWordList.StrictDelimiter := True;

 fKeyWordList.DelimitedText := ProtoBufKeyWords;

 Inherited Create(AOwner);

 ClearMethodTables;
 ClearSpecials;

 DefTokIdentif('[A-Za-z_]', '[A-Za-z0-9_]*');

 tnDataType := NewTokType(SYNS_AttrDataType);

 For I := 0 To fKeyWordList.Count - 1 Do
  AddKeyword(fKeyWordList[I]);

 fKeyWordList.Clear;
 fKeyWordList.DelimitedText := ProtoBufDataTypes;

 For I := 0 To fKeyWordList.Count - 1 Do
  AddIdentSpec(fKeyWordList[I], tnDataType);

 fKeyWordList.Free;

 DefTokDelim('"','"', tnString);
 DefTokDelim('//','', tnComment);
 DefTokDelim('/\*','\*/', tnComment, tdMulLin, True);

 DefTokContent('[0123456789]','[0-9]', tnNumber);
 DefTokContent('0x','[0-9a-f]*', tnNumber);

 fDefaultFilter := SYNS_FilterProtoBuf;

 Rebuild;

 SetAttributesOnChange(@DefHighlightChange);
end;

destructor TMySEHighlighterProtoBuf.Destroy;
begin
  inherited Destroy;
end;

class function TMySEHighlighterProtoBuf.GetLanguageName: string;
begin
 Result := SYNS_LangProtoBuf;
end;

end.

