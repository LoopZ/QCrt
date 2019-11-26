{
    Copyright 2019 Jerome Shidel
    Released Under GPL v2.0 License.
}

unit QDOS; { QuickCrt 9.x, DOS Unit }

{$I QCRT.DEF}

interface

    function XMS_Avail : boolean;

implementation

var
    OldExitProc : Pointer;

{$L QDOS.OBJ}

function XMS_Avail : boolean; external;

function InitQDOS : boolean; external;
procedure DoneQDOS; external;

{ initialization & finalization routines }
procedure UnitFinal;
begin
    ExitProc := OldExitProc;
    DoneQDOS;
end;

procedure UnitInit;
begin
    if not InitQDOS then Halt(10); { Internal Error }
    OldExitProc := ExitProc;
    ExitProc := @UnitFinal;
end;

begin
    UnitInit;
end.
