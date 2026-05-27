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

`NivelIngresoGES` — 4 cases (`.primaria`, `.secundaria`, `.urgencias`, `.ambos`), each with `procesoGES: String` prose shown in the detail view.

## Domain context

GES = *Garantías Explícitas en Salud*, Chile's mandatory health guarantees. Current decree: DS N°29 (in force 1 Dec 2025, covering 2025–2028).

**DS N°29 new problems** — `estadoDS29: .nuevo`, no SIGGES guide exists:
- PS 88 — Cirrosis hepática (tras alta hospitalaria)
- PS 89 — Depresión grave en menores de 15 años
- PS 90 — Cesación del consumo de tabaco

**DS N°29 modified problems** — `estadoDS29: .modificado`, available PDF is from the prior decree:
PS 1, 2, 3, 6, 7, 22, 43, 45, 51, 60, 61

`archivoGuiaSIGGES` **should be set** on these 11 PS — `DetalleGESView` automatically shows the subtitle "Guía del decreto anterior" when `estadoDS29 == .modificado`, so the old-guide disclaimer is built into the UI.

Do **not** set `archivoGuiaSIGGES` on the 3 new PS (88, 89, 90) — no SIGGES guide exists for them.

## Content review

All 90 `ProblemaGES` entries have been reviewed against available SIGGES PDF guides (`GES/Guias Rapidas SIGGES/`). PS 1–87 are fully verified. PS 88–90 have no PDF (DS N°29 new) and cannot be verified against an official guide.
