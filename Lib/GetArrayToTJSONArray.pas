unit GetArrayToTJSONArray;

interface

uses
  System.SysUtils, System.JSON;

function ArrayToJsonArray(const Values: TArray<Integer>): TJSONArray;

implementation

function ArrayToJsonArray(const Values: TArray<Integer>): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I in Values do
    Result.Add(I);
end;

end.
