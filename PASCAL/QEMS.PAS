{
Copyright 1990-2021, Jerome Shidel
Released Under Mozilla Public License 2.0

This project and related files are subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file, You
can obtain one at http://mozilla.org/MPL/2.0/.
}

unit QEMS; { QuickCrt 9.x, EMS Unit }

{$I QCRT.DEF}

interface

implementation

var
    OldExitProc : Pointer;

{$L QEMS.OBJ}

{ initialization & finalization routines }

procedure DoneQEMS; external;

procedure UnitFinal;
begin
    ExitProc := OldExitProc;
    DoneQEMS;
end;

function InitQEMS : boolean; external;

procedure UnitInit;
begin
    if not InitQEMS then Halt(10); { Internal Error }
    {$IFDEF finalialization}
        OldExitProc := ExitProc;
        ExitProc := @UnitFinal;
    {$ENDIF}
end;

begin
    UnitInit;

end.
