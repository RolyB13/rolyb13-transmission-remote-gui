unit varlist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, variants;

type

  { TVarList }

  TVarList = class(TList)
  private
    FColCnt: integer;
    function GetItems(ACol, ARow: integer): variant;
    function GetRowCnt: integer;
    function GetRows(ARow: integer): variant;
    function GetRow(ARow: integer): PVariant;
    procedure SetItems(ACol, ARow: integer; const AValue: variant);
    procedure SetRowCnt(const AValue: integer);

  public
    constructor Create(AColCnt, ARowCnt: integer);
    procedure Clear; override;
    procedure Delete(Index: Integer);
    procedure Sort(ACol: integer; Descending: boolean = False);
    property Items[ACol, ARow: integer]: variant read GetItems write SetItems; default;
    property Rows[ARow: integer]: variant read GetRows;
    property ColCnt: integer read FColCnt;
    property RowCnt: integer read GetRowCnt write SetRowCnt;
    property Count: integer read GetRowCnt;
  end;

implementation

{ TVarList }

function TVarList.GetItems(ACol, ARow: integer): variant;
begin
  Result:=GetRow(ARow)^[ACol];
end;

function TVarList.GetRowCnt: integer;
begin
  Result:=inherited GetCount;
end;

function TVarList.GetRows(ARow: integer): variant;
begin
  Result:=GetRow(ARow)^;
end;

function TVarList.GetRow(ARow: integer): PVariant;
var
  v: PVariant;
begin
  if ARow >= Count then
    SetCount(ARow + 1);
  v:=Get(ARow);
  if v = nil then begin
    v:=GetMem(SizeOf(variant));
    FillChar(v^, SizeOf(variant), 0);
    v^:=VarArrayCreate([0, FColCnt - 1], varVariant);
    Put(ARow, v);
  end;
  Result:=v;
end;

procedure TVarList.SetItems(ACol, ARow: integer; const AValue: variant);
begin
  GetRow(ARow)^[ACol]:=AValue;
end;

procedure TVarList.SetRowCnt(const AValue: integer);
begin
  while Count > AValue do
    Delete(Count - 1);
  SetCount(AValue);
end;

constructor TVarList.Create(AColCnt, ARowCnt: integer);
begin
  inherited Create;
  FColCnt:=AColCnt;
  RowCnt:=ARowCnt;
end;

procedure TVarList.Clear;
var
  i: integer;
  v: PVariant;
begin
  for i:=0 to Count - 1 do begin
    v:=inherited Get(i);
    if v <> nil then begin
      VarClear(v^);
      FreeMem(v);
    end;
  end;
  inherited Clear;
end;

procedure TVarList.Delete(Index: Integer);
var
  v: PVariant;
begin
  v:=inherited Get(Index);
  if v <> nil then begin
    VarClear(v^);
    FreeMem(v);
  end;
  inherited Delete(Index);
end;

var
  FSortColumn: integer;
  FSortDesc: boolean;

function CompareItems(Item1, Item2: Pointer): Integer;
var
  v1, v2: PVariant;
begin
  v1:=Item1;
  v2:=Item2;
  if v1^[FSortColumn] > v2^[FSortColumn] then
    Result:=1
  else
    if v1^[FSortColumn] < v2^[FSortColumn] then
      Result:=-1
    else
      if v1^[0] > v2^[0] then
        Result:=1
      else
        if v1^[0] < v2^[0] then
          Result:=-1
        else
          Result:=0;
  if FSortDesc then
    Result:=-Result;
end;

procedure TVarList.Sort(ACol: integer; Descending: boolean);
begin
  FSortColumn:=ACol;
  FSortDesc:=Descending;
  inherited Sort(@CompareItems);
end;

end.
