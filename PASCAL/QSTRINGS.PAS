{
    Copyright 2019 Jerome Shidel
    Released Under GPL v2.0 License.
}

unit QStrings; { QuickCrt 9.x, Strings Unit }

{$I QCRT.DEF}

interface

implementation

var
    OldExitProc : Pointer;

{$L QSTRINGS.OBJ}

function InitQStrings : boolean; external;
procedure DoneQStrings; external;

{ initialization & finalization routines }
procedure UnitFinal;
begin
    ExitProc := OldExitProc;
    DoneQStrings;
end;

procedure UnitInit;
begin
    if not InitQStrings then Halt(10); { Internal Error }
    OldExitProc := ExitProc;
    ExitProc := @UnitFinal;
end;

begin
    UnitInit;
end.
