unit MatomoFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MatomoSdkLib, Vcl.StdCtrls;

type
  TMatomoDlg = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
    matomo: TMatomo;
  public
    { Public-Deklarationen }
  end;

var
  MatomoDlg: TMatomoDlg;

implementation

{$R *.dfm}

procedure TMatomoDlg.Button1Click(Sender: TObject);
var
  event: TMatomoEvent;
begin
  event.category := 'App';
  event.action := 'User interaction';
  event.name := 'Button1 clicked';

  matomo.trackEvent(event);
end;

procedure TMatomoDlg.Button2Click(Sender: TObject);
begin
  matomo.ping;
end;

procedure TMatomoDlg.FormCreate(Sender: TObject);
var
  event: TMatomoEvent;
begin
  matomo := TMatomo.Create;
  matomo.MatomoURL := 'http://127.0.0.1/matomo/matomo.php';
  matomo.SiteId := '2';
  matomo.AppName := ExtractFileName(Application.ExeName);
  matomo.UserId := 'Max@Mustermann.com';

  event.category := 'App';
  event.action := 'Automatic actions';
  event.name := 'App started';

  matomo.trackEvent(event);
end;

procedure TMatomoDlg.FormDestroy(Sender: TObject);
begin
  matomo.Free;
end;

end.
