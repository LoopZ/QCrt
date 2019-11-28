{
    Copyright 2019 Jerome Shidel
    Released Under GPL v2.0 License.
}

unit QClass; { QuickCrt 9.x, Class Unit }

{$I QCRT.DEF}

interface

type
    PObject = ^TObject;
    TObject = object
    private
        POwner : PObject;
    public
        constructor Create(AOwner : PObject);
        destructor Destroy; virtual;

    end;

    PPersistent = ^TPersistent;
    TPersistent = object (TObject)
    end;

implementation

var
    OldExitProc : Pointer;

constructor TObject.Create(AOwner : PObject);
begin
    POwner := AOwner;
end;

destructor TObject.Destroy;
begin
    POwner := nil;
end;

{ initialization & finalization routines }
procedure UnitFinal;
begin
    ExitProc := OldExitProc;
end;

procedure UnitInit;
begin
    OldExitProc := ExitProc;
    ExitProc := @UnitFinal;
end;

begin
    UnitInit;
end.
