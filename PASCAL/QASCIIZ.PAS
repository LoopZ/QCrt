{
Copyright 1990-2021, Jerome Shidel
Released Under Mozilla Public License 2.0

This project and related files are subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file, You
can obtain one at http://mozilla.org/MPL/2.0/.
}

unit QAsciiZ; { QuickCrt 9.x, AsciiZ Unit }

{$I QCRT.DEF}

interface

type
    PAsciiZ = ^TAsciiZ;
    TAsciiZ = array[0..65534] of char;

    { Return Key and Value from AsciiZ Data Blob. Like Environment Table or
      Application Translation Messages, Returns empty string if not found.
      Returns Key & Value when found. }
    function LookupAsciiZ(Data : pointer; ID : String) : string;
    function FindAsciiZ(Data : pointer; ID : String) : PAsciiZ;
    { Similar to LookupAsciiZ. but returns a pointer to the ASCII string, or
      NIL if not found. }

    { Returns just the value portion of an AsciiZ lookup label Key + Value pair }
    function KeyValueOnly(S : String) : String;

    { Returns up to the first 254 characters of an AsciiZ string as a pascal
      string. }
    function PascalStr(const AsciiZ) : String;

    function LoadAsciiFile(AFileName : String; var ASize : Word) : pointer;
    { If pointer = nil, then ASize is an Error Code; When Successful,
      the File is loaded and a Zero is appended to the end. So, ASize is equal
      to the FileSize + 1 }


implementation

{$L QAsciiZ.OBJ}

function FindAsciiZ(Data : pointer; ID : String) : PAsciiZ;
var
    R : String;
    I : word;
begin
    ID := ID + '=';
    R[0] := ID[0];
    repeat
        Move(Data^, R[1], byte(R[0]));
        if (R <> ID) then begin
            repeat
                Data := Ptr(Seg(Data^), Ofs(Data^) + 1);
            until byte(Data^) = 0;
            Data := Ptr(Seg(Data^), Ofs(Data^) + 1);
        end;
    until (byte(Data^) = 0) or (R = ID);
    if R = ID then
        FindAsciiZ := Ptr(Seg(Data^), Ofs(Data^) + Length(ID))
    else
        FindAsciiZ := nil;
end;

function LookupAsciiZ(Data : pointer; ID : String) : string;
var
    R : String;
    I : word;
begin
    ID := ID + '=';
    R[0] := ID[0];
    repeat
        Move(Data^, R[1], byte(R[0]));
        if (R <> ID) then begin
            repeat
                Data := Ptr(Seg(Data^), Ofs(Data^) + 1);
            until byte(Data^) = 0;
            Data := Ptr(Seg(Data^), Ofs(Data^) + 1);
        end;
    until (byte(Data^) = 0) or (R = ID);
    if R = ID then begin
        R := '';
        repeat
            if Pos(Char(Data^), #13#10#0 ) < 1 then begin
                Inc(byte(R[0]));
                R[byte(R[0])] := Char(Data^);
            end;
            Data := Ptr(Seg(Data^), Ofs(Data^) + 1);
        until (byte(Data^) = 0) or (Length(R) = 255);
        LookupAsciiZ := R;
    end else
        LookupAsciiZ := '';
end;

function KeyValueOnly(S : String) : String;
begin
    KeyValueOnly := Copy(S, Pos('=', S) + 1, 255);
end;


function PascalStr(const AsciiZ) : String;
type
	AsciiZStr = array[0..$FF] of char;
var
	I : integer;
	S : String;
begin
	PascalStr := '';
	I := 0;
	while (I <= 254) and (AsciiZStr(AsciiZ)[I] <> #0) do Inc(I);
	if I <= 254 then begin
		Move(AsciiZ, S[1], I);
		S[0] := Chr(I);
		PascalStr := S;
	end;
end;

function LoadAsciiFile(AFileName : String; var ASize : Word) : pointer;
var
    P : Pointer;
    F : File;
    TS : LongInt;
    FM, Sz : Word;
    C : integer;
begin
    {$I-}
    LoadAsciiFile := nil;

    FM := FileMode;

    Assign(F, AFileName);
    FileMode:=0;
    Reset(F, 1);
    ASize := IOResult;
    if (ASize <> 0) then begin
        Exit;
    end;
    TS := FileSize(F);
    ASize := IOResult;
    if (TS > 65533) or (TS > MaxAvail - 10240) or (ASize <> 0) then begin
        if ASize = 0 then ASize := 8; { Not enough memory }
        Close(F);
        exit;
    end;
    Sz := TS + 1;
    GetMem(P, Sz);
    FillChar(P^, Sz, 0);
    BlockRead(F, P^, Sz - 1, C);
    ASize := IOResult;
    if (ASize <> 0) or ( Sz -1 <> C ) then
        FreeMem(P, Sz)
    else begin
        ASize := Sz;
        LoadAsciiFile := P;
    end;
    Close(F);

    FileMode:=FM;
    {$I+}
end;

end.
