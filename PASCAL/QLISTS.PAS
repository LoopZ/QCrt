{
    Copyright 2019 Jerome Shidel
    Released Under GPL v2.0 License.
}

unit QLists; { QuickCrt 9.x, List Unit }

{$I QCRT.DEF}

interface

    uses QClass;

    type
        PDataList = ^TDataList;
        PDataItem = ^TDataItem;
        TDataItem = object (TPersistent)
        private
            PPrevious, PNext : PDataItem;
            PData : Pointer;
        public
            constructor Create(AOwner : PObject);
            destructor Destroy; virtual;
        end;

        TDataList = object(TObject)
        end;

        PStringItem = ^TStringItem;
        PStringList = ^TStringList;
        TStringItem = object(TDataItem)
        end;

        TStringList = object(TDataList)
        end;

implementation

var
    OldExitProc : Pointer;

constructor TDataItem.Create(AOwner :PObject);
begin
    inherited Create(AOwner);
    PPrevious := nil;
    PNext := nil;
    PData := nil;
end;

destructor TDataItem.Destroy;
begin
    PPrevious := nil;
    PNext := nil;
    PData := nil;
    inherited Destroy;
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
