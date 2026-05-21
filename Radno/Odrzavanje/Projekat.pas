unit Projekat;

{
  AquaCentar — AquaMaintain Modul
  Upravljanje odrzavanjem vodenog sportskog centra

  Moduli:
    - Dashboard (pregled alarma i otvorenih naloga)
    - Merenja vode (pH, hlor, temperatura po bazenu)
    - Radni nalozi (otvaranje, pracenje, zatvaranje)
    - Oprema (evidencija i status)
    - Magacin (zalihe materijala)

  Vizuelni stil: AquaCentar tamna morska tema
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.IOUtils, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.TabControl, FMX.Layouts, FMX.StdCtrls, FMX.Edit,
  FMX.Controls.Presentation, FMX.Objects, FMX.ScrollBox,
  FMX.ListView, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ComboEdit, FMX.Memo,
  FMX.Memo.Types,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Data.DB,
  Unit2;

const
  CLR_BG       = $FF0A1628;
  CLR_CARD     = $FF0D2444;
  CLR_CARD2    = $FF102A52;
  CLR_BLUE     = $FF1E7EC8;
  CLR_BRIGHT   = $FF2196F3;
  CLR_WHITE    = $FFFFFFFF;
  CLR_DIM      = $FFAACCEE;
  CLR_GREEN    = $FF4CAF50;
  CLR_ORANGE   = $FFFF9800;
  CLR_RED      = $FFE53935;
  CLR_YELLOW   = $FFFFC107;

type
  TfrmMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    { Login }
    procedure btnLoginClick(Sender: TObject);
    procedure btnGoRegisterClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure btnBackToLoginClick(Sender: TObject);

    { Nav }
    procedure btnNavDashClick(Sender: TObject);
    procedure btnNavMerenjeClick(Sender: TObject);
    procedure btnNavNaloziClick(Sender: TObject);
    procedure btnNavOpremaClick(Sender: TObject);
    procedure btnNavMagacinClick(Sender: TObject);

    { Dashboard }
    procedure btnRefreshDashClick(Sender: TObject);

    { Merenja }
    procedure btnNovoMerenjeClick(Sender: TObject);
    procedure btnSaveMerenjeClick(Sender: TObject);
    procedure btnCancelMerenjeClick(Sender: TObject);

    { Radni nalozi }
    procedure btnNoviNalogClick(Sender: TObject);
    procedure btnSaveNalogClick(Sender: TObject);
    procedure btnCancelNalogClick(Sender: TObject);
    procedure cmbNalogFilterChange(Sender: TObject);
    procedure NalogCardClick(Sender: TObject);
    procedure btnZatvoriNalogClick(Sender: TObject);
    procedure btnBackNalogClick(Sender: TObject);

    { Oprema }
    procedure btnNovaOpremaClick(Sender: TObject);
    procedure btnSaveOpremaClick(Sender: TObject);
    procedure btnCancelOpremaClick(Sender: TObject);
    procedure OpremaCardClick(Sender: TObject);

    { Magacin }
    procedure btnNoviMatClick(Sender: TObject);
    procedure btnSaveMatClick(Sender: TObject);
    procedure btnCancelMatClick(Sender: TObject);

  private
    { Tabs }
    tcMain                          : TTabControl;
    tiLogin, tiRegister, tiDashboard, tiMerenje : TTabItem;
    tiNalozi, tiOprema, tiMagacin   : TTabItem;
    tiNalogForm, tiNalogDetail      : TTabItem;
    tiOpremaForm, tiMatForm         : TTabItem;
    tiMerenjeForm                   : TTabItem;

    { Login }
    edtUser, edtPass : TEdit;
    { Register }
    edtRegEmpID, edtRegUsername, edtRegPass, edtRegPass2 : TEdit;
    lblRegErr : TLabel;
    btnLogin         : TCornerButton;
    lblLoginErr      : TLabel;

    { Dashboard }
    sbDash           : TScrollBox;
    btnRefreshDash   : TCornerButton;

    { Merenja }
    sbMerenja        : TScrollBox;
    btnNovoMerenje   : TCornerButton;
    cmbMerBazen      : TComboEdit;
    edtMerPH         : TEdit;
    edtMerHlor       : TEdit;
    edtMerTemp       : TEdit;
    edtMerUneo       : TEdit;
    lblMerErr        : TLabel;

    { Radni nalozi }
    sbNalozi         : TScrollBox;
    cmbNalogFilter   : TComboEdit;
    btnNoviNalog     : TCornerButton;
    { Nalog forma }
    cmbNalogBazen    : TComboEdit;
    cmbNalogOprema   : TComboEdit;
    cmbNalogTip      : TComboEdit;
    cmbNalogKat      : TComboEdit;
    cmbNalogPrior    : TComboEdit;
    edtNalogIzvrsio  : TEdit;
    memoNalogOpis    : TMemo;
    chkBlokiraj      : TCheckBox;
    lblNalogErr      : TLabel;
    { Nalog detail }
    sbNalogDetail    : TScrollBox;
    lblNalogDetTitle : TLabel;
    btnZatvoriNalog  : TCornerButton;

    { Oprema }
    sbOprema         : TScrollBox;
    btnNovaOprema    : TCornerButton;
    edtOpNaziv       : TEdit;
    cmbOpTip         : TComboEdit;
    cmbOpStatus      : TComboEdit;
    edtOpModel       : TEdit;
    edtOpSerial      : TEdit;
    edtOpDatum       : TEdit;
    cmbOpBazen       : TComboEdit;
    memoOpNap        : TMemo;
    lblOpErr         : TLabel;

    { Magacin }
    sbMagacin        : TScrollBox;
    btnNoviMat       : TCornerButton;
    edtMatNaziv      : TEdit;
    cmbMatTip        : TComboEdit;
    edtMatJed        : TEdit;
    edtMatZal        : TEdit;
    edtMatMin        : TEdit;
    lblMatErr        : TLabel;

    { State }
    FNalogCurrentID  : Integer;
    FNalogIsNew      : Boolean;
    FOpCurrentID     : Integer;
    FOpIsNew         : Boolean;
    FMatCurrentID    : Integer;
    FMatIsNew        : Boolean;
    FBazenIDs        : array of Integer;
    FOpremaIDs       : array of Integer;

    { Build }
    procedure BuildUI;
    procedure AddNavBar(ATab: TTabItem; AActive: Integer);

    { Data }
    procedure RefreshDashboard;
    procedure LoadMerenja;
    procedure LoadNalozi(const AFilter: string = '');
    procedure LoadOprema;
    procedure LoadMagacin;
    procedure LoadBazenCombo(ACombo: TComboEdit);
    procedure LoadOpremaCombo;

    { Cards }
    procedure AddAlarmCard(AParent: TFmxObject; const AText, ASub: string;
      AColor: TAlphaColor; var AY: Single);
    procedure AddMerenjeCard(AID: Integer; const ABazen, ADatum: string;
      APH, AHlor, ATemp: Double; AAlarm: Boolean; var AY: Single);
    procedure AddNalogCard(AID: Integer; const ATip, AOpis, AStatus: string;
      APrior: Integer; var AY: Single);
    procedure AddOpremaCard(AID: Integer; const ANaziv, ATip, AStatus: string;
      var AY: Single);
    procedure AddMatCard(AID: Integer; const ANaziv, ATip: string;
      AZal, AMin: Double; var AY: Single);

    { Nalog detail }
    procedure ShowNalogDetail(AID: Integer);

    { Auth }
    function SimpleHash(const S: string): string;
    { UI Helpers }
    function MkRect(AParent: TFmxObject; X, Y, W, H: Single;
      AColor: TAlphaColor; ARadius: Single = 0): TRectangle;
    function MkLbl(AParent: TFmxObject; const AText: string;
      X, Y, W, H, ASize: Single; ABold: Boolean = False): TLabel;
    function MkEdit(AParent: TFmxObject; const APrompt: string;
      X, Y, W: Single; APass: Boolean = False): TEdit;
    function MkBtn(AParent: TFmxObject; const AText: string;
      X, Y, W, H: Single; AColor: TAlphaColor = CLR_BLUE): TCornerButton;
    function MkCombo(AParent: TFmxObject; X, Y, W: Single): TComboEdit;
    function MkMemo(AParent: TFmxObject; X, Y, W, H: Single): TMemo;
    function MkCheck(AParent: TFmxObject; const AText: string;
      X, Y, W, H: Single): TCheckBox;
    function MkScroll(AParent: TFmxObject; X, Y, W, H: Single): TScrollBox;
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

{ ===================================================================
  UI HELPERS
  =================================================================== }

function TfrmMain.MkRect(AParent: TFmxObject; X, Y, W, H: Single;
  AColor: TAlphaColor; ARadius: Single): TRectangle;
begin
  Result := TRectangle.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.Fill.Color := AColor;
  Result.Fill.Kind := TBrushKind.Solid;
  Result.XRadius := ARadius; Result.YRadius := ARadius;
end;

function TfrmMain.MkLbl(AParent: TFmxObject; const AText: string;
  X, Y, W, H, ASize: Single; ABold: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Text := AText;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.Font.Size := ASize;
  Result.FontColor := CLR_WHITE;
  Result.StyledSettings := [];
  if ABold then Result.Font.Style := [TFontStyle.fsBold];
end;

function TfrmMain.MkEdit(AParent: TFmxObject; const APrompt: string;
  X, Y, W: Single; APass: Boolean): TEdit;
begin
  Result := TEdit.Create(Self);
  Result.Parent := AParent;
  Result.TextPrompt := APrompt;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := 40;
  Result.Password := APass;
end;

function TfrmMain.MkBtn(AParent: TFmxObject; const AText: string;
  X, Y, W, H: Single; AColor: TAlphaColor): TCornerButton;
begin
  Result := TCornerButton.Create(Self);
  Result.Parent := AParent;
  Result.Text := AText;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.CornerType := TCornerType.Round;
  Result.XRadius := H / 2; Result.YRadius := H / 2;
  Result.Font.Size := 14;
end;

function TfrmMain.MkCombo(AParent: TFmxObject; X, Y, W: Single): TComboEdit;
begin
  Result := TComboEdit.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := 40;
end;

function TfrmMain.MkMemo(AParent: TFmxObject; X, Y, W, H: Single): TMemo;
begin
  Result := TMemo.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
end;

function TfrmMain.MkCheck(AParent: TFmxObject; const AText: string;
  X, Y, W, H: Single): TCheckBox;
begin
  Result := TCheckBox.Create(Self);
  Result.Parent := AParent;
  Result.Text := AText;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
end;

function TfrmMain.MkScroll(AParent: TFmxObject; X, Y, W, H: Single): TScrollBox;
begin
  Result := TScrollBox.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.ShowScrollBars := False;
end;

{ ===================================================================
  NAV BAR
  =================================================================== }

procedure TfrmMain.AddNavBar(ATab: TTabItem; AActive: Integer);
const
  FW = 420; FH = 760;
var
  Nav: TRectangle;
  Icons: array[0..4] of string;
  Events: array[0..4] of TNotifyEvent;
  I: Integer;
  L: TLayout;
  Lbl: TLabel;
begin
  Icons[0] := '⌂'; Icons[1] := '💧'; Icons[2] := '🔧';
  Icons[3] := '⚙'; Icons[4] := '📦';

  Events[0] := btnNavDashClick;    Events[1] := btnNavMerenjeClick;
  Events[2] := btnNavNaloziClick;  Events[3] := btnNavOpremaClick;
  Events[4] := btnNavMagacinClick;

  Nav := MkRect(ATab, 10, FH - 76, FW - 20, 58, CLR_CARD, 29);
  Nav.HitTest := True;

  for I := 0 to 4 do
  begin
    L := TLayout.Create(Self);
    L.Parent := Nav;
    L.Position.X := 8 + I * ((FW - 36) / 5);
    L.Position.Y := 4;
    L.Width := (FW - 36) / 5;
    L.Height := 50;
    L.HitTest := True;
    L.OnClick := Events[I];

    Lbl := MkLbl(L, Icons[I], 0, 6, (FW - 36) / 5, 36, 20);
    Lbl.TextSettings.HorzAlign := TTextAlign.Center;
    Lbl.HitTest := False;
    if I = AActive then
      Lbl.FontColor := CLR_BRIGHT
    else
      Lbl.FontColor := CLR_DIM;
  end;
end;

{ ===================================================================
  BUILD UI
  =================================================================== }

procedure TfrmMain.BuildUI;
const
  FW = 420; FH = 760; NB = 76; { nav bar height }
  CW = FW - 32; { content width }
var
  Y: Single;

  procedure SectionLabel(AParent: TFmxObject; const AText: string; var AY: Single);
  begin
    MkLbl(AParent, AText, 16, AY, 300, 22, 11, True).FontColor := CLR_DIM;
    AY := AY + 28;
  end;

begin
  Self.Caption := 'AquaCentar — AquaMaintain';
  Self.Width := FW; Self.Height := FH;

  tcMain := TTabControl.Create(Self);
  tcMain.Parent := Self;
  tcMain.Align := TAlignLayout.Client;
  tcMain.TabPosition := TTabPosition.None;

  tiLogin       := TTabItem.Create(Self); tiLogin.Parent       := tcMain;
  tiRegister    := TTabItem.Create(Self); tiRegister.Parent    := tcMain;
  tiDashboard   := TTabItem.Create(Self); tiDashboard.Parent   := tcMain;
  tiMerenje     := TTabItem.Create(Self); tiMerenje.Parent     := tcMain;
  tiNalozi      := TTabItem.Create(Self); tiNalozi.Parent      := tcMain;
  tiOprema      := TTabItem.Create(Self); tiOprema.Parent      := tcMain;
  tiMagacin     := TTabItem.Create(Self); tiMagacin.Parent     := tcMain;
  tiNalogForm   := TTabItem.Create(Self); tiNalogForm.Parent   := tcMain;
  tiNalogDetail := TTabItem.Create(Self); tiNalogDetail.Parent := tcMain;
  tiOpremaForm  := TTabItem.Create(Self); tiOpremaForm.Parent  := tcMain;
  tiMatForm     := TTabItem.Create(Self); tiMatForm.Parent     := tcMain;
  tiMerenjeForm := TTabItem.Create(Self); tiMerenjeForm.Parent := tcMain;

  { ════════════════════════════════════════════════════
    LOGIN
    ════════════════════════════════════════════════════ }
  MkRect(tiLogin, 0, 0, FW, FH, CLR_BG);
  var Card := MkRect(tiLogin, 24, FH * 0.42, FW - 48, 258, CLR_CARD, 22);
  MkLbl(tiLogin, '🌊 AquaMaintain', 0, FH * 0.28, FW, 44, 24, True)
    .TextSettings.HorzAlign := TTextAlign.Center;
  MkLbl(tiLogin, 'Upravljanje odrzavanjem', 0, FH * 0.38, FW, 26, 13)
    .TextSettings.HorzAlign := TTextAlign.Center;

  edtUser := MkEdit(Card, 'Korisnicko ime', 20, 24, CW - 8);
  edtPass := MkEdit(Card, 'Lozinka', 20, 76, CW - 8, True);
  btnLogin := MkBtn(Card, 'Prijavljivanje', (FW - 48 - 200) / 2, 136, 200, 44, CLR_BRIGHT);
  btnLogin.OnClick := btnLoginClick;
  var btnGoReg := MkBtn(Card, 'Registruj se', (FW - 48 - 160) / 2, 186, 160, 34, CLR_CARD2);
  btnGoReg.OnClick := btnGoRegisterClick;
  lblLoginErr := MkLbl(Card, '', 16, 228, CW, 22, 11);
  lblLoginErr.FontColor := CLR_RED;
  lblLoginErr.TextSettings.HorzAlign := TTextAlign.Center;

  { ════════════════════════════════════════════════════
    DASHBOARD
    ════════════════════════════════════════════════════ }
  MkRect(tiDashboard, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiDashboard, '🌊  AquaMaintain', 16, 20, 300, 34, 18, True);
  btnRefreshDash := MkBtn(tiDashboard, '↻', FW - 66, 22, 50, 30, CLR_CARD2);
  btnRefreshDash.OnClick := btnRefreshDashClick;
  sbDash := MkScroll(tiDashboard, 0, 64, FW, FH - 64 - NB);
  AddNavBar(tiDashboard, 0);

  { ════════════════════════════════════════════════════
    REGISTER
    ════════════════════════════════════════════════════ }
  MkRect(tiRegister, 0, 0, FW, FH, CLR_BG);
  var RegCard := MkRect(tiRegister, 24, FH * 0.18, FW - 48, 360, CLR_CARD, 22);
  MkLbl(tiRegister, '📋  Registracija', 0, FH * 0.08, FW, 36, 20, True)
    .TextSettings.HorzAlign := TTextAlign.Center;
  MkLbl(RegCard, 'ID zaposlenog', 20, 16, CW - 8, 20, 12);
  edtRegEmpID    := MkEdit(RegCard, 'npr. EMP-001', 20, 36, CW - 8);
  MkLbl(RegCard, 'Korisnicko ime', 20, 86, CW - 8, 20, 12);
  edtRegUsername := MkEdit(RegCard, 'Unesite korisnicko ime', 20, 106, CW - 8);
  MkLbl(RegCard, 'Lozinka', 20, 156, CW - 8, 20, 12);
  edtRegPass     := MkEdit(RegCard, 'Unesite lozinku', 20, 176, CW - 8, True);
  MkLbl(RegCard, 'Potvrdite lozinku', 20, 226, CW - 8, 20, 12);
  edtRegPass2    := MkEdit(RegCard, 'Ponovite lozinku', 20, 246, CW - 8, True);
  lblRegErr := MkLbl(RegCard, '', 20, 296, CW - 8, 22, 11);
  lblRegErr.FontColor := CLR_RED;
  MkBtn(RegCard, 'Registruj se', 20, 326, (CW / 2) - 18, 44, CLR_BRIGHT).OnClick := btnRegisterClick;
  MkBtn(RegCard, '← Nazad', (CW / 2) + 10, 326, (CW / 2) - 18, 44, CLR_CARD2).OnClick := btnBackToLoginClick;

  { ════════════════════════════════════════════════════
    MERENJA VODE
    ════════════════════════════════════════════════════ }
  MkRect(tiMerenje, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiMerenje, '💧  Merenja Vode', 16, 20, 300, 30, 17, True);
  btnNovoMerenje := MkBtn(tiMerenje, '+  Novo merenje', FW - 176, 16, 160, 38, CLR_BRIGHT);
  btnNovoMerenje.OnClick := btnNovoMerenjeClick;
  sbMerenja := MkScroll(tiMerenje, 0, 64, FW, FH - 64 - NB);
  AddNavBar(tiMerenje, 1);

  { Merenje forma }
  MkRect(tiMerenjeForm, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiMerenjeForm, '💧  Novo Merenje', 16, 20, 300, 30, 17, True);
  Y := 64;
  MkLbl(tiMerenjeForm, 'Bazen *', 16, Y, 200, 20, 12); Y := Y + 22;
  cmbMerBazen := MkCombo(tiMerenjeForm, 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'pH vrednost (6.8 – 7.6)', 16, Y, 250, 20, 12); Y := Y + 22;
  edtMerPH := MkEdit(tiMerenjeForm, 'npr. 7.2', 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'Hlor mg/L (0.5 – 2.0)', 16, Y, 250, 20, 12); Y := Y + 22;
  edtMerHlor := MkEdit(tiMerenjeForm, 'npr. 1.0', 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'Temperatura °C', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMerTemp := MkEdit(tiMerenjeForm, 'npr. 27.0', 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'Uneo', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMerUneo := MkEdit(tiMerenjeForm, 'Ime i prezime', 16, Y, CW); Y := Y + 56;
  lblMerErr := MkLbl(tiMerenjeForm, '', 16, Y, CW, 22, 11);
  lblMerErr.FontColor := CLR_RED; Y := Y + 28;
  MkBtn(tiMerenjeForm, '💾  Sacuvaj merenje', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveMerenjeClick;
  MkBtn(tiMerenjeForm, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelMerenjeClick;

  { ════════════════════════════════════════════════════
    RADNI NALOZI
    ════════════════════════════════════════════════════ }
  MkRect(tiNalozi, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiNalozi, '🔧  Radni Nalozi', 16, 20, 250, 30, 17, True);
  btnNoviNalog := MkBtn(tiNalozi, '+ Nov', FW - 100, 18, 84, 34, CLR_BRIGHT);
  btnNoviNalog.OnClick := btnNoviNalogClick;
  cmbNalogFilter := MkCombo(tiNalozi, 16, 60, CW);
  cmbNalogFilter.Items.AddStrings(['Svi nalozi', 'Otvoren', 'U radu', 'Zatvoren', 'Hitno']);
  cmbNalogFilter.Text := 'Svi nalozi';
  cmbNalogFilter.OnChange := cmbNalogFilterChange;
  sbNalozi := MkScroll(tiNalozi, 0, 110, FW, FH - 110 - NB);
  AddNavBar(tiNalozi, 2);

  { Nalog forma }
  MkRect(tiNalogForm, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiNalogForm, '🔧  Novi Radni Nalog', 16, 16, 350, 30, 16, True);
  Y := 56;
  MkLbl(tiNalogForm, 'Tip intervencije *', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogTip := MkCombo(tiNalogForm, 16, Y, CW);
  cmbNalogTip.Items.AddStrings(['Preventivno', 'Korektivno', 'Hitno']); Y := Y + 48;
  MkLbl(tiNalogForm, 'Kategorija', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogKat := MkCombo(tiNalogForm, 16, Y, CW);
  cmbNalogKat.Items.AddStrings(['Servis pumpe', 'Kvalitet vode', 'Filter sistem',
    'Osvetljenje', 'Kvar opreme', 'Ciscenje', 'Ostalo']); Y := Y + 48;
  MkLbl(tiNalogForm, 'Prioritet *', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogPrior := MkCombo(tiNalogForm, 16, Y, CW);
  cmbNalogPrior.Items.AddStrings(['1 - Hitno', '2 - Visok', '3 - Normalan']); Y := Y + 48;
  MkLbl(tiNalogForm, 'Bazen / lokacija', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogBazen := MkCombo(tiNalogForm, 16, Y, CW); Y := Y + 48;
  MkLbl(tiNalogForm, 'Oprema', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogOprema := MkCombo(tiNalogForm, 16, Y, CW); Y := Y + 48;
  MkLbl(tiNalogForm, 'Izvrsio / zaduzeni tehnicar', 16, Y, 300, 20, 12); Y := Y + 22;
  edtNalogIzvrsio := MkEdit(tiNalogForm, 'Ime tehnicara', 16, Y, CW); Y := Y + 48;
  MkLbl(tiNalogForm, 'Opis radova *', 16, Y, 250, 20, 12); Y := Y + 22;
  memoNalogOpis := MkMemo(tiNalogForm, 16, Y, CW, 80); Y := Y + 88;
  chkBlokiraj := MkCheck(tiNalogForm, 'Blokirati rezervacije za ovaj bazen', 16, Y, CW, 32); Y := Y + 40;
  lblNalogErr := MkLbl(tiNalogForm, '', 16, Y, CW, 22, 11);
  lblNalogErr.FontColor := CLR_RED; Y := Y + 28;
  MkBtn(tiNalogForm, '💾  Otvori nalog', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveNalogClick;
  MkBtn(tiNalogForm, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelNalogClick;

  { Nalog detalji }
  MkRect(tiNalogDetail, 0, 0, FW, FH, CLR_BG);
  lblNalogDetTitle := MkLbl(tiNalogDetail, 'Radni Nalog', 16, 16, 300, 30, 16, True);
  sbNalogDetail := MkScroll(tiNalogDetail, 0, 56, FW, FH - 56 - 110);
  btnZatvoriNalog := MkBtn(tiNalogDetail, '✓  Zatvori nalog', 16, FH - 104, (CW / 2) - 8, 44, CLR_GREEN);
  btnZatvoriNalog.OnClick := btnZatvoriNalogClick;
  MkBtn(tiNalogDetail, '← Nazad', (CW / 2) + 24, FH - 104, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnBackNalogClick;

  { ════════════════════════════════════════════════════
    OPREMA
    ════════════════════════════════════════════════════ }
  MkRect(tiOprema, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiOprema, '⚙  Oprema', 16, 20, 250, 30, 17, True);
  btnNovaOprema := MkBtn(tiOprema, '+ Nova', FW - 100, 18, 84, 34, CLR_BRIGHT);
  btnNovaOprema.OnClick := btnNovaOpremaClick;
  sbOprema := MkScroll(tiOprema, 0, 64, FW, FH - 64 - NB);
  AddNavBar(tiOprema, 3);

  { Oprema forma }
  MkRect(tiOpremaForm, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiOpremaForm, '⚙  Nova Oprema', 16, 16, 300, 30, 16, True);
  Y := 56;
  MkLbl(tiOpremaForm, 'Naziv *', 16, Y, 200, 20, 12); Y := Y + 22;
  edtOpNaziv := MkEdit(tiOpremaForm, '', 16, Y, CW); Y := Y + 48;
  MkLbl(tiOpremaForm, 'Tip *', 16, Y, 200, 20, 12); Y := Y + 22;
  cmbOpTip := MkCombo(tiOpremaForm, 16, Y, CW);
  cmbOpTip.Items.AddStrings(['Pumpa', 'Filter', 'Dozator', 'Vozilo', 'Senzor',
    'Osvetljenje', 'Grijanije', 'Ostalo']); Y := Y + 48;
  MkLbl(tiOpremaForm, 'Status *', 16, Y, 200, 20, 12); Y := Y + 22;
  cmbOpStatus := MkCombo(tiOpremaForm, 16, Y, CW);
  cmbOpStatus.Items.AddStrings(['Aktivna', 'Neaktivna', 'Na popravci', 'Penzionisana']); Y := Y + 48;
  MkLbl(tiOpremaForm, 'Bazen / lokacija', 16, Y, 200, 20, 12); Y := Y + 22;
  cmbOpBazen := MkCombo(tiOpremaForm, 16, Y, CW); Y := Y + 48;
  MkLbl(tiOpremaForm, 'Model', 16, Y, 200, 20, 12); Y := Y + 22;
  edtOpModel := MkEdit(tiOpremaForm, '', 16, Y, CW); Y := Y + 48;
  MkLbl(tiOpremaForm, 'Serijski broj', 16, Y, 200, 20, 12); Y := Y + 22;
  edtOpSerial := MkEdit(tiOpremaForm, '', 16, Y, CW); Y := Y + 48;
  MkLbl(tiOpremaForm, 'Datum nabavke (GGGG-MM-DD)', 16, Y, 300, 20, 12); Y := Y + 22;
  edtOpDatum := MkEdit(tiOpremaForm, '', 16, Y, CW); Y := Y + 48;
  MkLbl(tiOpremaForm, 'Napomena', 16, Y, 200, 20, 12); Y := Y + 22;
  memoOpNap := MkMemo(tiOpremaForm, 16, Y, CW, 72); Y := Y + 80;
  lblOpErr := MkLbl(tiOpremaForm, '', 16, Y, CW, 22, 11);
  lblOpErr.FontColor := CLR_RED; Y := Y + 28;
  MkBtn(tiOpremaForm, '💾  Sacuvaj', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveOpremaClick;
  MkBtn(tiOpremaForm, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelOpremaClick;

  { ════════════════════════════════════════════════════
    MAGACIN
    ════════════════════════════════════════════════════ }
  MkRect(tiMagacin, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiMagacin, '📦  Magacin', 16, 20, 250, 30, 17, True);
  btnNoviMat := MkBtn(tiMagacin, '+ Nov', FW - 100, 18, 84, 34, CLR_BRIGHT);
  btnNoviMat.OnClick := btnNoviMatClick;
  sbMagacin := MkScroll(tiMagacin, 0, 64, FW, FH - 64 - NB);
  AddNavBar(tiMagacin, 4);

  { Materijal forma }
  MkRect(tiMatForm, 0, 0, FW, FH, CLR_BG);
  MkLbl(tiMatForm, '📦  Novi Materijal', 16, 16, 300, 30, 16, True);
  Y := 56;
  MkLbl(tiMatForm, 'Naziv *', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMatNaziv := MkEdit(tiMatForm, '', 16, Y, CW); Y := Y + 48;
  MkLbl(tiMatForm, 'Tip', 16, Y, 200, 20, 12); Y := Y + 22;
  cmbMatTip := MkCombo(tiMatForm, 16, Y, CW);
  cmbMatTip.Items.AddStrings(['Hemija', 'Rezervni deo', 'Alat', 'Ostalo']); Y := Y + 48;
  MkLbl(tiMatForm, 'Jedinica mere', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMatJed := MkEdit(tiMatForm, 'kg / kom / L', 16, Y, CW); Y := Y + 48;
  MkLbl(tiMatForm, 'Trenutna zaliha', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMatZal := MkEdit(tiMatForm, '0', 16, Y, CW); Y := Y + 48;
  MkLbl(tiMatForm, 'Minimalna zaliha (alarm)', 16, Y, 280, 20, 12); Y := Y + 22;
  edtMatMin := MkEdit(tiMatForm, '0', 16, Y, CW); Y := Y + 56;
  lblMatErr := MkLbl(tiMatForm, '', 16, Y, CW, 22, 11);
  lblMatErr.FontColor := CLR_RED; Y := Y + 28;
  MkBtn(tiMatForm, '💾  Sacuvaj', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveMatClick;
  MkBtn(tiMatForm, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelMatClick;
end;

{ ===================================================================
  CARD HELPERS
  =================================================================== }

procedure TfrmMain.AddAlarmCard(AParent: TFmxObject; const AText, ASub: string;
  AColor: TAlphaColor; var AY: Single);
var C: TRectangle;
begin
  C := MkRect(AParent, 16, AY, 388, 70, AColor, 14);
  MkLbl(C, AText, 14, 8, 340, 24, 13, True);
  var L := MkLbl(C, ASub, 14, 34, 340, 20, 11);
  L.FontColor := $FFDDDDDD;
  AY := AY + 78;
end;

procedure TfrmMain.AddMerenjeCard(AID: Integer; const ABazen, ADatum: string;
  APH, AHlor, ATemp: Double; AAlarm: Boolean; var AY: Single);
var
  C: TRectangle;
  Color: TAlphaColor;
  Info: string;
begin
  if AAlarm then Color := $FF8B1A1A else Color := CLR_CARD;
  C := MkRect(sbMerenja.Content, 16, AY, 388, 80, Color, 14);
  C.Tag := AID;
  MkLbl(C, ABazen, 14, 6, 280, 22, 13, True);
  var lDate := MkLbl(C, ADatum, 14, 28, 280, 18, 11);
  lDate.FontColor := CLR_DIM;
  Info := Format('pH: %.1f  |  Hlor: %.2f  |  T: %.1f°C', [APH, AHlor, ATemp]);
  MkLbl(C, Info, 14, 50, 340, 20, 12);
  if AAlarm then
  begin
    var lA := MkLbl(C, '⚠ ALARM', 300, 6, 80, 22, 11, True);
    lA.FontColor := CLR_YELLOW;
  end;
  AY := AY + 88;
end;

procedure TfrmMain.AddNalogCard(AID: Integer; const ATip, AOpis, AStatus: string;
  APrior: Integer; var AY: Single);
var
  C: TRectangle;
  PriorColor, StatColor: TAlphaColor;
  PriorText: string;
begin
  if APrior = 1 then begin PriorColor := CLR_RED;    PriorText := '● HITNO'; end
  else if APrior = 2 then begin PriorColor := CLR_ORANGE; PriorText := '● Visok'; end
  else begin PriorColor := CLR_BLUE; PriorText := '● Normal'; end;

  if AStatus = 'Zatvoren' then StatColor := CLR_GREEN
  else if AStatus = 'U radu' then StatColor := CLR_BLUE
  else StatColor := CLR_ORANGE;

  C := MkRect(sbNalozi.Content, 16, AY, 388, 82, CLR_CARD, 14);
  C.Tag := AID;
  C.HitTest := True;
  C.OnClick := NalogCardClick;

  var lPrior := MkLbl(C, PriorText, 14, 6, 120, 20, 11, True);
  lPrior.FontColor := PriorColor;
  var lStat := MkLbl(C, AStatus, 254, 6, 120, 20, 11, True);
  lStat.FontColor := StatColor;
  lStat.TextSettings.HorzAlign := TTextAlign.Trailing;
  MkLbl(C, ATip, 14, 26, 200, 22, 13, True);
  var lOpis := MkLbl(C, AOpis, 14, 50, 356, 20, 11);
  lOpis.FontColor := CLR_DIM;
  MkLbl(C, '›', 362, 28, 20, 30, 20).FontColor := CLR_DIM;
  AY := AY + 90;
end;

procedure TfrmMain.AddOpremaCard(AID: Integer; const ANaziv, ATip, AStatus: string;
  var AY: Single);
var
  C: TRectangle;
  DotColor: TAlphaColor;
begin
  if AStatus = 'Aktivna' then DotColor := CLR_GREEN
  else if AStatus = 'Na popravci' then DotColor := CLR_ORANGE
  else DotColor := $FF9E9E9E;

  C := MkRect(sbOprema.Content, 16, AY, 388, 68, CLR_CARD, 14);
  C.Tag := AID;
  C.HitTest := True;
  C.OnClick := OpremaCardClick;

  var Dot := TCircle.Create(Self);
  Dot.Parent := C;
  Dot.Position.X := 16; Dot.Position.Y := 22;
  Dot.Width := 16; Dot.Height := 16;
  Dot.Fill.Color := DotColor;
  Dot.Fill.Kind := TBrushKind.Solid;

  MkLbl(C, ANaziv, 42, 8, 290, 22, 13, True);
  var lSub := MkLbl(C, ATip + ' · ' + AStatus, 42, 32, 290, 20, 11);
  lSub.FontColor := CLR_DIM;
  MkLbl(C, '›', 362, 20, 20, 30, 20).FontColor := CLR_DIM;
  AY := AY + 76;
end;

procedure TfrmMain.AddMatCard(AID: Integer; const ANaziv, ATip: string;
  AZal, AMin: Double; var AY: Single);
var
  C: TRectangle;
  Low: Boolean;
begin
  Low := AZal <= AMin;
  C := MkRect(sbMagacin.Content, 16, AY, 388, 72, CLR_CARD, 14);
  C.Tag := AID;
  MkLbl(C, ANaziv, 14, 6, 280, 22, 13, True);
  var lTip := MkLbl(C, ATip, 14, 28, 200, 18, 11);
  lTip.FontColor := CLR_DIM;
  var lZal := MkLbl(C, Format('Zaliha: %.1f', [AZal]), 14, 48, 200, 18, 12);
  if Low then lZal.FontColor := CLR_RED
  else lZal.FontColor := CLR_GREEN;
  if Low then
  begin
    var lW := MkLbl(C, '⚠ Niska zaliha', 240, 48, 140, 18, 11, True);
    lW.FontColor := CLR_ORANGE;
  end;
  AY := AY + 80;
end;

{ ===================================================================
  LOAD DATA
  =================================================================== }

procedure TfrmMain.LoadBazenCombo(ACombo: TComboEdit);
var Q: TFDQuery;
begin
  ACombo.Items.Clear;
  ACombo.Items.Add('(nije vezano)');
  SetLength(FBazenIDs, 1);
  FBazenIDs[0] := -1;

  if not dmData.IsConnected then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT B_ID, B_NAZIV FROM BAZEN ORDER BY B_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      ACombo.Items.Add(Q.FieldByName('B_NAZIV').AsString);
      SetLength(FBazenIDs, Length(FBazenIDs) + 1);
      FBazenIDs[High(FBazenIDs)] := Q.FieldByName('B_ID').AsInteger;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadOpremaCombo;
var Q: TFDQuery;
begin
  cmbNalogOprema.Items.Clear;
  cmbNalogOprema.Items.Add('(nije vezano)');
  SetLength(FOpremaIDs, 1);
  FOpremaIDs[0] := -1;

  if not dmData.IsConnected then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT OP_ID, OP_NAZIV FROM OPREMA ORDER BY OP_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      cmbNalogOprema.Items.Add(Q.FieldByName('OP_NAZIV').AsString);
      SetLength(FOpremaIDs, Length(FOpremaIDs) + 1);
      FOpremaIDs[High(FOpremaIDs)] := Q.FieldByName('OP_ID').AsInteger;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.RefreshDashboard;
var
  Q: TFDQuery;
  Y: Single;
  I: Integer;
begin
  if not dmData.IsConnected then Exit;

  for I := sbDash.Content.ChildrenCount - 1 downto 0 do
    sbDash.Content.Children[I].Parent := nil;

  Y := 8;

  { KPI row }
  var KPIBg := MkRect(sbDash.Content, 16, Y, 388, 80, CLR_CARD2, 16); Y := Y + 88;
  var Tot := dmData.ExecScalar('SELECT COUNT(*) FROM RADNI_NALOG');
  var Otv := dmData.ExecScalar('SELECT COUNT(*) FROM RADNI_NALOG WHERE RN_STATUS <> ''Zatvoren''');
  var Hit := dmData.ExecScalar('SELECT COUNT(*) FROM RADNI_NALOG WHERE RN_TIP=''Hitno'' AND RN_STATUS <> ''Zatvoren''');
  var Ala := dmData.ExecScalar('SELECT COUNT(*) FROM MERENJE_VODE WHERE MV_ALARM=''Y''');

  MkLbl(KPIBg, 'Ukupno naloga', 10, 8, 90, 18, 9).FontColor := CLR_DIM;
  MkLbl(KPIBg, Tot.ToString, 10, 26, 90, 36, 22, True);
  MkLbl(KPIBg, 'Otvoreno', 108, 8, 80, 18, 9).FontColor := CLR_DIM;
  var lOtv := MkLbl(KPIBg, Otv.ToString, 108, 26, 80, 36, 22, True);
  if Otv > 0 then lOtv.FontColor := CLR_ORANGE;
  MkLbl(KPIBg, 'Hitno', 206, 8, 70, 18, 9).FontColor := CLR_DIM;
  var lHit := MkLbl(KPIBg, Hit.ToString, 206, 26, 70, 36, 22, True);
  if Hit > 0 then lHit.FontColor := CLR_RED;
  MkLbl(KPIBg, 'Alarmi', 294, 8, 80, 18, 9).FontColor := CLR_DIM;
  var lAla := MkLbl(KPIBg, Ala.ToString, 294, 26, 80, 36, 22, True);
  if Ala > 0 then lAla.FontColor := CLR_YELLOW;

  { Alarmi }
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT M.MV_DATUM, B.B_NAZIV, M.MV_PH, M.MV_HLOR, M.MV_NAPOMENA ' +
      'FROM MERENJE_VODE M JOIN BAZEN B ON B.B_ID=M.MV_BAZEN_ID ' +
      'WHERE M.MV_ALARM=''Y'' ORDER BY M.MV_DATUM DESC';
    Q.Open;
    if not Q.IsEmpty then
    begin
      MkLbl(sbDash.Content, '⚠  Aktivni Alarmi', 16, Y, 300, 22, 12, True)
        .FontColor := CLR_YELLOW;
      Y := Y + 28;
      while not Q.Eof do
      begin
        AddAlarmCard(sbDash.Content,
          Q.FieldByName('B_NAZIV').AsString + ' — pH: ' +
          Q.FieldByName('MV_PH').AsString + '  Hlor: ' + Q.FieldByName('MV_HLOR').AsString,
          Q.FieldByName('MV_DATUM').AsString + '  ' + Q.FieldByName('MV_NAPOMENA').AsString,
          $FF8B1A1A, Y);
        Q.Next;
      end;
    end;
    Q.Close;

    { Hitni nalozi }
    Q.SQL.Text :=
      'SELECT RN_ID, RN_TIP, RN_OPIS, RN_STATUS, RN_DATUM_OTVAR ' +
      'FROM RADNI_NALOG WHERE RN_PRIORITET=1 AND RN_STATUS <> ''Zatvoren'' ' +
      'ORDER BY RN_DATUM_OTVAR DESC';
    Q.Open;
    if not Q.IsEmpty then
    begin
      MkLbl(sbDash.Content, '🔴  Hitni Nalozi', 16, Y, 300, 22, 12, True)
        .FontColor := CLR_RED;
      Y := Y + 28;
      while not Q.Eof do
      begin
        AddAlarmCard(sbDash.Content,
          Q.FieldByName('RN_TIP').AsString + ' — ' + Q.FieldByName('RN_STATUS').AsString,
          Q.FieldByName('RN_OPIS').AsString,
          $FF4A0A0A, Y);
        Q.Next;
      end;
    end;
    Q.Close;

    { Blokirani bazeni }
    Q.SQL.Text :=
      'SELECT DISTINCT B.B_NAZIV FROM RADNI_NALOG R ' +
      'JOIN BAZEN B ON B.B_ID=R.RN_BAZEN_ID ' +
      'WHERE R.RN_BLOKIRA_REZ=''Y'' AND R.RN_STATUS <> ''Zatvoren''';
    Q.Open;
    if not Q.IsEmpty then
    begin
      MkLbl(sbDash.Content, '🚫  Blokirani Bazeni', 16, Y, 300, 22, 12, True)
        .FontColor := CLR_ORANGE;
      Y := Y + 28;
      while not Q.Eof do
      begin
        AddAlarmCard(sbDash.Content,
          Q.FieldByName('B_NAZIV').AsString,
          'Rezervacije onemogucene zbog aktivnog naloga',
          $FF3A2500, Y);
        Q.Next;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadMerenja;
var Q: TFDQuery; Y: Single; I: Integer;
begin
  for I := sbMerenja.Content.ChildrenCount - 1 downto 0 do
    sbMerenja.Content.Children[I].Parent := nil;
  if not dmData.IsConnected then Exit;
  Y := 8;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT M.MV_ID, B.B_NAZIV, M.MV_DATUM, M.MV_PH, M.MV_HLOR, M.MV_TEMP, M.MV_ALARM ' +
      'FROM MERENJE_VODE M JOIN BAZEN B ON B.B_ID=M.MV_BAZEN_ID ' +
      'ORDER BY M.MV_DATUM DESC';
    Q.Open;
    while not Q.Eof do
    begin
      AddMerenjeCard(
        Q.FieldByName('MV_ID').AsInteger,
        Q.FieldByName('B_NAZIV').AsString,
        Q.FieldByName('MV_DATUM').AsString,
        Q.FieldByName('MV_PH').AsFloat,
        Q.FieldByName('MV_HLOR').AsFloat,
        Q.FieldByName('MV_TEMP').AsFloat,
        Q.FieldByName('MV_ALARM').AsString = 'Y',
        Y
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadNalozi(const AFilter: string);
var Q: TFDQuery; SQL: string; Y: Single; I: Integer;
begin
  for I := sbNalozi.Content.ChildrenCount - 1 downto 0 do
    sbNalozi.Content.Children[I].Parent := nil;
  if not dmData.IsConnected then Exit;
  Y := 8;
  SQL := 'SELECT RN_ID, RN_TIP, RN_OPIS, RN_STATUS, RN_PRIORITET FROM RADNI_NALOG ';
  if (AFilter <> '') and (AFilter <> 'Svi nalozi') then
  begin
    if AFilter = 'Hitno' then
      SQL := SQL + 'WHERE RN_TIP=''Hitno'' '
    else
      SQL := SQL + 'WHERE RN_STATUS=''' + AFilter + ''' ';
  end;
  SQL := SQL + 'ORDER BY RN_PRIORITET, RN_DATUM_OTVAR DESC';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := SQL;
    Q.Open;
    while not Q.Eof do
    begin
      AddNalogCard(
        Q.FieldByName('RN_ID').AsInteger,
        Q.FieldByName('RN_TIP').AsString,
        Q.FieldByName('RN_OPIS').AsString,
        Q.FieldByName('RN_STATUS').AsString,
        Q.FieldByName('RN_PRIORITET').AsInteger,
        Y
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadOprema;
var Q: TFDQuery; Y: Single; I: Integer;
begin
  for I := sbOprema.Content.ChildrenCount - 1 downto 0 do
    sbOprema.Content.Children[I].Parent := nil;
  if not dmData.IsConnected then Exit;
  Y := 8;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT OP_ID, OP_NAZIV, OP_TIP, OP_STATUS FROM OPREMA ORDER BY OP_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      AddOpremaCard(
        Q.FieldByName('OP_ID').AsInteger,
        Q.FieldByName('OP_NAZIV').AsString,
        Q.FieldByName('OP_TIP').AsString,
        Q.FieldByName('OP_STATUS').AsString,
        Y
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadMagacin;
var Q: TFDQuery; Y: Single; I: Integer;
begin
  for I := sbMagacin.Content.ChildrenCount - 1 downto 0 do
    sbMagacin.Content.Children[I].Parent := nil;
  if not dmData.IsConnected then Exit;
  Y := 8;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT MAT_ID, MAT_NAZIV, MAT_TIP, MAT_ZALIHA, MAT_MIN_ZAL ' +
      'FROM MATERIJAL ORDER BY MAT_TIP, MAT_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      AddMatCard(
        Q.FieldByName('MAT_ID').AsInteger,
        Q.FieldByName('MAT_NAZIV').AsString,
        Q.FieldByName('MAT_TIP').AsString,
        Q.FieldByName('MAT_ZALIHA').AsFloat,
        Q.FieldByName('MAT_MIN_ZAL').AsFloat,
        Y
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

{ ===================================================================
  NALOG DETAIL
  =================================================================== }

procedure TfrmMain.ShowNalogDetail(AID: Integer);
var
  Q: TFDQuery;
  Y: Single;
  I: Integer;
begin
  FNalogCurrentID := AID;

  for I := sbNalogDetail.Content.ChildrenCount - 1 downto 0 do
    sbNalogDetail.Content.Children[I].Parent := nil;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT R.*, B.B_NAZIV, O.OP_NAZIV ' +
      'FROM RADNI_NALOG R ' +
      'LEFT JOIN BAZEN B ON B.B_ID=R.RN_BAZEN_ID ' +
      'LEFT JOIN OPREMA O ON O.OP_ID=R.RN_OPREMA_ID ' +
      'WHERE R.RN_ID=:ID';
    Q.ParamByName('ID').AsInteger := AID;
    Q.Open;

    if Q.IsEmpty then Exit;

    lblNalogDetTitle.Text := Q.FieldByName('RN_TIP').AsString + ' — #' + AID.ToString;

    Y := 8;

    var StatC: TAlphaColor;
    var RowCard: TRectangle;
    var RowKey, RowVal: TLabel;
    if Q.FieldByName('RN_STATUS').AsString = 'Zatvoren' then StatC := CLR_GREEN
    else if Q.FieldByName('RN_STATUS').AsString = 'U radu' then StatC := CLR_BLUE
    else StatC := CLR_ORANGE;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Status', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_STATUS').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := StatC;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Tip', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_TIP').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Kategorija', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_KATEGORIJA').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Prioritet', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_PRIORITET').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Bazen', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('B_NAZIV').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Oprema', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('OP_NAZIV').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Izvrsio', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_IZVRSIO').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Otvoren', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_DATUM_OTVAR').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    if not Q.FieldByName('RN_DATUM_ZATVR').IsNull then
    begin
      RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
      RowKey := MkLbl(RowCard, 'Zatvoren', 14, 4, 130, 18, 10);
      RowKey.FontColor := CLR_DIM;
      RowVal := MkLbl(RowCard, Q.FieldByName('RN_DATUM_ZATVR').AsString, 14, 22, 360, 18, 12, True);
      RowVal.FontColor := CLR_WHITE;
      Y := Y + 52;
    end;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Trosak', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Format('%.2f RSD', [Q.FieldByName('RN_TROSAK').AsFloat]), 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Blokira rez.', 14, 4, 130, 18, 10);
    RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_BLOKIRA_REZ').AsString, 14, 22, 360, 18, 12, True);
    RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;


    { Opis }
    MkLbl(sbNalogDetail.Content, 'Opis radova', 16, Y, 300, 20, 11).FontColor := CLR_DIM;
    Y := Y + 22;
    var OpR := MkRect(sbNalogDetail.Content, 16, Y, 388, 80, CLR_CARD, 10);
    var lOpis := MkLbl(OpR, Q.FieldByName('RN_OPIS').AsString, 12, 8, 364, 64, 12);
    lOpis.WordWrap := True;
    Y := Y + 88;

    { Potrosnja }
    Q.Close;
    Q.SQL.Text :=
      'SELECT M.MAT_NAZIV, P.P_KOLICINA, M.MAT_JEDINICA ' +
      'FROM POTROSNJA P JOIN MATERIJAL M ON M.MAT_ID=P.P_MAT_ID ' +
      'WHERE P.P_RN_ID=:ID';
    Q.ParamByName('ID').AsInteger := AID;
    Q.Open;
    if not Q.IsEmpty then
    begin
      MkLbl(sbNalogDetail.Content, 'Potroseni materijal', 16, Y, 300, 20, 11).FontColor := CLR_DIM;
      Y := Y + 22;
      while not Q.Eof do
      begin
        var PR := MkRect(sbNalogDetail.Content, 16, Y, 388, 36, CLR_CARD, 8);
        MkLbl(PR, Q.FieldByName('MAT_NAZIV').AsString, 12, 8, 250, 20, 12);
        MkLbl(PR, Format('%.2f %s', [Q.FieldByName('P_KOLICINA').AsFloat,
          Q.FieldByName('MAT_JEDINICA').AsString]), 270, 8, 110, 20, 12)
          .TextSettings.HorzAlign := TTextAlign.Trailing;
        Y := Y + 44;
        Q.Next;
      end;
    end;

    { btnZatvoriNalog visibility set before finally }
  finally
    Q.Free;
  end;

  tcMain.ActiveTab := tiNalogDetail;
end;

{ ===================================================================
  AUTH
  =================================================================== }

function TfrmMain.SimpleHash(const S: string): string;
var
  I, H: Integer;
begin
  { Simple deterministic hash — adequate for embedded single-user app }
  H := 5381;
  for I := 1 to Length(S) do
    H := ((H shl 5) + H) + Ord(S[I]);
  Result := IntToHex(H, 8);
end;

procedure TfrmMain.btnGoRegisterClick(Sender: TObject);
begin
  edtRegEmpID.Text := '';
  edtRegUsername.Text := '';
  edtRegPass.Text := '';
  edtRegPass2.Text := '';
  lblRegErr.Text := '';
  tcMain.ActiveTab := tiRegister;
end;

procedure TfrmMain.btnBackToLoginClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiLogin;
end;

procedure TfrmMain.btnRegisterClick(Sender: TObject);
var
  Q: TFDQuery;
begin
  lblRegErr.Text := '';
  if Trim(edtRegEmpID.Text) = '' then
  begin lblRegErr.Text := 'ID zaposlenog je obavezan.'; Exit; end;
  if Trim(edtRegUsername.Text) = '' then
  begin lblRegErr.Text := 'Korisnicko ime je obavezno.'; Exit; end;
  if Length(Trim(edtRegPass.Text)) < 4 then
  begin lblRegErr.Text := 'Lozinka mora imati najmanje 4 karaktera.'; Exit; end;
  if edtRegPass.Text <> edtRegPass2.Text then
  begin lblRegErr.Text := 'Lozinke se ne podudaraju.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    { Check username not taken }
    Q.SQL.Text := 'SELECT COUNT(*) FROM KORISNIK_ODR WHERE KO_USERNAME = :UN';
    Q.ParamByName('UN').AsString := Trim(edtRegUsername.Text);
    Q.Open;
    if Q.Fields[0].AsInteger > 0 then
    begin
      lblRegErr.Text := 'Korisnicko ime vec postoji.';
      Exit;
    end;
    Q.Close;

    Q.SQL.Text :=
      'INSERT INTO KORISNIK_ODR (KO_EMP_ID, KO_USERNAME, KO_PASSHASH) ' +
      'VALUES (:EMP, :UN, :HASH)';
    Q.ParamByName('EMP').AsString  := Trim(edtRegEmpID.Text);
    Q.ParamByName('UN').AsString   := Trim(edtRegUsername.Text);
    Q.ParamByName('HASH').AsString := SimpleHash(Trim(edtRegPass.Text));
    Q.ExecSQL;
    dmData.CommitWork;

    ShowMessage('Registracija uspjesna! Mozete se prijaviti.');
    tcMain.ActiveTab := tiLogin;
  except
    on E: Exception do
      lblRegErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

{ ===================================================================
  FORM EVENTS
  =================================================================== }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  BuildUI;
  tcMain.ActiveTab := tiLogin;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  tcMain.ActiveTab := tiLogin;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  // Unit2 handles cleanup
end;

{ ===================================================================
  NAVIGATION
  =================================================================== }

procedure TfrmMain.btnLoginClick(Sender: TObject);
var
  Q: TFDQuery;
  StoredHash: string;
begin
  lblLoginErr.Text := '';
  if Trim(edtUser.Text) = '' then
  begin lblLoginErr.Text := 'Unesite korisnicko ime.'; Exit; end;
  if Trim(edtPass.Text) = '' then
  begin lblLoginErr.Text := 'Unesite lozinku.'; Exit; end;
  if not dmData.IsConnected then
  begin lblLoginErr.Text := 'Baza nije dostupna.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT KO_PASSHASH FROM KORISNIK_ODR ' +
      'WHERE KO_USERNAME = :UN';
    Q.ParamByName('UN').AsString := Trim(edtUser.Text);
    Q.Open;
    if Q.IsEmpty then
    begin
      lblLoginErr.Text := 'Korisnik nije pronadjen.';
      Exit;
    end;
    StoredHash := Q.FieldByName('KO_PASSHASH').AsString;
    if StoredHash <> SimpleHash(Trim(edtPass.Text)) then
    begin
      lblLoginErr.Text := 'Pogresna lozinka.';
      Exit;
    end;
  finally
    Q.Free;
  end;

  edtUser.Text := '';
  edtPass.Text := '';
  tcMain.ActiveTab := tiDashboard;
  RefreshDashboard;
  LoadMerenja;
  LoadNalozi;
  LoadOprema;
  LoadMagacin;
end;

procedure TfrmMain.btnNavDashClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiDashboard;
  RefreshDashboard;
end;

procedure TfrmMain.btnNavMerenjeClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMerenje;
  LoadMerenja;
end;

procedure TfrmMain.btnNavNaloziClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiNalozi;
  LoadNalozi(cmbNalogFilter.Text);
end;

procedure TfrmMain.btnNavOpremaClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiOprema;
  LoadOprema;
end;

procedure TfrmMain.btnNavMagacinClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMagacin;
  LoadMagacin;
end;

procedure TfrmMain.btnRefreshDashClick(Sender: TObject);
begin
  RefreshDashboard;
end;

{ ===================================================================
  MERENJA
  =================================================================== }

procedure TfrmMain.btnNovoMerenjeClick(Sender: TObject);
begin
  LoadBazenCombo(cmbMerBazen);
  edtMerPH.Text := ''; edtMerHlor.Text := '';
  edtMerTemp.Text := ''; edtMerUneo.Text := '';
  lblMerErr.Text := '';
  tcMain.ActiveTab := tiMerenjeForm;
end;

procedure TfrmMain.btnSaveMerenjeClick(Sender: TObject);
var
  Q: TFDQuery;
  PH, Hlor, Temp: Double;
  Alarm: string;
  BazenID: Integer;
begin
  lblMerErr.Text := '';
  if cmbMerBazen.ItemIndex <= 0 then
  begin lblMerErr.Text := 'Izaberite bazen.'; Exit; end;
  if not TryStrToFloat(edtMerPH.Text, PH) then
  begin lblMerErr.Text := 'Unesite ispravnu pH vrednost.'; Exit; end;
  if not TryStrToFloat(edtMerHlor.Text, Hlor) then
  begin lblMerErr.Text := 'Unesite ispravnu vrednost hlora.'; Exit; end;
  if not TryStrToFloat(edtMerTemp.Text, Temp) then
  begin lblMerErr.Text := 'Unesite ispravnu temperaturu.'; Exit; end;

  { Provera granica: pH 6.8-7.6, Hlor 0.5-2.0 }
  if (PH < 6.8) or (PH > 7.6) or (Hlor < 0.5) or (Hlor > 2.0) then
    Alarm := 'Y'
  else
    Alarm := 'N';

  BazenID := FBazenIDs[cmbMerBazen.ItemIndex];

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'INSERT INTO MERENJE_VODE (MV_BAZEN_ID, MV_DATUM, MV_PH, MV_HLOR, MV_TEMP, MV_UNEO, MV_ALARM, MV_NAPOMENA) ' +
      'VALUES (:BID, :DATUM, :PH, :HLOR, :TEMP, :UNEO, :ALARM, :NAP)';
    Q.ParamByName('BID').AsInteger := BazenID;
    Q.ParamByName('DATUM').AsDateTime := Now;
    Q.ParamByName('PH').AsFloat := PH;
    Q.ParamByName('HLOR').AsFloat := Hlor;
    Q.ParamByName('TEMP').AsFloat := Temp;
    Q.ParamByName('UNEO').AsString := Trim(edtMerUneo.Text);
    Q.ParamByName('ALARM').AsString := Alarm;
    if Alarm = 'Y' then
      Q.ParamByName('NAP').AsString :=
        Format('ALARM: pH=%.2f (6.8-7.6), Hlor=%.3f (0.5-2.0)', [PH, Hlor])
    else
      Q.ParamByName('NAP').AsString := '';
    Q.ExecSQL;
    dmData.CommitWork;

    { Ako je alarm, automatski otvori nalog }
    if Alarm = 'Y' then
    begin
      Q.SQL.Text :=
        'INSERT INTO RADNI_NALOG (RN_BAZEN_ID, RN_DATUM_OTVAR, RN_TIP, RN_KATEGORIJA, ' +
        'RN_OPIS, RN_STATUS, RN_PRIORITET, RN_BLOKIRA_REZ) ' +
        'VALUES (:BID, :DATUM, ''Hitno'', ''Kvalitet vode'', :OPIS, ''Otvoren'', 1, ''Y'')';
      Q.ParamByName('BID').AsInteger := BazenID;
      Q.ParamByName('DATUM').AsDateTime := Now;
      Q.ParamByName('OPIS').AsString :=
        Format('AUTOMATSKI NALOG: Merenje van granica — pH=%.2f, Hlor=%.3f. Rezervacije blokirane.', [PH, Hlor]);
      Q.ExecSQL;
      dmData.CommitWork;
      ShowMessage('⚠ ALARM! Parametri van granica.' + #13#10 +
        'Automatski otvoren hitni nalog.' + #13#10 +
        'Rezervacije za ovaj bazen su blokirane.');
    end;

    LoadMerenja;
    tcMain.ActiveTab := tiMerenje;
  except
    on E: Exception do lblMerErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelMerenjeClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMerenje;
end;

{ ===================================================================
  RADNI NALOZI
  =================================================================== }

procedure TfrmMain.btnNoviNalogClick(Sender: TObject);
begin
  LoadBazenCombo(cmbNalogBazen);
  LoadOpremaCombo;
  cmbNalogTip.Text := 'Preventivno';
  cmbNalogPrior.Text := '3 - Normalan';
  cmbNalogBazen.ItemIndex := 0;
  cmbNalogOprema.ItemIndex := 0;
  edtNalogIzvrsio.Text := '';
  memoNalogOpis.Text := '';
  chkBlokiraj.IsChecked := False;
  lblNalogErr.Text := '';
  tcMain.ActiveTab := tiNalogForm;
end;

procedure TfrmMain.cmbNalogFilterChange(Sender: TObject);
begin
  LoadNalozi(cmbNalogFilter.Text);
end;

procedure TfrmMain.NalogCardClick(Sender: TObject);
begin
  ShowNalogDetail(TControl(Sender).Tag);
end;

procedure TfrmMain.btnSaveNalogClick(Sender: TObject);
var Q: TFDQuery; Prior: Integer; Blok: string;
begin
  lblNalogErr.Text := '';
  if Trim(memoNalogOpis.Text) = '' then
  begin lblNalogErr.Text := 'Opis je obavezan.'; Exit; end;
  if cmbNalogTip.Text = '' then
  begin lblNalogErr.Text := 'Tip je obavezan.'; Exit; end;

  Prior := 3;
  if Pos('1', cmbNalogPrior.Text) > 0 then Prior := 1
  else if Pos('2', cmbNalogPrior.Text) > 0 then Prior := 2;

  Blok := 'N';
  if chkBlokiraj.IsChecked then Blok := 'Y';

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'INSERT INTO RADNI_NALOG ' +
      '(RN_BAZEN_ID, RN_OPREMA_ID, RN_DATUM_OTVAR, RN_TIP, RN_KATEGORIJA, ' +
      ' RN_OPIS, RN_IZVRSIO, RN_STATUS, RN_PRIORITET, RN_BLOKIRA_REZ) ' +
      'VALUES (:BID, :OID, :DATUM, :TIP, :KAT, :OPIS, :IZV, ''Otvoren'', :PRIOR, :BLOK)';

    if (cmbNalogBazen.ItemIndex > 0) and (cmbNalogBazen.ItemIndex <= High(FBazenIDs)) then
      Q.ParamByName('BID').AsInteger := FBazenIDs[cmbNalogBazen.ItemIndex]
    else
      Q.ParamByName('BID').Clear;

    if (cmbNalogOprema.ItemIndex > 0) and (cmbNalogOprema.ItemIndex <= High(FOpremaIDs)) then
      Q.ParamByName('OID').AsInteger := FOpremaIDs[cmbNalogOprema.ItemIndex]
    else
      Q.ParamByName('OID').Clear;

    Q.ParamByName('DATUM').AsDateTime := Now;
    Q.ParamByName('TIP').AsString   := cmbNalogTip.Text;
    Q.ParamByName('KAT').AsString   := cmbNalogKat.Text;
    Q.ParamByName('OPIS').AsString  := Trim(memoNalogOpis.Text);
    Q.ParamByName('IZV').AsString   := Trim(edtNalogIzvrsio.Text);
    Q.ParamByName('PRIOR').AsInteger := Prior;
    Q.ParamByName('BLOK').AsString  := Blok;
    Q.ExecSQL;
    dmData.CommitWork;
    LoadNalozi(cmbNalogFilter.Text);
    tcMain.ActiveTab := tiNalozi;
  except
    on E: Exception do lblNalogErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelNalogClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiNalozi;
end;

procedure TfrmMain.btnZatvoriNalogClick(Sender: TObject);
var Q: TFDQuery;
begin
  if MessageDlg('Zatvoriti ovaj nalog? Rezervacije ce biti ponovo omogucene.',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'UPDATE RADNI_NALOG SET RN_STATUS=''Zatvoren'', ' +
      'RN_DATUM_ZATVR=:DATUM, RN_BLOKIRA_REZ=''N'' WHERE RN_ID=:ID';
    Q.ParamByName('DATUM').AsDateTime := Now;
    Q.ParamByName('ID').AsInteger := FNalogCurrentID;
    Q.ExecSQL;
    dmData.CommitWork;
    LoadNalozi(cmbNalogFilter.Text);
    ShowNalogDetail(FNalogCurrentID);
    RefreshDashboard;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.btnBackNalogClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiNalozi;
end;

{ ===================================================================
  OPREMA
  =================================================================== }

procedure TfrmMain.btnNovaOpremaClick(Sender: TObject);
begin
  LoadBazenCombo(cmbOpBazen);
  FOpIsNew := True; FOpCurrentID := -1;
  edtOpNaziv.Text := ''; cmbOpTip.Text := 'Pumpa';
  cmbOpStatus.Text := 'Aktivna'; edtOpModel.Text := '';
  edtOpSerial.Text := ''; edtOpDatum.Text := '';
  memoOpNap.Text := ''; cmbOpBazen.ItemIndex := 0;
  lblOpErr.Text := '';
  tcMain.ActiveTab := tiOpremaForm;
end;

procedure TfrmMain.OpremaCardClick(Sender: TObject);
begin
  FOpIsNew := False;
  FOpCurrentID := TControl(Sender).Tag;
  LoadBazenCombo(cmbOpBazen);
  var Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT * FROM OPREMA WHERE OP_ID=:ID';
    Q.ParamByName('ID').AsInteger := FOpCurrentID;
    Q.Open;
    if not Q.IsEmpty then
    begin
      edtOpNaziv.Text  := Q.FieldByName('OP_NAZIV').AsString;
      cmbOpTip.Text    := Q.FieldByName('OP_TIP').AsString;
      cmbOpStatus.Text := Q.FieldByName('OP_STATUS').AsString;
      edtOpModel.Text  := Q.FieldByName('OP_MODEL').AsString;
      edtOpSerial.Text := Q.FieldByName('OP_SERIJSKI').AsString;
      edtOpDatum.Text  := Q.FieldByName('OP_DATUM_NABAVKE').AsString;
      memoOpNap.Text   := Q.FieldByName('OP_NAPOMENA').AsString;
      var BID := Q.FieldByName('OP_BAZEN_ID').AsInteger;
      cmbOpBazen.ItemIndex := 0;
      for var I := 0 to High(FBazenIDs) do
        if FBazenIDs[I] = BID then begin cmbOpBazen.ItemIndex := I; Break; end;
    end;
  finally
    Q.Free;
  end;
  lblOpErr.Text := '';
  tcMain.ActiveTab := tiOpremaForm;
end;

procedure TfrmMain.btnSaveOpremaClick(Sender: TObject);
var Q: TFDQuery;
begin
  lblOpErr.Text := '';
  if Trim(edtOpNaziv.Text) = '' then begin lblOpErr.Text := 'Naziv je obavezan.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    if FOpIsNew then
      Q.SQL.Text :=
        'INSERT INTO OPREMA (OP_NAZIV,OP_TIP,OP_STATUS,OP_BAZEN_ID,OP_MODEL,OP_SERIJSKI,OP_DATUM_NABAVKE,OP_NAPOMENA) ' +
        'VALUES (:NAZ,:TIP,:STAT,:BID,:MOD,:SER,:DAT,:NAP)'
    else
    begin
      Q.SQL.Text :=
        'UPDATE OPREMA SET OP_NAZIV=:NAZ,OP_TIP=:TIP,OP_STATUS=:STAT,OP_BAZEN_ID=:BID,' +
        'OP_MODEL=:MOD,OP_SERIJSKI=:SER,OP_DATUM_NABAVKE=:DAT,OP_NAPOMENA=:NAP WHERE OP_ID=:ID';
      Q.ParamByName('ID').AsInteger := FOpCurrentID;
    end;
    Q.ParamByName('NAZ').AsString  := Trim(edtOpNaziv.Text);
    Q.ParamByName('TIP').AsString  := cmbOpTip.Text;
    Q.ParamByName('STAT').AsString := cmbOpStatus.Text;
    Q.ParamByName('MOD').AsString  := Trim(edtOpModel.Text);
    Q.ParamByName('SER').AsString  := Trim(edtOpSerial.Text);
    Q.ParamByName('NAP').AsString  := Trim(memoOpNap.Text);
    if (cmbOpBazen.ItemIndex > 0) and (cmbOpBazen.ItemIndex <= High(FBazenIDs)) then
      Q.ParamByName('BID').AsInteger := FBazenIDs[cmbOpBazen.ItemIndex]
    else
      Q.ParamByName('BID').Clear;
    if Trim(edtOpDatum.Text) <> '' then
      Q.ParamByName('DAT').AsDate := StrToDateDef(edtOpDatum.Text, Date)
    else
      Q.ParamByName('DAT').Clear;
    Q.ExecSQL;
    dmData.CommitWork;
    LoadOprema;
    tcMain.ActiveTab := tiOprema;
  except
    on E: Exception do lblOpErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelOpremaClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiOprema;
end;

{ ===================================================================
  MAGACIN
  =================================================================== }

procedure TfrmMain.btnNoviMatClick(Sender: TObject);
begin
  FMatIsNew := True; FMatCurrentID := -1;
  edtMatNaziv.Text := ''; cmbMatTip.Text := 'Hemija';
  edtMatJed.Text := 'kg'; edtMatZal.Text := '0'; edtMatMin.Text := '0';
  lblMatErr.Text := '';
  tcMain.ActiveTab := tiMatForm;
end;

procedure TfrmMain.btnSaveMatClick(Sender: TObject);
var Q: TFDQuery;
begin
  lblMatErr.Text := '';
  if Trim(edtMatNaziv.Text) = '' then begin lblMatErr.Text := 'Naziv je obavezan.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'INSERT INTO MATERIJAL (MAT_NAZIV,MAT_TIP,MAT_JEDINICA,MAT_ZALIHA,MAT_MIN_ZAL) ' +
      'VALUES (:NAZ,:TIP,:JED,:ZAL,:MIN)';
    Q.ParamByName('NAZ').AsString := Trim(edtMatNaziv.Text);
    Q.ParamByName('TIP').AsString := cmbMatTip.Text;
    Q.ParamByName('JED').AsString := Trim(edtMatJed.Text);
    Q.ParamByName('ZAL').AsFloat  := StrToFloatDef(edtMatZal.Text, 0);
    Q.ParamByName('MIN').AsFloat  := StrToFloatDef(edtMatMin.Text, 0);
    Q.ExecSQL;
    dmData.CommitWork;
    LoadMagacin;
    tcMain.ActiveTab := tiMagacin;
  except
    on E: Exception do lblMatErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelMatClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMagacin;
end;

end.
