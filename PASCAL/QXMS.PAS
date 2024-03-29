{
Copyright 1990-2021, Jerome Shidel
Released Under Mozilla Public License 2.0

This project and related files are subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file, You
can obtain one at http://mozilla.org/MPL/2.0/.
}

unit QXMS; { QuickCrt 9.x, XMS Unit }

{$I QCRT.DEF}


interface

    function XMS_Avail : boolean;

implementation

var
    OldExitProc : Pointer;

{$L QXMS.OBJ}

function XMS_Avail : boolean; external;

{ initialization & finalization routines }

procedure DoneQXMS; external;

procedure UnitFinal;
begin
    ExitProc := OldExitProc;
    DoneQXMS;
end;

function InitQXMS : boolean; external;

procedure UnitInit;
begin
    if not InitQXMS then Halt(10); { Internal Error }
    OldExitProc := ExitProc;
    ExitProc := @UnitFinal;
end;

begin
    UnitInit;
end.
