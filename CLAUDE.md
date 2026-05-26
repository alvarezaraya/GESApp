# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

Use the `BuildProject` MCP tool (xcode-tools) to build. There are no tests, no package manager (no SPM/CocoaPods), and no lint configuration — it is a pure Xcode project.

To quickly validate Swift changes without a full build, use `XcodeRefreshCodeIssuesInFile` on the modified file — it surfaces type errors and missing APIs in seconds.

## Architecture

Single-target iOS SwiftUI app. All data is static (no network, no persistence beyond favorites).

```
GESApp.swift          @main entry — WindowGroup → ContentView
ContentView.swift     List + search + category filter + favorites toggle
DetalleGESView.swift  Detail screen for one ProblemaGES
ProblemaGES.swift     All model types: ProblemaGES struct, CategoriaGES enum, NivelIngresoGES enum
DatosGES.swift        Static data: extension ProblemaGES { static let todos: [ProblemaGES] }
```

**Data flow**: `ProblemaGES.todos` is the single source of truth — a hardcoded array of 90 `ProblemaGES` values defined in `DatosGES.swift`. `ContentView` filters this array in a computed property (`problemasFiltrados`) combining search text, category chip selection, and the favorites set.

**Favorites**: stored as a comma-separated string of IDs in `@AppStorage("favoritos")`. The binding `$favoritosString` is passed down to `DetalleGESView` so the star button can write back.

## Key types

`ProblemaGES` (in `ProblemaGES.swift`) has these fields in order:
```swift
id, nombre, categoria, nivelIngreso, descripcion, poblacionObjetivo,
sospechaDiagnostica, confirmacionDiagnostica, garantiaOportunidad, tratamiento, seguimiento
```

`CategoriaGES` — 15 cases with `icono: String` (SF Symbol name) and `color: Color` computed properties. Used for the chip filter bar and the colored icon in each row/detail header.

`NivelIngresoGES` — 4 cases: `.primaria`, `.secundaria`, `.urgencias`, `.ambos`. Each has `icono` and `color`. Displayed as a badge in the detail header alongside the category badge.

## Detail view pattern

`DetalleGESView` uses a private `seccionInfo(titulo:icono:contenido:)` helper that renders a labeled card; it silently skips empty strings. The prominent `headerSection` at the top shows the category icon, GES number, problem name, and the two colored capsule badges (category + nivel ingreso).

## Domain context

GES = *Garantías Explícitas en Salud*, Chile's mandatory health guarantees. The current decree is DS N°29 (in force December 1, 2025, covering 2025–2028), which added problems 88, 89, 90 and modified 11 existing ones. All 90 problems and their clinical content reflect this decree.
