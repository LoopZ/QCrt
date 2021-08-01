{
Copyright 2021, Jerome Shidel
Released Under Mozilla Public License 2.0

This project and related files are subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file, You
can obtain one at http://mozilla.org/MPL/2.0/.
}
unit QNLS;

interface

uses QClass, QDos, QStrings, QASCIIZ;

    const
        Language : Str3 = '';
        UserLanguage : Str3 = 'EN';
        DefaultLanguage : Str3 = 'EN';

    { When Language data is set, it is stored in reverse order. So, defining
      a string again overrides any previous definitions. Also, defining
      frequently used strings later means they will be found quicker. But,
      if Performance is critical, cache the results from NLS in a string
      variable. }

    procedure SetBuiltInLanguage(AAddr : Pointer);
    procedure SetLanguage(ALang : String);
    { Tries to load Specified Language from EXE directory, then NLSPATH. If
      not found, then tries the DefaultLanguage in the same order. }

    function GetNLS(AID : String; var AString : String) : integer;
    { Returns 0 for Success, 1 for Success from BuiltIn, -1 for Failure }

    function NLS(AID : String) : String;
    { Returns the NLS String and/or Empty String }

    function NLSstr(AID : String; AStr : String) : String;
    { Like NLS. But, also replaces $ with AStr }

implementation

var
    LangData : Pointer;
    LangSize : word;
    LangBuiltIn : Pointer;

procedure SetBuiltInLanguage(AAddr : Pointer);
begin
    LangBuiltIn := AAddr;
end;

procedure LoadNLSFile(FileName:String);
begin
    LangData := LoadAsciiFile(FileName, LangSize);
    if not Assigned(LangData) then LangSize := 0;
end;

procedure SetLanguage(ALang : String);
var
    FN, HL : String;
begin
    if Assigned(LangData) then
        FreeMem(LangData, LangSize);
    Language := Trim(ALang);
    LangData := nil;
    LangSize := 0;
    if Language = '' then Language := Trim(GetEnv('LANG'));
    if Language = '' then Language := DefaultLanguage;
    UserLanguage := Language;
    FN := TailDelim(GetEXEPath) + GetEXEBase + '.' + Language;
    if not FileExists(FN) then
        FN := TailDelim(GetEnv('NLSPATH')) + GetEXEBase + '.' + Language;

    if FileExists(FN) then LoadNLSFile(FN);

    { Add support for Languages Attached to EXE }

    if (Language <> DefaultLanguage) and ( Not Assigned(LangData) ) then begin
        HL := UserLanguage;
        SetLanguage(DefaultLanguage);
        UserLanguage := HL;
    end;
end;

function FindLangData(AID : String) : Pointer;
var
    I : word;
    T : String;
begin
    FindLangData := nil;
    if Not Assigned (LangData) then Exit;
    AID := AID + '=';
    T[0] := AID[0];
    I := 0;
    repeat
        move(PAsciiZ(LangData)^[I], T[1], Length(AID));
        if (AID = T) then begin
            FindLangData := Ptr(Seg(LangData^), Ofs(LangData^) + I + Length(AID));
            Exit;
        end;
        while (Pos(PAsciiZ(LangData)^[I], #13#10#0) < 1) do inc(I);
        while (Pos(PAsciiZ(LangData)^[I + 1], #13#10#0) = 1) do inc(I);
        Inc(I);
    until I >= LangSize;
end;

function StrToEOLN (P : Pointer) : String;
var
    I : Integer;
    S : String;
begin
    S := '';
    if Assigned(P) then begin
        I := 0;
        while (I<254) and (Pos(PAsciiZ(P)^[I], #13#10#0) < 1) do begin
            S := S + PAsciiZ(P)^[I];
            Inc(I);
        end;
    end;
    StrToEOLN := S;
end;

function GetNLS(AID : String; var AString : String) : integer;
var
    P : Pointer;
    Ret : Integer;
begin
    Ret := -1;
    AString := '';
    if Assigned(LangData) then begin
        P := FindLangData(AID);
        if Assigned(P) then begin
            AString:=StrToEOLN(P);
            Ret := 1;
        end;
    end;
    if (Ret = -1) and Assigned(LangBuiltIn) then begin
        P := FindAsciiZ(LangBuiltIn, AID);
        if Assigned(P) then begin
            AString:=PascalStr(P^);
            Ret := 1;
        end;
    end;

    GetNLS := Ret;
end;

function NLS(AID : String) : String;
var
    T : String;
begin
    GetNLS(AID, T); { Don't care where it came from }
    NLS := Trim(T);
end;

function NLSstr(AID : String; AStr : String) : String;
begin
    NLSstr := ReplaceStr(NLS(AID), '$', AStr, True);
end;


begin
    LangBuiltIn := nil;
    LangData := nil;
    LangSize := 0;
end.