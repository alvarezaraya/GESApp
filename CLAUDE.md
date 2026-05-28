# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

Use the `BuildProject` MCP tool (xcode-tools) to build. Pure Xcode project — no SPM, no CocoaPods, no lint config.

For quick type-checking without a full build, use `XcodeRefreshCodeIssuesInFile` on the modified file.

## Architecture

Single-target iOS SwiftUI app. All data is static (no network, no persistence beyond favorites).

```
GESApp.swift           @main — WindowGroup → ContentView
ContentView.swift      List + search + category filter + favorites
DetalleGESView.swift   Detail screen for one ProblemaGES
ProblemaGES.swift      Model types: ProblemaGES, CategoriaGES, NivelIngresoGES, EstadoDS29
DatosGES.swift         Static data: ProblemaGES.todos — 90 hardcoded entries
InfoView.swift         "Acerca de" modal sheet
GuiaSIGGESView.swift   PDF viewer (PDFKit) — lives at project root, not inside GES/
```

**Data flow**: `ProblemaGES.todos` → `ContentView.aplicarFiltros()` combines search text, category selection, and favorites set into `resultados`. Favorites persisted as a comma-separated ID string in `@AppStorage("favoritos")`, bound down to `DetalleGESView`.

**PDF guides**: `ProblemaGES.archivoGuiaSIGGES` is an optional filename string (e.g. `"04 Alivio del Dolor... v2.0.pdf"`). When non-nil, `DetalleGESView` shows the "Ver Guía para SIGGES" button; when nil, it's omitted. PDFs live in `GES/Guias Rapidas SIGGES/` and are loaded from `Bundle.main.resourceURL`.

**Search index**: `ContentView.preconstruirIndice()` builds a `[Int: String]` map of lowercased searchable text in a `Task.detached(priority: .background)` on first appear, enabling O(1) lookups in `aplicarFiltros()`.

## Key types

`ProblemaGES` fields (in order):
```
id, nombre, categoria, nivelIngreso, descripcion, poblacionObjetivo,
sospechaDiagnostica, confirmacionDiagnostica, garantiaOportunidad, tratamiento, seguimiento,
archivoGuiaSIGGES (String? = nil), estadoDS29 (EstadoDS29 = .vigente)
```

`EstadoDS29` — `.vigente` / `.modificado` / `.nuevo`. Non-vigente entries show an orange alert banner in `DetalleGESView`. Modified entries also show the PDF button with a "Guía del decreto anterior" subtitle.

`CategoriaGES` — 15 cases, each with `icono: String` (SF Symbol) and `color: Color`.

`NivelIngresoGES` — 6 cases: `.primaria`, `.secundaria`, `.urgencias`, `.ambos`, `.cualquierNivel`, `.derivaSecundaria`. Each has `procesoGES: String` prose shown in the detail view.

- `.derivaSecundaria` — APS creates SIC that opens a formal SIGGES sospecha guarantee + always derives to secondary (used for non-oncological PS where the SIGGES guarantee starts from sospecha at APS)
- `.secundaria` — plain SIC derivation from APS without a SIGGES sospecha guarantee (case opens only at confirmation)
- Oncological PS always use `.derivaSecundaria` (GES opens at sospecha)

## Domain context

GES = *Garantías Explícitas en Salud*, Chile's mandatory health guarantees. Current decree: DS N°29 (in force 1 Dec 2025, covering 2025–2028).

**DS N°29 new problems** — `estadoDS29: .nuevo`, no SIGGES guide exists:
- PS 88 — Cirrosis hepática (tras alta hospitalaria)
- PS 89 — Depresión grave en menores de 15 años
- PS 90 — Cesación del consumo de tabaco

**DS N°29 modified problems still with `estadoDS29: .modificado`** (new guide exists but pending review):
- PS 43 — Tumores Primarios SNC: **keep `.modificado` permanently** — no new DS N°29 guide exists
- PS 45, 51, 60, 61 — new guides available, `.modificado` must be removed once reviewed

PS 1, 2, 3, 6, 7, 22 were originally `.modificado` and have already been resolved (new guides applied, `.modificado` removed).

Do **not** set `archivoGuiaSIGGES` on the 3 new PS (88, 89, 90) — no SIGGES guide exists for them yet.

## Ongoing content review

Active multi-part task processing PS entries sequentially:
- **A. nivelIngreso**: verify against SIGGES guide flow diagrams
- **B. archivoGuiaSIGGES**: update filename to new guide
- **C. estadoDS29**: remove `.modificado` once new guide applied; remove `.nuevo` once guide available and applied
- **D. Text fields**: verify all prose fields against the updated guide
- **E. Delete outdated PDFs**: remove old guide file from project

**Progress**: PS 1–23 complete. **Next: PS 24** (guide v29.0 pages 1–20 already read but NOT yet analyzed — start here).

DS 29/2025 terminology: "embarazadas" → "personas gestantes" in all obstetric text.

**Remaining `archivoGuiaSIGGES` updates** (PS 24 onward):

| PS | New filename | estadoDS29 |
|----|-------------|------------|
| 24 | `"24_-_Prematurez_Prev.Parto_Prematuro_v29.0.pdf"` | vigente |
| 25 | `"25_-_Marcapaso_15_Años_y_Más_v10.0.pdf"` | vigente |
| 27 | `"27_-_Cáncer_Gástrico_v10.0.pdf"` | vigente |
| 28 | `"28_-_Cáncer_de_Próstata_15_Años_y_Más_v12.0.pdf"` | vigente |
| 30 | `"30_-_Estrabismo_Menor_9_Años_v10.0.pdf"` | vigente |
| 31 | `"31_-_Retinopatía_Diabética_v7.0.pdf"` | vigente |
| 37 | `"37_-_Ataque_Cerebrovascular_Isquémico_en_Personas_.pdf"` | vigente |
| 42 | `"42_-_Hemorragia_Subaracnoidea_v.6.0.pdf"` | vigente |
| 43 | keep old `"43 Tumores Primarios SNC Instructivo GES V2.0.pdf"` | stays `.modificado` |
| 45 | `"45_-_Leucemia_15_Años_y_Más_v6.0.pdf"` | `.modificado` → remove |
| 51 | `"51_-_Fibrosis_Quística_v.6.0.pdf"` | `.modificado` → remove |
| 60 | `"60_-_Epilepsia_No_Refractaria_15_Años_y_Más_v.4.0.pdf"` | `.modificado` → remove |
| 61 | `"61_-_Asma_Bronquial_15_Años_y_Más_v.4.0.pdf"` | `.modificado` → remove |
| 62 | `"62_-_Enfermedad_de_Parkinson_v3.0.pdf"` | vigente |
| 67 | `"67-_Esclerosis_Múltiple_Remitente_Recurrente_v4.0.pdf"` | vigente |
| 70 | `"70_-_Cáncer_Colorectal_15_Años_y_Más_4.0.pdf"` | vigente |
| 72 | `"72_-_Cáncer_Vesical_15_Años_y_Más_3.0.pdf"` | vigente |
| 73 | `"73_-_Osteosarcoma_15_Años_y_Más_v3.0.pdf"` | vigente |
| 81 | `"81_-_Cáncer_de_Pulmón_V._3.0.pdf"` | vigente |
| 83 | `"83_-_Cáncer_Renal_en_Personas_de_15_Años_y_Más_V.3.pdf"` | vigente |
| 84 | `"84_-_Mieloma_Múltiple_en_Personas_de_15_Años_y_Más.pdf"` | vigente |
| 88 | `"88_-_Tratamiento_Farmacológico_Cirrosis_v.1.0.pdf"` | `.nuevo` → remove |
| 89 | `"89_-_Tratamiento_Hospitalario_Depresión_v.1.0.pdf"` | `.nuevo` → remove |
| 90 | `"90_-CESACIÓN_DEL_CONSUMO_DE_TABACO_EN_PERSONAS_DE_.pdf"` | `.nuevo` → remove |
