{
    Copyright 2019 Jerome Shidel
    Released Under GPL v2.0 License.
}

unit QDOS; { QuickCrt 9.x, DOS Unit }

{$I QCRT.DEF}

interface

    var
        PathDelim   : Char;
        SwitchChar  : Char;

    function GetExeName : String;
    function GetExeBase : String;
    function GetExePath : String;

    function GetEnv(const Key : String) : String;

implementation

uses
    QASCIIZ;

var
    OldExitProc : Pointer;

{$L QDOS.OBJ}

function GetExeName : String;
var
    P : integer;
    R : String;
begin
    R := ParamStr(0);
    P := Length(R);
    while (R[P] <> PathDelim) and (P > 0) do Dec(P);
    GetExeName := Copy(R, P + 1, Length(R));
end;

function GetExeBase : String;
var
    P : integer;
    R : String;
begin
    R := GetExeName;
    while (R[Length(R)] <> '.' ) and (Length(R) > 1) do Dec(R[0]);
    Dec(R[0]);
    GetExeBase := R;
end;

function GetExePath : String;
var
    P : integer;
    R : String;
begin
    R := ParamStr(0);
    while (R[Length(R)] <> PathDelim ) and (Length(R) > 1) do Dec(R[0]);
    Dec(R[0]);
    GetExePath := R;
end;

function GetEnv(const Key : String) : String;
begin
    GetEnv := KeyValueOnly(LookupASCIIZ(Ptr(MemW[PrefixSeg:$002c],0), Key));
end;

function InitQDOS(PSP : word) : boolean; external;
procedure DoneQDOS; external;

{ initialization & finalization routines }
procedure UnitFinal;
begin
    ExitProc := OldExitProc;
    DoneQDOS;
end;

procedure UnitInit;
var
    S : String;
begin
    if not InitQDOS(PrefixSeg) then Halt(10); { Internal Error }
    OldExitProc := ExitProc;
    ExitProc := @UnitFinal;
    PathDelim := '\';
    S := GetEnv('SWITCHCHAR');
    if S = '' then
        SwitchChar := '/'
    else
        SwitchChar := S[1];
end;

begin
    UnitInit;
end.
