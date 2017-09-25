Unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, nrclasses, nratcmd, nrgsm, nrcomm, StdCtrls, nrcommbox,
  nrlogfile, Spin, nrgsmpdu, ComCtrls, ExtCtrls, WinSkinData;

type
  TForm1 = class(TForm)
    nrComm1: TnrComm;                      
    nrGsm1: TnrGsm;
    Pages: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label4: TLabel;
    eMem: TComboBox;
    Button6: TButton;
    Button5: TButton;
    Label3: TLabel;
    Edit1: TEdit;
    Button2: TButton;
    Memo1: TMemo;
    TabSheet3: TTabSheet;
    lvInfo: TListView;
    Label7: TLabel;
    chConfirm: TCheckBox;
    pgTerminal: TTabSheet;
    Memo3: TMemo;
    pgBook: TTabSheet;
    lvPhones: TListView;
    Panel1: TPanel;
    ePhoneBookType: TComboBox;
    Button7: TButton;
    Label8: TLabel;
    nrLogFile1: TnrLogFile;
    Panel2: TPanel;
    CheckBox1: TCheckBox;
    nrDeviceBox1: TnrDeviceBox;
    Button1: TButton;
    SB: TStatusBar;
    Timer1: TTimer;
    SkinData1: TSkinData;
    Label2: TLabel;
    cbOnNewSms: TComboBox;
    chAutodetect: TCheckBox;
    Label9: TLabel;
    eDrivers: TComboBox;
    LVSms: TListView;
    Memo2: TMemo;
    Button3: TButton;
    procedure CheckBox1Click(Sender: TObject);
    procedure nrGsm1AfterInit(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure nrGsm1GsmError(Sender: TObject; sData: String);
    procedure nrGsm1Ring(Sender: TObject; sData: String);
    procedure Button1Click(Sender: TObject);
  {  procedure Button4Click(Sender: TObject);}
    procedure Button5Click(Sender: TObject);
    procedure nrGsm1SmsReceived(Sender: TObject; aMem: String;
      idSms: Integer; aSms: TnrPduSms);
    procedure nrGsm1SmsListItem(Sender: TObject; aMem: String;
      idSms: Integer; aSms: TnrPduSms);
    procedure Button6Click(Sender: TObject);
    procedure cbOnNewSmsChange(Sender: TObject);
    procedure nrGsm1SmsSent(Sender: TObject; aMem: String; idSms: Integer;
      aSms: TnrPduSms);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure nrGsm1PhoneListFinish(Sender: TObject);
    procedure nrGsm1PhoneListProgress(Sender: TObject;
      var flBreak: Boolean);
    procedure Memo3DblClick(Sender: TObject);
    procedure pgOptionsShow(Sender: TObject);
    procedure chAutodetectClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure LVSmsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMDeviceChange(var Msg:TMessage); message WM_DEVICECHANGE;
    procedure AddInfo(sCapt, sVal: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  G : String;
implementation

uses clipbrd;

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
var i:integer;
begin
  chAutodetect.Checked := nrGsm1.Autodetect;
  Pages.ActivePageIndex := 0;
  cbOnNewSms.ItemIndex := Integer(nrGsm1.NewSmsMode);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  try
    nrGsm1.NewSmsMode := TgsmNewSmsMode(cbOnNewSms.ItemIndex);
    nrGsm1.Autodetect := chAutodetect.Checked;
    if not nrGsm1.Autodetect then
      nrGsm1.DriverIndex := eDrivers.ItemIndex;
    nrComm1.Active := CheckBox1.Checked;
  except
    CheckBox1.Checked := nrComm1.Active;
    raise;
  end;
end;

procedure TForm1.AddInfo(sCapt, sVal: string);
var Itm:TListItem;
begin
  if Trim(sVal) = '' then exit;
  with lvInfo do begin
    Itm := Items.Add;
    Itm.Caption := sCapt;
    Itm.SubItems.Add(sVal);
  end;
end;

procedure TForm1.nrGsm1AfterInit(Sender: TObject);
begin
  SB.Panels.Items[2].Text := 'Perangkat GSM Terhubung';
  lvInfo.Clear;
  AddInfo('Vendor', nrGsm1.DeviceManufacturer);
  AddInfo('Model', nrGsm1.DeviceName);
  AddInfo('Versi', nrGsm1.DeviceVersion);
  AddInfo('IMEI', nrGsm1.DeviceIMEI);
  AddInfo('Driver', nrGsm1.Driver.Caption);
  eMem.Items.Text := nrGsm1.MemTypesRead.Text;
  eMem.ItemIndex := eMem.Items.Count - 1;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  nrGSm1.SmsSend(Edit1.Text,Memo1.Text, chConfirm.Checked);
end;

procedure TForm1.nrGsm1GsmError(Sender: TObject; sData: String);
begin
  SB.Panels.Items[2].Text := 'Perangkat GSM Terhubung';
  SB.Panels.Items[2].Text := 'GSM Error :'+sData;
end;

procedure TForm1.nrGsm1Ring(Sender: TObject; sData: String);
begin
  SB.Panels.Items[2].Text := 'Perangkat GSM Terhubung';
  SB.Panels.Items[2].Text := 'RING: ' + sData;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  nrComm1.ConfigDialog;
end;

procedure TForm1.WMDeviceChange(var Msg: TMessage);
begin
  nrComm1.WMDeviceChange(Msg);
end;

procedure TForm1.nrGsm1SmsReceived(Sender: TObject; aMem: String;
  idSms: Integer; aSms: TnrPduSms);
begin
  SB.Panels.Items[2].Text := 'Perangkat GSM Terhubung';
  if aMem <> '' then
    SB.Panels.Items[2].Text := 'Sms is received "' + aMem+'",'+ IntToStr(idSms)
  else
    SB.Panels.Items[2].Text := 'Pesan Diterima';
  if aSms <> nil then
  begin
    if aSms.Report then
      SB.Panels.Items[2].Text := aSms.ReportText
    else
      SB.Panels.Items[2].Text := 'SMS: From: ' + aSms.Phone + ' text: '+ aSms.Text;
  end;
end;

procedure TForm1.nrGsm1SmsListItem(Sender: TObject; aMem: String;
  idSms: Integer; aSms: TnrPduSms);
Var I : TListItem;
begin
  SB.Panels.Items[2].Text := 'Perangkat GSM Terhubung';
  if aSms <> nil then
  begin
    if not aSms.Report then
    begin
      I := LVSms.Items.Add;
      I.Caption := ('+'+aSms.Phone);
      I.SubItems.Add(aSms.Text);
      I.SubItems.Add(IntToStr(idSms));
      I.SubItems.Add(DateToStr(aSms.DateTime))
    end;
  end
  else
    SB.Panels.Items[2].Text := 'Sinkronasi Pesan SMS Selesai';
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  SB.Panels.Items[2].Text := 'Perangkat GSM Terhubung';
  If nrGSM1.SmsDelete(StrToInt(LVSms.Selected.SubItems.Strings[1])) Then
    SB.Panels.Items[2].Text := 'OK'
  else
    SB.Panels.Items[2].Text := 'Error';
  LVSms.Items.Clear;
  If LVSms.Items.Count = 0 Then
  Begin
    Button6.Click;
    Memo2.Text:='';
  End;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  nrGSM1.MemoryRead :=  eMem.Text;
  nrGSM1.SmsList(False);
end;

procedure TForm1.cbOnNewSmsChange(Sender: TObject);
begin
  nrGsm1.NewSmsMode := TgsmNewSmsMode(cbOnNewSms.ItemIndex);
end;

procedure TForm1.nrGsm1SmsSent(Sender: TObject; aMem: String;
  idSms: Integer; aSms: TnrPduSms);
begin
  SB.Panels.Items[2].Text := 'Pesan Terkirim';
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  nrGsm1.PhoneListType := TnrPhoneBookType(ePhoneBookType.ItemIndex);
  nrGsm1.PhoneBookRead;
  Label8.Caption := 'Pembacaan ... ';
end;

procedure TForm1.nrGsm1PhoneListFinish(Sender: TObject);
var i : integer;
    itm:TListItem;
begin
  lvPhones.Clear;
  for i := 0 to nrGsm1.PhoneList.Count - 1 do begin
    itm := lvPhones.Items.Add;
    itm.Caption := nrGsm1.PhoneList.Item[i].Caption;
    itm.SubItems.Add(nrGsm1.PhoneList.Item[i].Phone);
  end;
  Label8.Caption := 'Total:'+IntToStr(nrGsm1.PhoneList.Count);
  SB.Panels.Items[2].Text := 'Sinkronasi Kontak Selesai';
end;

procedure TForm1.nrGsm1PhoneListProgress(Sender: TObject;
  var flBreak: Boolean);
begin
  Label8.Caption := 'Total :'+ IntToStr(nrGsm1.PhoneList.Count);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // hide terminal page ...
  lvInfo.Items.Add;
  nrComm1.Terminal := nil;
  pgTerminal.Free;
end;

procedure TForm1.Memo3DblClick(Sender: TObject);
var s:string;
    i:integer;
begin
  // insert from clipboard into terminal ...
  s := Clipboard.AsText;
  s := StringReplace(s, '\1Ah', #$1a, []);
  s := StringReplace(s, '\0Dh', #$0D, []);
  for i := 1 to Length(s) do
    PostMessage(Memo3.Handle, WM_CHAR, DWord(s[i]),0 );
end;

procedure TForm1.pgOptionsShow(Sender: TObject);
var i : integer;
begin
  // load driver list ...
  eDrivers.Clear;
  for i := 0 to nrGsm1.DriverCount - 1 do
    eDrivers.Items.Add(nrGsm1.Drivers[i].Caption);
  chAutodetect.Checked := nrGsm1.Autodetect;
end;

procedure TForm1.chAutodetectClick(Sender: TObject);
begin
  eDrivers.Enabled := not chAutodetect.Checked;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Sb.Panels.Items[0].Text := TimeToStr(Time);
  Sb.Panels.Items[1].Text := DateToStr(Date);
end;

procedure TForm1.LVSmsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
      Memo2.Text := Item.SubItems.Strings[0];
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  LVSms.Items.Clear;
end;

end.
