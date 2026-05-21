unit Unit2;

{
  ================================================================
  AquaCentar — Upravljanje Odrzavanjem
  DataModule — Firebird Embedded, prenosiva baza

  Baza se automatski kreira u:
    <exe_folder>\Baza\ODRZAVANJE.FDB

  Nema servera, nema instalacije — samo exe + Firebird DLL-ovi.

  Potrebni DLL-ovi pored .exe (Firebird 3.0 Embedded, 32-bit):
    fbclient.dll
    ib_util.dll
    icudt52.dll  (ili icudt63.dll za FB4)
    icuin52.dll
    icuuc52.dll
    plugins\engine12.dll  (FB3) ili plugins\engine13.dll (FB4)
    intl\fbintl.dll
    firebird.conf
    firebird.msg

  Sve ove fajlove kopirati iz:
    C:\Program Files\Firebird\Firebird_3_0\  (embedded build)
  ili skinuti Firebird Embedded zip sa firebirdsql.org
  ================================================================
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.FMXUI.Wait, FireDAC.Comp.UI,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Dialogs;

type
  TdmData = class(TDataModule)
  private
    FConn       : TFDConnection;
    FDriverLink : TFDPhysFBDriverLink;
    FWaitCursor : TFDGUIxWaitCursor;
    FqEquipment : TFDQuery;
    FqMaintLog  : TFDQuery;
    FqHelper    : TFDQuery;

    function  GetDatabasePath: string;
    procedure EnsureFolders;
    procedure InitConnection;
    procedure CreateTablesIfNotExist;
    procedure InsertSampleDataIfEmpty;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure DataModuleCreate(Sender: TObject);

    property Conn       : TFDConnection read FConn;
    property qEquipment : TFDQuery      read FqEquipment;
    property qMaintLog  : TFDQuery      read FqMaintLog;
    property qHelper    : TFDQuery      read FqHelper;

    function  IsConnected: Boolean;
    function  ExecScalar(const ASQL: string): Integer;
    procedure CommitWork;
    procedure ExecSQL(const ASQL: string);
  end;

var
  dmData: TdmData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ ===================================================================
  CONSTRUCTOR / DESTRUCTOR
  =================================================================== }

constructor TdmData.Create(AOwner: TComponent);
begin
  inherited;
  DataModuleCreate(Self);
end;

destructor TdmData.Destroy;
begin
  if Assigned(FConn) and FConn.Connected then
    FConn.Close;
  FqHelper.Free;
  FqMaintLog.Free;
  FqEquipment.Free;
  FWaitCursor.Free;
  FConn.Free;
  FDriverLink.Free;
  inherited;
end;

{ ===================================================================
  DATAMODULE CREATE — glavni init (isti pattern kao u primeru)
  =================================================================== }

procedure TdmData.DataModuleCreate(Sender: TObject);
begin
  { 1. Osiguraj da postoji Baza\ folder }
  EnsureFolders;

  { 2. Inicijalizuj Firebird Embedded konekciju }
  InitConnection;

  { 3. Kreiraj tabele ako ne postoje }
  try
    FConn.Open;

    if FConn.Connected then
    begin
      CreateTablesIfNotExist;
      InsertSampleDataIfEmpty;

      { Inicijalizuj query komponente }
      FqEquipment := TFDQuery.Create(nil);
      FqEquipment.Connection := FConn;

      FqMaintLog := TFDQuery.Create(nil);
      FqMaintLog.Connection := FConn;

      FqHelper := TFDQuery.Create(nil);
      FqHelper.Connection := FConn;
    end;
  except
    on E: Exception do
      ShowMessage('Greska pri inicijalizaciji baze:' + sLineBreak + E.Message);
  end;
end;

{ ===================================================================
  HELPERS — putanja, folderi, konekcija
  =================================================================== }

function TdmData.GetDatabasePath: string;
var
  LBazaFolder: string;
begin
  { Baza\ folder pored .exe — isti pattern kao u primeru }
  { Go up 2 levels during debug (Win32\Debug\), stay put in release }
  if TDirectory.Exists(TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..'), '')) then
    LBazaFolder := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..'), 'Baza')
  else
    LBazaFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Baza');
  Result := TPath.Combine(LBazaFolder, 'ODRZAVANJE.FDB');
end;

procedure TdmData.EnsureFolders;
var
  LBazaFolder: string;
begin
  if TDirectory.Exists(TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..'), '')) then
    LBazaFolder := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..'), 'Baza')
  else
    LBazaFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Baza');

  if not TDirectory.Exists(LBazaFolder) then
    TDirectory.CreateDirectory(LBazaFolder);
end;

procedure TdmData.InitConnection;
begin
  { Driver link — govori FireDAC-u da koristi fbclient.dll pored exe-a }
  FDriverLink := TFDPhysFBDriverLink.Create(nil);
  { Debug build: exe in Win32\Debug\, DLLs in project root (go up 2 levels) }
  { Release build: DLLs sit next to exe }
  if TFile.Exists(TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..'), 'fbembed.dll')) then
    FDriverLink.VendorLib := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..'), 'fbembed.dll')
  else
    FDriverLink.VendorLib := TPath.Combine(ExtractFilePath(ParamStr(0)), 'fbembed.dll');

  { Wait cursor za FMX }
  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FWaitCursor.Provider := 'FMX';

  { Konekcija — Firebird Embedded (nema Server, nema Port) }
  FConn := TFDConnection.Create(nil);
  FConn.DriverName  := 'FB';
  FConn.LoginPrompt := False;

  FConn.Params.Clear;
  FConn.Params.DriverID := 'FB';
  FConn.Params.Add('Database='  + GetDatabasePath);
  FConn.Params.Add('User_Name=SYSDBA');
  FConn.Params.Add('Password=masterkey');
  FConn.Params.Add('CharacterSet=UTF8');
  FConn.Params.Add('Protocol=Local');
  FConn.Params.Add('CreateDatabase=Yes');
end;

{ ===================================================================
  CREATE TABLES IF NOT EXIST
  Isti pattern kao u primeru — ExecSQL u AfterConnect / nakon Open
  =================================================================== }

procedure TdmData.CreateTablesIfNotExist;

  procedure Tbl(const ASQL: string);
  begin
    try FConn.ExecSQL(ASQL); except end;
  end;

  procedure Seq(const AName: string);
  begin
    try FConn.ExecSQL('CREATE SEQUENCE ' + AName); except end;
  end;

  procedure Trg(const ASQL: string);
  begin
    try FConn.ExecSQL(ASQL); except end;
  end;

begin
  Tbl('CREATE TABLE BAZEN (B_ID INTEGER NOT NULL, B_NAZIV VARCHAR(100) NOT NULL, ' +
      'B_TIP VARCHAR(50), B_STATUS VARCHAR(20) DEFAULT ''Aktivan'', B_NAPOMENA VARCHAR(300), ' +
      'CONSTRAINT PK_BAZEN PRIMARY KEY (B_ID))');
  Seq('SEQ_BAZEN_ID');
  Trg('CREATE OR ALTER TRIGGER TRG_BAZEN_BI FOR BAZEN ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS BEGIN IF (NEW.B_ID IS NULL OR NEW.B_ID = 0) THEN NEW.B_ID = NEXT VALUE FOR SEQ_BAZEN_ID; END');

  Tbl('CREATE TABLE OPREMA (OP_ID INTEGER NOT NULL, OP_NAZIV VARCHAR(100) NOT NULL, ' +
      'OP_TIP VARCHAR(50) NOT NULL, OP_MODEL VARCHAR(100), OP_SERIJSKI VARCHAR(100), ' +
      'OP_STATUS VARCHAR(20) DEFAULT ''Aktivna'', OP_BAZEN_ID INTEGER, OP_DATUM_NABAVKE DATE, ' +
      'OP_NAPOMENA VARCHAR(500), CONSTRAINT PK_OPREMA PRIMARY KEY (OP_ID))');
  Seq('SEQ_OPREMA_ID');
  Trg('CREATE OR ALTER TRIGGER TRG_OPREMA_BI FOR OPREMA ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS BEGIN IF (NEW.OP_ID IS NULL OR NEW.OP_ID = 0) THEN NEW.OP_ID = NEXT VALUE FOR SEQ_OPREMA_ID; END');

  Tbl('CREATE TABLE MERENJE_VODE (MV_ID INTEGER NOT NULL, MV_BAZEN_ID INTEGER NOT NULL, ' +
      'MV_DATUM TIMESTAMP NOT NULL, MV_PH DECIMAL(4,2), MV_HLOR DECIMAL(5,3), MV_TEMP DECIMAL(4,1), ' +
      'MV_UNEO VARCHAR(100), MV_ALARM CHAR(1) DEFAULT ''N'', MV_NAPOMENA VARCHAR(300), ' +
      'CONSTRAINT PK_MERENJE PRIMARY KEY (MV_ID))');
  Seq('SEQ_MERENJE_ID');
  Trg('CREATE OR ALTER TRIGGER TRG_MERENJE_BI FOR MERENJE_VODE ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS BEGIN IF (NEW.MV_ID IS NULL OR NEW.MV_ID = 0) THEN NEW.MV_ID = NEXT VALUE FOR SEQ_MERENJE_ID; END');

  Tbl('CREATE TABLE RADNI_NALOG (RN_ID INTEGER NOT NULL, RN_BAZEN_ID INTEGER, RN_OPREMA_ID INTEGER, ' +
      'RN_DATUM_OTVAR TIMESTAMP NOT NULL, RN_DATUM_ZATVR TIMESTAMP, RN_TIP VARCHAR(30) NOT NULL, ' +
      'RN_KATEGORIJA VARCHAR(50), RN_OPIS VARCHAR(1000) NOT NULL, RN_IZVRSIO VARCHAR(100), ' +
      'RN_STATUS VARCHAR(20) DEFAULT ''Otvoren'', RN_PRIORITET INTEGER DEFAULT 3, ' +
      'RN_TROSAK DECIMAL(10,2) DEFAULT 0, RN_BLOKIRA_REZ CHAR(1) DEFAULT ''N'', ' +
      'RN_FOTO_OTVAR VARCHAR(500), RN_FOTO_ZATVR VARCHAR(500), RN_NAPOMENA VARCHAR(500), ' +
      'CONSTRAINT PK_RADNI_NALOG PRIMARY KEY (RN_ID))');
  Seq('SEQ_RN_ID');
  Trg('CREATE OR ALTER TRIGGER TRG_RN_BI FOR RADNI_NALOG ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS BEGIN IF (NEW.RN_ID IS NULL OR NEW.RN_ID = 0) THEN NEW.RN_ID = NEXT VALUE FOR SEQ_RN_ID; END');

  Tbl('CREATE TABLE MATERIJAL (MAT_ID INTEGER NOT NULL, MAT_NAZIV VARCHAR(100) NOT NULL, ' +
      'MAT_TIP VARCHAR(50), MAT_JEDINICA VARCHAR(20) DEFAULT ''kom'', ' +
      'MAT_ZALIHA DECIMAL(10,3) DEFAULT 0, MAT_MIN_ZAL DECIMAL(10,3) DEFAULT 0, ' +
      'MAT_NAPOMENA VARCHAR(300), CONSTRAINT PK_MATERIJAL PRIMARY KEY (MAT_ID))');
  Seq('SEQ_MAT_ID');
  Trg('CREATE OR ALTER TRIGGER TRG_MAT_BI FOR MATERIJAL ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS BEGIN IF (NEW.MAT_ID IS NULL OR NEW.MAT_ID = 0) THEN NEW.MAT_ID = NEXT VALUE FOR SEQ_MAT_ID; END');

  Tbl('CREATE TABLE POTROSNJA (P_ID INTEGER NOT NULL, P_RN_ID INTEGER NOT NULL, ' +
      'P_MAT_ID INTEGER NOT NULL, P_KOLICINA DECIMAL(10,3) NOT NULL, ' +
      'P_DATUM TIMESTAMP DEFAULT CURRENT_TIMESTAMP, CONSTRAINT PK_POTROSNJA PRIMARY KEY (P_ID))');
  Seq('SEQ_P_ID');
  Trg('CREATE OR ALTER TRIGGER TRG_P_BI FOR POTROSNJA ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS BEGIN IF (NEW.P_ID IS NULL OR NEW.P_ID = 0) THEN NEW.P_ID = NEXT VALUE FOR SEQ_P_ID; END');

  { Korisnici modula odrzavanja }
  Tbl('CREATE TABLE KORISNIK_ODR (' +
      'KO_ID INTEGER NOT NULL, ' +
      'KO_EMP_ID VARCHAR(50) NOT NULL, ' +
      'KO_USERNAME VARCHAR(100) NOT NULL, ' +
      'KO_PASSHASH VARCHAR(200) NOT NULL, ' +
      'KO_DATUM TIMESTAMP DEFAULT CURRENT_TIMESTAMP, ' +
      'CONSTRAINT PK_KORISNIK_ODR PRIMARY KEY (KO_ID), ' +
      'CONSTRAINT UQ_KO_USERNAME UNIQUE (KO_USERNAME))');
  Seq('SEQ_KO_ID');
  Trg('CREATE OR ALTER TRIGGER TRG_KO_BI FOR KORISNIK_ODR ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS BEGIN IF (NEW.KO_ID IS NULL OR NEW.KO_ID = 0) THEN NEW.KO_ID = NEXT VALUE FOR SEQ_KO_ID; END');

  FConn.Commit;
end;

function TdmData.IsConnected: Boolean;
begin
  Result := Assigned(FConn) and FConn.Connected;
end;

function TdmData.ExecScalar(const ASQL: string): Integer;
begin
  Result := 0;
  if not IsConnected then Exit;
  FqHelper.SQL.Text := ASQL;
  FqHelper.Open;
  if not FqHelper.IsEmpty then
    Result := FqHelper.Fields[0].AsInteger;
  FqHelper.Close;
end;

procedure TdmData.CommitWork;
begin
  if IsConnected then
    FConn.Commit;
end;

procedure TdmData.ExecSQL(const ASQL: string);
begin
  if IsConnected then
    FConn.ExecSQL(ASQL);
end;


procedure TdmData.InsertSampleDataIfEmpty;
var Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'SELECT COUNT(*) FROM BAZEN';
    Q.Open;
    if Q.Fields[0].AsInteger > 0 then Exit;
    Q.Close;
  finally
    Q.Free;
  end;

  FConn.ExecSQL('INSERT INTO BAZEN (B_NAZIV,B_TIP) VALUES (''Olimpijski bazen'',''Olimpijski'')');
  FConn.ExecSQL('INSERT INTO BAZEN (B_NAZIV,B_TIP) VALUES (''Decji bazen'',''Decki'')');
  FConn.ExecSQL('INSERT INTO BAZEN (B_NAZIV,B_TIP) VALUES (''Jacuzzi zona'',''Jacuzzi'')');
  FConn.ExecSQL('INSERT INTO BAZEN (B_NAZIV,B_TIP) VALUES (''Sala A'',''Sala'')');

  FConn.ExecSQL('INSERT INTO OPREMA (OP_NAZIV,OP_TIP,OP_STATUS,OP_BAZEN_ID) VALUES (''Pumpa P1'',''Pumpa'',''Aktivna'',1)');
  FConn.ExecSQL('INSERT INTO OPREMA (OP_NAZIV,OP_TIP,OP_STATUS,OP_BAZEN_ID) VALUES (''Filter F1'',''Filter'',''Aktivna'',1)');
  FConn.ExecSQL('INSERT INTO OPREMA (OP_NAZIV,OP_TIP,OP_STATUS,OP_BAZEN_ID) VALUES (''Dozator D1'',''Dozator'',''Aktivna'',2)');

  FConn.ExecSQL('INSERT INTO MATERIJAL (MAT_NAZIV,MAT_TIP,MAT_JEDINICA,MAT_ZALIHA,MAT_MIN_ZAL) VALUES (''Hlor granulat'',''Hemija'',''kg'',150,20)');
  FConn.ExecSQL('INSERT INTO MATERIJAL (MAT_NAZIV,MAT_TIP,MAT_JEDINICA,MAT_ZALIHA,MAT_MIN_ZAL) VALUES (''pH minus'',''Hemija'',''kg'',80,10)');
  FConn.ExecSQL('INSERT INTO MATERIJAL (MAT_NAZIV,MAT_TIP,MAT_JEDINICA,MAT_ZALIHA,MAT_MIN_ZAL) VALUES (''Filter pesak'',''Rezervni deo'',''kg'',200,50)');

  FConn.ExecSQL('INSERT INTO MERENJE_VODE (MV_BAZEN_ID,MV_DATUM,MV_PH,MV_HLOR,MV_TEMP,MV_UNEO,MV_ALARM) VALUES (1,CURRENT_TIMESTAMP,7.2,0.8,26.5,''Marko Jovanovic'',''N'')');
  FConn.ExecSQL('INSERT INTO MERENJE_VODE (MV_BAZEN_ID,MV_DATUM,MV_PH,MV_HLOR,MV_TEMP,MV_UNEO,MV_ALARM,MV_NAPOMENA) VALUES (1,CURRENT_TIMESTAMP,8.1,0.2,27.0,''Marko Jovanovic'',''Y'',''ALARM: pH visok, hlor nizak'')');

  FConn.ExecSQL('INSERT INTO RADNI_NALOG (RN_BAZEN_ID,RN_DATUM_OTVAR,RN_TIP,RN_KATEGORIJA,RN_OPIS,RN_STATUS,RN_PRIORITET,RN_BLOKIRA_REZ) ' +
    'VALUES (1,CURRENT_TIMESTAMP,''Hitno'',''Kvalitet vode'',''ALARM: pH van granica. Rezervacije blokirane.'',''U radu'',1,''Y'')');
  FConn.ExecSQL('INSERT INTO RADNI_NALOG (RN_OPREMA_ID,RN_DATUM_OTVAR,RN_TIP,RN_KATEGORIJA,RN_OPIS,RN_STATUS,RN_PRIORITET) ' +
    'VALUES (2,CURRENT_TIMESTAMP,''Preventivno'',''Servis filtera'',''Redovan servis filter sistema'',''Otvoren'',3)');

  FConn.Commit;
end;

end.