unit Provider.Authorization;

interface

uses
  Horse,
  Horse.JWT;

function Authorization: THorseCallback;
function getToken(AUser: string): string;

implementation

uses
  JOSE.Core.JWT,
  JOSE.Core.Builder,
  System.SysUtils;

function Authorization: THorseCallback;
begin
  //Result := HorseJWT(GetEnvironmentVariable('KEY'));
  Result := HorseJWT('raulkey123');
end;


function getToken(AUser: string): string;
var
  LToken: TJWT;
  LCompactToken: string;
begin
  LToken := TJWT.Create;
  try
    // Token claims
    LToken.Claims.Issuer := 'Terapy';
    LToken.Claims.Subject := AUser;
    LToken.Claims.IssuedAt := Now;
    LToken.Claims.Expiration := Now + 1;

    // Signing and Compact format creation
    LCompactToken := TJOSE.SHA256CompactToken('raulkey123', LToken);
    Result := LCompactToken;
  finally
    LToken.Free;
  end;
end;

end.
