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

The 3 DS N°29 new PS (88, 89, 90) now have SIGGES guides and have been applied (`.nuevo` removed, `archivoGuiaSIGGES` set).

## Ongoing content review

Multi-part task processing PS entries sequentially:
- **A. nivelIngreso**: verify against SIGGES guide flow diagrams
- **B. archivoGuiaSIGGES**: update filename to new guide
- **C. estadoDS29**: remove `.modificado` once new guide applied; remove `.nuevo` once guide available and applied
- **D. Text fields**: verify all prose fields against the updated guide
- **E. Delete outdated PDFs**: remove old guide file from project

**Progress**: COMPLETE. PS 1–90 reviewed against DS N°29/2025 guides. All filename updates from the table applied, old PDFs deleted, and `.modificado`/`.nuevo` states resolved — except PS 43 (Tumores Primarios SNC), which keeps `.modificado` and its old guide permanently (no new DS N°29 guide exists).

DS 29/2025 terminology: "embarazadas" → "personas gestantes" in all obstetric text.
