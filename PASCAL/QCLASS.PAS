{
Copyright 1990-2021, Jerome Shidel
Released Under Mozilla Public License 2.0

This project and related files are subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file, You
can obtain one at http://mozilla.org/MPL/2.0/.
}

unit QClass; { QuickCrt 9.x, Class Unit }

{$I QCRT.DEF}

interface

type
    TObjectComparison = (ocLessThan, ocEqual, ocGreaterThan, ocNull);

    PObject = ^TObject;
    TObject = object
    private
        POwner : PObject;
    public
        constructor Create(AOwner : PObject);
        destructor Destroy; virtual;
        function GetClassName : String; virtual;
        function GetOwner : PObject;
        procedure SetOwner(AOwner : PObject);
        function Compare(AObject : PObject) : TObjectComparison; virtual;
        function SizeOfObject : LongInt; virtual;
        procedure Clear; virtual;
    end;

    TCreateFunction = function (AOwner : PObject) : PObject;
    TForEachFunction = function (AObject : PObject) : integer;

    PPersistent = ^TPersistent;
    TPersistent = object (TObject)
    public
        function GetClassName : String; virtual;
        function SizeOfObject : LongInt; virtual;
    end;

    PListItem = ^TListItem;
    TListItem = object (TObject)
    public
        PPrior,
        PNext : PListItem;
        PItem : PObject;
        constructor Create(AOwner : PObject);
        destructor Destroy; virtual;
        function GetClassName : String; virtual;
        function SizeOfObject : LongInt; virtual;
    end;

    PList = ^TList;
    TList = object (TObject)
    private
        PFirst,
        PLast,
        PCurrent : PListItem;
        FCount : LongInt;
    public
        constructor Create(AOwner : PObject);
        function GetClassName : String; virtual;
        function SizeOfObject : LongInt; virtual;
        procedure Clear; virtual;
        function ForEach ( AFunction : TForEachFunction ) : integer; virtual;
        function AddItem(AObject : PObject) : PObject; virtual;
        function InsertItem(AObject : PObject; ABefore : PListItem) : PObject; virtual;
        function Count : LongInt; virtual;
        function GetFirst : PListItem; virtual;
        function GetLast : PListItem; virtual;
    end;

procedure RegisterObject(const AClassName : String; const ACreate : TCreateFunction);

function NewObject(AOwner:PObject) : PObject;
function NewPersistent(AOwner:PObject) : PObject;
function NewListItem(AOwner:PObject) : PObject;
function NewList(AOwner:PObject) : PObject;

implementation

constructor TObject.Create(AOwner : PObject);
begin
    POwner := AOwner;
end;

destructor TObject.Destroy;
begin
    Clear;
    POwner := nil;
end;

function TObject.GetClassName : String;
begin
    GetClassName := 'TObject';
end;

function TObject.GetOwner : PObject;
begin
    GetOwner := POwner;
end;

procedure TObject.SetOwner(AOwner : PObject);
begin
    POwner:= AOwner;
end;

function TObject.Compare(AObject : PObject) : TObjectComparison;
begin
    if not Assigned(AObject) then
        Compare := ocNull
    else if GetClassName <> AObject^.GetClassName then
        Compare := ocNull
    else
        Compare := ocEqual;
end;

function TObject.SizeOfObject : LongInt;
begin
    SizeOfObject := SizeOf(TObject);
end;

procedure TObject.Clear;
begin
    {WriteLn(GetClassName, '.Clear');}
end;

{ TPersistent }

function TPersistent.GetClassName : String;
begin
    GetClassName := 'TPersistent';
end;

function TPersistent.SizeOfObject : LongInt;
begin
    SizeOfObject := SizeOf(TPersistent);
end;

{ TListItem }
constructor TListItem.Create(AOwner : PObject);
begin
    inherited Create(AOwner);
    PNext := nil;
    PPrior := nil;
    PItem := nil;
end;

destructor TListItem.Destroy;
begin
    if Assigned(PItem) then Dispose(PItem, Destroy);
    PPrior := nil;
    PNext := nil;
    inherited Destroy;
end;

function TListItem.GetClassName : String;
begin
    GetClassName := 'TListItem';
end;

function TListItem.SizeOfObject : LongInt;
begin
    SizeOfObject := SizeOf(TListItem);
end;

{ TList }

constructor TList.Create(AOwner : PObject);
begin
    inherited Create(AOwner);
    PFirst := nil;
    PLast := nil;
    PCurrent := nil;
    FCount := 0;
end;

function TList.GetClassName : String;
begin
    GetClassName := 'TPersistent';
end;

function TList.SizeOfObject : LongInt;
begin
    SizeOfObject := SizeOf(TPersistent);
end;

procedure TList.Clear;
var
    P : PListItem;
begin
    While Assigned(PFirst) do begin
        P := PFirst;
        PFirst := P^.PNext;
        Dispose(P, Destroy);
    end;
    PFirst := nil;
    PLast := nil;
    PCurrent := nil;
    FCount := 0;
    inherited Clear;
end;

function TList.ForEach ( AFunction : TForEachFunction ) : integer;
var
    Ret : integer;
begin
    PCurrent := PFirst;
    Ret := 0;
    While Assigned(PCurrent) and (Ret = 0) do begin
        if Assigned(PCurrent^.PItem) then
            Ret := AFunction(PCurrent^.PItem);
        PCurrent := PCurrent^.PNext;
    end;
    if not Assigned(PCurrent) then PCurrent := PLast;
    ForEach:=Ret;
end;

function TList.AddItem(AObject : PObject) : PObject;
begin
    PCurrent := PListItem(NewListItem(@Self));
    PCurrent^.PItem := AObject;
    if Assigned(PLast) then begin
        PCurrent^.PPrior := PLast;
        PLast^.PNext := PCurrent;
        PLast := PCurrent;
    end else begin
        PLast := PCurrent;
        PFirst := PCurrent;
    end;
    Inc(FCount);
    AddItem := PCurrent;
end;

function TList.InsertItem(AObject : PObject; ABefore : PListItem) : PObject;
begin
    if ABefore = nil then ABefore := PFirst;
    PCurrent := PListItem(NewListItem(@Self));
    PCurrent^.PItem := AObject;
    if Assigned(ABefore) then begin
        PCurrent^.PNext := ABefore;
        PCurrent^.PPrior := ABefore^.PPrior;
        if Assigned(PCurrent^.PPrior) then
            PCurrent^.PPrior^.PNext := PCurrent;
        ABefore^.PPrior := PCurrent;
        if PCurrent^.PPrior = nil then
            PFirst := PCurrent;
    end else begin
        PLast := PCurrent;
        PFirst := PCurrent;
    end;
    Inc(FCount);
    InsertItem := PCurrent;
end;

function TList.Count : LongInt;
begin
    Count := FCount;
end;

function TList.GetFirst : PListItem;
begin
    GetFirst := PFirst;
end;

function TList.GetLast : PListItem;
begin
    GetLast := PLast;
end;

{ Unit procedures and functions }

procedure RegisterObject(const AClassName : String; const ACreate : TCreateFunction);
begin
    { WriteLn(AClassName); }
end;

function NewObject(AOwner:PObject) : PObject;
begin
    NewObject := New(PObject, Create(AOwner));
end;

function NewPersistent(AOwner:PObject) : PObject;
begin
    NewPersistent := New(PPersistent, Create(AOwner));
end;

function NewListItem(AOwner:PObject) : PObject;
begin
    NewListItem := New(PListItem, Create(AOwner));
end;

function NewList(AOwner:PObject) : PObject;
begin
    NewList := New(PList, Create(AOwner));
end;

{ initialization & finalization routines }
begin
    RegisterObject('TObject', NewObject);
    RegisterObject('TPersistent', NewPersistent);
    RegisterObject('TListItem', NewList);
    RegisterObject('TList', NewList);
end.
