{
Copyright 2021, Jerome Shidel
Released Under Mozilla Public License 2.0

This project and related files are subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file, You
can obtain one at http://mozilla.org/MPL/2.0/.
}

unit QPkgLSM;

interface

    uses QClass, QDOS, QAsciiZ, QNLS, QStrings;

    const
        FileExtLSM : Str4 = '.LSM';
        FileExtLST : Str4 = '.LST';

    var
        PackageLSMPath : String;
        PackageLSTPath : String;

    type
        PPackageLSM = ^TPackageLSM;
        TPackageLSM = object (TObject)
        public
            DLang : Pointer;
            DSize : word;
            ULang : Pointer;
            USize : word;
            constructor Create(AOwner : PObject);
            function ReadMetaData (APackage : String) : integer; virtual;
            function WriteMetaData (APackage : String) : integer; virtual;
            function GetClassName : String; virtual;
            function SizeOfObject : LongInt; virtual;
            procedure Clear; virtual;
            function SearchField(PLang:Pointer; PSize : word; AID : String) : Pointer;  virtual;
            function FieldPtr(AID : String) : Pointer; virtual;
            function DataPtr(AID : String) : Pointer; virtual;
            function DataLen(P : Pointer) : word; virtual;
            function DataStr(AID : String) : String; virtual;
            function SearchMetaWildLang(PLang:Pointer; PSize : word; AWild : String) : boolean;  virtual;
            function SearchMetaWild(AWild : String) : boolean; virtual;
        end;

        PPackageList = ^TPackageList;
        TPackageList = object (TDirList)
        public
            constructor Create (AOwner : PObject);
            function GetClassName : String; virtual;
            function SizeOfObject : LongInt; virtual;
            function GetInstalled : integer; virtual;
        end;

function NewPackageLSM(AOwner:PObject) : PObject;
function NewPackageList(AOwner:PObject) : PObject;

implementation

{ TPackageLSM }
constructor TPackageLSM.Create(AOwner : PObject);
begin
    inherited Create(AOwner);
    DLang := nil;
    ULang := nil;
    DSize := 0;
    USize := 0;
end;

function TPackageLSM.ReadMetaData (APackage : String) : integer;
var
    I  : Word;

begin
    if Assigned(DLang) then Clear;
    ReadMetaData := 0;
    DLang := LoadAsciiFile(TailDelim(PackageLSMPath) + APackage + FileExtLSM, DSize);
    if Not Assigned(DLang) then begin
        ReadMetaData := DSize;
        Exit;
    end;
    if FileExists(TailDelim(PackageLSMPath) + APackage + '.' + UserLanguage) then begin
        ULang := LoadAsciiFile(TailDelim(PackageLSMPath) + APackage + '.' + UserLanguage, USize);
        if Not Assigned(ULang) then begin
            ReadMetaData := USize;
            Exit;
        end;

    end
end;

function TPackageLSM.WriteMetaData (APackage : String) : integer;
begin
    WriteMetaData := 0;
end;

function TPackageLSM.GetClassName : String;
begin
    GetClassName := 'TPackageLSM';
end;

function TPackageLSM.SizeOfObject : LongInt;
begin
    SizeOfObject := SizeOf(TPackageLSM);
end;

procedure TPackageLSM.Clear;
begin
    if Assigned(DLang) then FreeMem(DLang, DSize);
    if Assigned(ULang) then FreeMem(ULang, USize);
    DLang := nil;
    ULang := nil;
    DSize := 0;
    USize := 0;
end;

function TPackageLSM.SearchField(PLang:Pointer; PSize : word; AID : String) : Pointer;
var
    R : String;
    I : word;
begin
    SearchField := nil;
    AID := UCase(AID) + ':';
    if Not Assigned(PLang) or (PSize - 2 < Length(AID)) then Exit;
    I := 0;
    R[0] := AID[0];
    repeat
        Move(PAsciiZ(PLang)^[I], R[1], Length(AID));
        R := UCase(R);
        if R = AID then begin
            SearchField := Ptr(Seg(PLang^), Ofs(PLang^) + I );
            Exit;
        end;
        while (Pos(PAsciiZ(PLang)^[I], #$0A#$0D#$00) < 1) do Inc(I);
        while (Pos(PAsciiZ(PLang)^[I], #$0A#$0D) > 0) do Inc(I);
        { Inc(I); }
    until (I >= PSize - 2 - Length(AID)) or (PAsciiZ(PLang)^[I] = #0);
end;

function TPackageLSM.FieldPtr(AID : String) : Pointer;
var
    P : Pointer;
begin
    P := SearchField(ULang, USize, AID);
    if not Assigned(P) then P := SearchField(DLang, DSize, AID);
    FieldPtr := P;
end;

function TPackageLSM.DataPtr(AID : String) : Pointer;
var
    P : Pointer;
    I : word;
begin
    DataPtr := nil;
    P := FieldPtr(AID);
    if assigned(P) then begin
        I := Length(AID);
        repeat
            Inc(I);
        until (PAsciiZ(P)^[I] <> #9) and (PAsciiZ(P)^[I] <> #32);
        DataPtr := Ptr(Seg(P^), Ofs(P^) + I );
    end;
end;

function TPackageLSM.DataLen(P : Pointer) : word;
var
    I : word;
begin
    DataLen := 0;
    if assigned(P) then begin
        I := 0;
        while (Pos(PAsciiZ(P)^[I], #$0A#$0D#$00) < 1) do Inc(I);
        DataLen := I;
    end;
end;

function TPackageLSM.DataStr(AID : String) : String;
var
    P : Pointer;
    S : String;
    L : word;
begin
    DataStr := '';
    P := DataPtr(AID);
    if Assigned(P) then begin
        L := DataLen(P);
        DataStr:=IntStr(L);
        if L = 0 then Exit;
        if L > 254 then L := 254;
        S[0] := Chr(L);
        Move(P^, S[1], L);
        DataStr := S;
    end;
end;

function TPackageLSM.SearchMetaWildLang(PLang:Pointer; PSize : word; AWild : String) : boolean;
var
    R : String;
    I : word;
begin
    SearchMetaWildLang := False;
    if Not Assigned(PLang) or (PSize < 2) then Exit;
    I := 0;
    AWild := '*' + UCase(AWILD) + '*';
    repeat
        R := '';
        while (Pos(PAsciiZ(PLang)^[I], #$3A#$00) < 1) and (I < PSize) do Inc(I);
        while (PAsciiZ(PLang)^[I] = #$3A) and (I < PSize) do Inc(I);
        while (Pos(PAsciiZ(PLang)^[I], #$0A#$0D#$00) < 1) and (I < PSize) do begin
            R := R + (PAsciiZ(PLang)^[I]);
            Inc(I);
        end;
        if (R <> '') and MatchWildCard(AWild, UCase(R)) then begin
            SearchMetaWildLang:= True;
            Exit;
        end;
        while (Pos(PAsciiZ(PLang)^[I], #$0A#$0D#$00) < 1) and (I < PSize) do Inc(I);
        while (Pos(PAsciiZ(PLang)^[I], #$0A#$0D) > 0) and (I < PSize) do Inc(I);
        { Inc(I); }

    until (I >= PSize) or (PAsciiZ(PLang)^[I] = #0);
end;

function TPackageLSM.SearchMetaWild(AWild : String) : boolean;
var
    X : boolean;
begin
    X := SearchMetaWildLang(ULang, USize, AWild);
    if not X then
        X := SearchMetaWildLang(DLang, DSize, AWild);
    SearchMetaWild:= X;
end;

{ TPackageList }
constructor TPackageList.Create (AOwner : PObject);
begin
    inherited Create(AOwner);
    IncludeParent := False;
    IncludeDirs := False;
    Sorted := True;
end;

function TPackageList.GetClassName : String;
begin
    GetClassName := 'TPackageList';
end;

function TPackageList.SizeOfObject : LongInt;
begin
    SizeOfObject := SizeOf(TPackageList);
end;

function TPackageList.Getinstalled : integer;
begin
    GetDirList(TailDelim(PackageLSMPath) + '*' + FileExtLSM, faAnyFile);
    GetInstalled := Count;
end;

function NewPackageLSM(AOwner:PObject) : PObject;
begin
    NewPackageLSM := New(PPackageLSM, Create(AOwner));
end;

function NewPackageList(AOwner:PObject) : PObject;
begin
    NewPackageList := New(PPackageList, Create(AOwner));
end;

{ initialization & finalization routines }
begin
    PackageLSMPath := TailDelim(GetEnv('DOSDIR')) + 'APPINFO';
    PackageLSTPath := TailDelim(GetEnv('DOSDIR')) + 'PACKAGES';
    RegisterObject('TPackageLSM', NewPackageLSM);
    RegisterObject('TPackageList', NewPackageList);
end.