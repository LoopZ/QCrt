{
    Copyright 2019 Jerome Shidel
    Released Under GPL v2.0 License.
}

unit QEMS; { QuickCrt 9.x, EMS Unit }

{$I QCRT.DEF}

interface

implementation

var
    OldExitProc : Pointer;

{$L QEMS.OBJ}

function InitQEMS : boolean; external;
procedure DoneQEMS; external;

{ initialization & finalization routines }
procedure UnitFinal;
begin
    ExitProc := OldExitProc;
    DoneQEMS;
end;

procedure UnitInit;
begin
    if not InitQEMS then Halt(10); { Internal Error }
    OldExitProc := ExitProc;
    ExitProc := @UnitFinal;
end;

begin
    UnitInit;
end.
