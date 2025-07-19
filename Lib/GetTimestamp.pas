unit GetTimestamp;

interface


function GetTimestampStr: string;

implementation

uses
  System.SysUtils;

function GetTimestampStr: string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

end.
