program Matomo;

uses
  Vcl.Forms,
  MatomoFrm in 'MatomoFrm.pas' {MatomoDlg},
  MatomoSdkLib in 'MatomoSdkLib.pas',
  HttpClientWrapperLib in 'Http-Client-Wrapper\source\HttpClientWrapperLib.pas',
  NetHttpClientWrapper in 'Http-Client-Wrapper\source\NetHttpClientWrapper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMatomoDlg, MatomoDlg);
  Application.Run;
end.
