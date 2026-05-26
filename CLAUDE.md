# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

Use the `BuildProject` MCP tool (xcode-tools) to build. There are no tests, no package manager (no SPM/CocoaPods), and no lint configuration — it is a pure Xcode project.

To quickly validate Swift changes without a full build, use `XcodeRefreshCodeIssuesInFile` on the modified file — it surfaces type errors and missing APIs in seconds.

## Architecture

Single-target iOS SwiftUI app. All data is static (no network, no persistence beyond favorites).

```
GESApp.swift              @main entry — WindowGroup → ContentView
ContentView.swift         List + search + category filter + favorites toggle
DetalleGESView.swift      Detail screen for one ProblemaGES
ProblemaGES.swift         All model types: ProblemaGES struct, CategoriaGES enum, NivelIngresoGES enum
DatosGES.swift            Static data: extension ProblemaGES { static let todos: [ProblemaGES] }
InfoView.swift            Modal sheet (info button in toolbar) — legal disclaimers, decree citation
GuiaSIGGESView.swift      PDF viewer sheet (PDFKit); lives at project root, not inside GES/
```

**PDF guide linking**: `ProblemaGES.archivoGuiaSIGGES` is an optional `String` holding the bare filename of the bundled PDF (e.g., `"04 Alivio del Dolor y Cuidados Paliativos Instructivo GES v2.0.pdf"`). When non-nil, `DetalleGESView` renders the "Ver Guía para SIGGES" button; when nil, the button is omitted entirely. PDFs are loaded from `Bundle.main.resourceURL` (not from an asset catalog). The DS N°29 modified and new problems have `nil` because their SIGGES guides are outdated or don't exist yet.

**Data flow**: `ProblemaGES.todos` is the single source of truth — a hardcoded array of 90 `ProblemaGES` values defined in `DatosGES.swift`. `ContentView` filters this array in a computed property (`problemasFiltrados`) combining search text, category chip selection, and the favorites set.

**Favorites**: stored as a comma-separated string of IDs in `@AppStorage("favoritos")`. The binding `$favoritosString` is passed down to `DetalleGESView` so the star button can write back.

## Key types

`ProblemaGES` (in `ProblemaGES.swift`) has these fields in order:
```swift
id, nombre, categoria, nivelIngreso, descripcion, poblacionObjetivo,
sospechaDiagnostica, confirmacionDiagnostica, garantiaOportunidad, tratamiento, seguimiento
```

`CategoriaGES` — 15 cases with `icono: String` (SF Symbol name) and `color: Color` computed properties. Used for the chip filter bar and the colored icon in each row/detail header.

`NivelIngresoGES` — 4 cases: `.primaria`, `.secundaria`, `.urgencias`, `.ambos`. Each has `icono`, `color`, and `procesoGES: String` — a prose paragraph describing the GES entry flow for that level, shown in `DetalleGESView`'s `seccionIngreso` card.

## Performance warm-ups

`GESApp.init()` eagerly evaluates `ProblemaGES.todos` (prevents first-render lag) and hides a `Text` with the New York serif font to force CoreText to load the glyph atlas before any user interaction — the row numbers use `.system(.title3, design: .serif, weight: .bold)`.

`ContentView.preconstruirIndice()` runs once on `onAppear` in a `Task.detached(priority: .background)`, building a `[Int: String]` map of lowercased searchable text per problem. `aplicarFiltros()` uses this index for O(1) lookups; while the index is being built it falls back to a direct string search.

## Detail view pattern

`DetalleGESView` uses a private `seccionInfo(titulo:icono:contenido:)` helper that renders a labeled card; it silently skips empty strings. The prominent `headerSection` at the top shows the category icon, GES number, problem name, and the two colored capsule badges (category + nivel ingreso).

## Domain context

GES = *Garantías Explícitas en Salud*, Chile's mandatory health guarantees. The current decree is DS N°29 (in force December 1, 2025, covering 2025–2028), which added problems 88, 89, 90 and modified 11 existing ones. All 90 problems and their clinical content reflect this decree.

### DS N°29 / 2025-2028 changes

**New problems (no SIGGES guide exists yet):**
- PS 88 — Tratamiento farmacológico tras alta por cirrosis hepática
- PS 89 — Tratamiento hospitalario para menores de 15 años con depresión grave
- PS 90 — Cesación del consumo de tabaco en personas de 25 años y más

**Modified existing problems (SIGGES guides may be outdated — do NOT add "Ver Guía SIGGES" button to these):**
- PS 1 — Enfermedad Renal Crónica Etapa 4 y 5
- PS 2 — Cardiopatías Congénitas Operables en Menores de 15 Años
- PS 3 — Cáncer Cervicouterino
- PS 6 — Diabetes Mellitus Tipo 1
- PS 7 — Diabetes Mellitus Tipo 2
- PS 22 — Epilepsia en personas de 1 a 15 años
- PS 43 — Tumores Primarios del Sistema Nervioso Central
- PS 45 — Leucemia en personas de 15 años y más
- PS 51 — Fibrosis Quística
- PS 60 — Epilepsia no Refractaria en personas de 15 años y más
- PS 61 — Asma Bronquial en personas de 15 años y más

Modifications include new treatment baskets, access adjustments, expanded services (radiotherapy, biological drugs), and fee updates.

## Content Review Progress

All 90 `ProblemaGES` entries in `DatosGES.swift` are being reviewed field-by-field against the SIGGES PDF guides in `GES/Guias Rapidas SIGGES/`. The review checks that `descripcion`, `poblacionObjetivo`, `sospechaDiagnostica`, `confirmacionDiagnostica`, `garantiaOportunidad`, `tratamiento`, and `seguimiento` are concordant with the official guides.

**Review status** (✅ verified, ⏳ pending):
- PS 1 — Enfermedad Renal Crónica Etapa 4 y 5 ⏳ (DS N°29 modified, no PDF to compare)
- PS 2 — Cardiopatías Congénitas Operables ⏳ (DS N°29 modified, no PDF to compare)
- PS 3 — Cáncer Cervicouterino ⏳ (DS N°29 modified, no PDF to compare)
- PS 4 — Alivio del Dolor y Cuidados Paliativos ✅
- PS 5 — Infarto Agudo del Miocardio ✅
- PS 6 — Diabetes Mellitus Tipo 1 ⏳ (DS N°29 modified, no PDF to compare)
- PS 7 — Diabetes Mellitus Tipo 2 ⏳ (DS N°29 modified, no PDF to compare)
- PS 8 — Cáncer de Mama ✅
- PS 9 — Disrafias Espinales ✅
- PS 10 — Escoliosis ✅
- PS 11 — Cataratas ✅
- PS 12 — Endoprótesis Total de Cadera ✅
- PS 13 — Fisura Labiopalatina ✅
- PS 14 — Cáncer en Menores ✅
- PS 15 — Esquizofrenia ✅
- PS 16 — Cáncer de Testículo ✅
- PS 17 — Linfomas ✅
- PS 18 — VIH/SIDA ✅
- PS 19 — IRA ✅
- PS 20 — Neumonía ✅
- PS 21 — Hipertensión Arterial ✅
- PS 22 — Epilepsia infantil ⏳ (DS N°29 modified)
- PS 23 — Salud Oral 6 años ✅
- PS 24 — Prevención parto prematuro ✅
- PS 25 — Marcapasos ✅
- PS 26 — Colecistectomía ✅
- PS 27 — Cáncer Gástrico ✅
- PS 28 — Cáncer de Próstata ✅
- PS 29 — Vicios de Refracción ✅
- PS 30 — Estrabismo ✅
- PS 31 — Retinopatía Diabética ✅
- PS 32 — Desprendimiento de Retina ✅
- PS 33 — Hemofilia ✅
- PS 34 — Depresión ✅
- PS 35 — Hiperplasia Benigna de Próstata ✅
- PS 36 — Ayudas Técnicas ✅
- PS 37 — ACV Isquémico ✅
- PS 38 — EPOC ✅
- PS 39 — Asma Bronquial infantil ✅
- PS 40 — SDRN ✅
- PS 41 — Artrosis de Cadera y Rodilla ✅
- PS 42 — Hemorragia Subaracnoidea ✅
- PS 43 — Tumores SNC ⏳ (DS N°29 modified, no PDF to compare)
- PS 44 — Hernia del Núcleo Pulposo ✅
- PS 45 — Leucemia ⏳ (DS N°29 modified, no PDF to compare)
- PS 46 — Urgencia Odontológica ✅
- PS 47 — Salud Oral 60 años ✅
- PS 48 — Politraumatizado Grave ✅
- PS 49 — TCE ✅
- PS 50 — Trauma Ocular Grave ✅
- PS 51 — Fibrosis Quística ⏳ (DS N°29 modified, no PDF to compare)
- PS 52 — Artritis Reumatoidea ✅
- PS 53 — Consumo perjudicial alcohol y drogas ✅
- PS 54 — Analgesia del Parto ✅
- PS 55 — Gran Quemado ✅
- PS 56 — Hipoacusia Bilateral ✅
- PS 57 — Retinopatía del Prematuro ✅
- PS 58 — Displasia Broncopulmonar ✅
- PS 59 — Hipoacusia Neurosensorial del Prematuro ✅
- PS 60 — Epilepsia adulto ⏳ (DS N°29 modified, no PDF to compare)
- PS 61 — Asma adulto ⏳ (DS N°29 modified, no PDF to compare)
- PS 62 — Parkinson ✅
- PS 63 — Artritis Idiopática Juvenil ✅
- PS 64 — Prevención Secundaria IRC ✅
- PS 65 — Displasia Luxante de Caderas ✅
- PS 66 — Salud Oral Embarazada ✅
- PS 67 — Esclerosis Múltiple ✅
- PS 68 — Hepatitis B ✅
- PS 69 — Hepatitis C ✅
- PS 70 — Cáncer Colorrectal ✅
- PS 71 — Cáncer de Ovario ✅
- PS 72 — Cáncer Vesical ✅
- PS 73 — Osteosarcoma ✅
- PS 74 — Válvula Aórtica ✅
- PS 75 — Trastorno Bipolar ✅
- PS 76 — Hipotiroidismo ✅
- PS 77 — Hipoacusia menor 4 años ✅
- PS 78 — Lupus Eritematoso Sistémico ✅
- PS 79 — Válvulas Mitral y Tricúspide ✅
- PS 80 — Helicobacter Pylori ✅
- PS 81 — Cáncer de Pulmón ✅
- PS 82 — Cáncer de Tiroides ✅
- PS 83 — Cáncer Renal ✅
- PS 84 — Mieloma Múltiple ✅
- PS 85 — Alzheimer y Otras Demencias ✅
- PS 86 — Agresión Sexual ✅
- PS 87 — Rehabilitación SARS-CoV-2 ✅
- PS 88 — Cirrosis Hepática ⏳ (DS N°29 new, no PDF)
- PS 89 — Depresión Grave menores 15 años ⏳ (DS N°29 new, no PDF)
- PS 90 — Cesación de Tabaco ⏳ (DS N°29 new, no PDF)
