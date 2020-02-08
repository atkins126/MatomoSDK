unit MatomoSdkLib;

interface

uses
  System.SysUtils, System.Classes, HttpClientWrapperLib;

type
  TMatomoEvent = record
    category: String;
    action: String;
    name: String;
    value: Double;
    function ToParams: TStrings;
  end;

  TMatomo = class(TObject)
  private
    FMatomoUrl: String;
    FSiteId: String;
    FId: String;
    FAppName: String;
    FUserId: String;

    procedure GenerateId;
    function GetRandomInt: String;
    function GetScreenResolution: String;
    function GetAppName: String;
    function GetUserAgent: String;

    function getDefaultParams: TStringList;
    function GenerateRequest(params: TStrings): String;

    procedure SetMatomoUrl(const Value: String);
  public
    procedure track;
    procedure trackEvent(event: TMatomoEvent);
    procedure ping;

    property MatomoURL: String read FMatomoUrl write SetMatomoUrl;
    property SiteId: String read FSiteId write FSiteId;
    property AppName: String read FAppName write FAppName;

    property Id: String read FId write FId; //TrackingId
    property UserId: String read FUserId write FUserId;
  end;

implementation

uses
  System.NetEncoding, NetHttpClientWrapper;

{ TMatomo }

procedure TMatomo.GenerateId;
var
  tmpGuid: string;
begin
  tmpGuid := TGUID.NewGuid.ToString;
  tmpGuid := tmpGuid.Replace('{', '', [rfReplaceAll])
                    .Replace('-', '', [rfReplaceAll])
                    .Replace('Empty}', '', [rfReplaceAll]);
  FID := tmpGuid.Substring(0, 16);
end;

function TMatomo.GenerateRequest(params: TStrings): String;
var
  i: Integer;
  requestParamStr: string;
begin
  requestParamStr := '';
  for i := 0 to params.Count-1 do
  begin
    if not requestParamStr.IsEmpty then requestParamStr := requestParamStr +'&';
    requestParamStr := requestParamStr + params[i];
  end;
  Result := FMatomoUrl+'?'+requestParamStr;
end;

function TMatomo.GetAppName: String;
begin
  Result := AppName;
  if not Result.StartsWith('http', true) then Result := 'http://'+Result;
end;

function TMatomo.getDefaultParams: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('idsite='+FSiteId);
  Result.Add('rec=1');
  Result.Add('_id='+FId);
  Result.Add('rand='+GetRandomInt);
  Result.Add('apiv=1');
  Result.Add('url='+GetAppName);
  Result.Add('ua='+GetUserAgent);
  Result.Add('res='+GetScreenResolution);
  { TODO : Get the correct system language }
  Result.Add('lang=de');
  if not FUserId.Trim.IsEmpty then Result.Add('uid='+FUserId);
end;

function TMatomo.GetRandomInt: String;
begin
  Randomize;
  Result := IntToStr(Random(10000));
end;

function TMatomo.GetScreenResolution: String;
begin
  { TODO : Get the correct screen size }
  Result := '1280x1024';
  Result := TNetEncoding.URL.EncodeQuery(Result);
end;

function TMatomo.GetUserAgent: String;
begin
  { TODO : Generate correct useragent }
  Result := 'Microsoft Windows 10';
end;

procedure TMatomo.ping;
var
  sl: TStringList;
  requestUrl: String;
  FHttpClient: THttpClientWrapper;
begin
  if FId.Trim.IsEmpty then GenerateId;

  sl := getDefaultParams;
  sl.Add('ping=1');
  requestUrl := GenerateRequest(sl);
  sl.Free;

  FHttpClient := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  FHttpClient.AsyncGet(requestUrl);
end;

procedure TMatomo.SetMatomoUrl(const Value: String);
begin
  FMatomoUrl := Value;
  if not FMatomoUrl.EndsWith('matomo.php') then
  begin
    raise Exception.Create('Unexpected URL: URL must end with "matomo.php"');
  end;
end;

procedure TMatomo.track;
var
  sl: TStringList;
  requestUrl: String;
  FHttpClient: THttpClientWrapper;
begin
  if FId.Trim.IsEmpty then GenerateId;

  sl := getDefaultParams;
  requestUrl := GenerateRequest(sl);
  sl.Free;

  FHttpClient := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  FHttpClient.AsyncGet(requestUrl);
end;

procedure TMatomo.trackEvent(event: TMatomoEvent);
var
  sl: TStringList;
  requestUrl: String;
  FHttpClient: THttpClientWrapper;
  additionalParams: TStrings;
begin
  if FId.Trim.IsEmpty then GenerateId;

  sl := getDefaultParams;
  additionalParams := event.ToParams;
  sl.AddStrings(additionalParams);
  additionalParams.Free;
  requestUrl := GenerateRequest(sl);
  sl.Free;

  FHttpClient := THttpClientWrapper.Create(TNetHttpClientWrapper.Create);
  FHttpClient.AsyncGet(requestUrl);
end;

{ TMatomoEvent }

function TMatomoEvent.ToParams: TStrings;
begin
  Result := TStringList.Create;
  Result.Add('e_c='+category);
  Result.Add('e_a='+action);
  Result.Add('e_n='+name);
  Result.Add('e_v='+FloatToStr(value));
end;

end.
