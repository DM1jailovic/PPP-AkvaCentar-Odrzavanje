# OdrzavanjeAC — Uputstvo za pokretanje

## Struktura foldera (identična ProcesProdajeAC)

```
OdrzavanjeAC\
├── OdrzavanjeAC.exe           ← buildovana aplikacija
├── OdrzavanjeAC.dpr
├── OdrzavanjeAC.dproj
├── OdrzavanjeAC.dproj.local
├── Projekat.pas
├── Projekat.fmx
├── Unit2.pas
├── Unit2.dfm
│
├── Baza\                      ← KREIRA SE AUTOMATSKI pri prvom pokretanju
│   └── ODRZAVANJE.FDB         ← baza podataka (kreira se automatski)
│
├── fbclient.dll               ← Firebird Embedded (obavezno!)
├── ib_util.dll
├── icudt63.dll                ← (broj verzije zavisi od FB verzije)
├── icuin63.dll
├── icuuc63.dll
├── firebird.conf
├── firebird.msg
├── plugins\
│   └── engine13.dll           ← FB4 Embedded engine
└── intl\
    └── fbintl.dll
```

---

## Korak 1 — Nabaviti Firebird Embedded DLL-ove

### Opcija A — iz instalirane Firebird 4.0 kolekcije:
Skinuti **Firebird-4.0.x.xxxxx_Win32.zip** (Embedded) sa:
https://firebirdsql.org/en/firebird-4-0/

Raspakirati i kopirati sve fajlove pored `OdrzavanjeAC.exe`.

### Opcija B — iz postojeće Firebird instalacije:
Ako imaš Firebird instaliran, idi u:
```
C:\Program Files\Firebird\Firebird_4_0\
```
i kopiraj:
- `fbclient.dll`
- `ib_util.dll`
- `icudt*.dll`, `icuin*.dll`, `icuuc*.dll`
- `firebird.conf`, `firebird.msg`
- `plugins\engine13.dll`
- `intl\fbintl.dll`

---

## Korak 2 — Pokrenuti aplikaciju

Dvaput kliknuti na `OdrzavanjeAC.exe`.

Pri **prvom pokretanju**:
1. Kreira se folder `Baza\` pored exe-a
2. Kreira se `ODRZAVANJE.FDB`
3. Kreiraju se tabele `EQUIPMENT_CENTER` i `MAINTENANCE_LOG`
4. Ubacuju se probni podaci (4 opreme, 4 naloga)
5. Aplikacija se otvara na Dashboard ekranu

U statusnoj traci na dnu vidi se puna putanja do baze.

---

## Build u Delphi 12

1. Otvoriti `OdrzavanjeAC.dproj`
2. Platform: **Win32** (Firebird Embedded je dostupan kao 32-bit)
3. **Project > Options > Compiler > Output directory** — podesiti na folder gdje su DLL-ovi
4. F9 — Build & Run

> **Napomena**: Firebird Embedded je tipično 32-bit build.
> Ako koristiš 64-bit DLL-ove, builduj za Win64.

---

## Baza podataka

| Tabela | Opis |
|---|---|
| `EQUIPMENT_CENTER` | Oprema centra (camci, jet ski, kajaci...) |
| `MAINTENANCE_LOG` | Nalozi/log odrzavanja, vezani za opremu |

Baza se nalazi u `Baza\ODRZAVANJE.FDB` — može se kopirati zajedno
sa aplikacijom na bilo koji računar koji ima Firebird DLL-ove.
