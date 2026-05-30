# GES — Garantías Explícitas en Salud

Aplicación iOS (SwiftUI) que reúne en el bolsillo los **90 Problemas de Salud GES** de Chile, con su flujo de ingreso al sistema, garantías de oportunidad y las **Guías Rápidas SIGGES** en PDF, listas para consultar sin conexión.

> Basada en el **Decreto Supremo N° 29** del Ministerio de Salud de Chile, vigente desde el **1 de diciembre de 2025** (período 2025–2028).

GES (*Garantías Explícitas en Salud*) es el conjunto de garantías obligatorias de acceso, calidad, oportunidad y protección financiera que rige tanto a FONASA como a las ISAPRE. Esta app es una herramienta de **consulta clínica y administrativa** pensada para profesionales de la red asistencial (APS, urgencias, nivel secundario) que necesitan resolver rápido dónde y cómo se abre un caso GES.

---

## Características

- **Catálogo completo de 90 problemas de salud**, cada uno con descripción, población objetivo, sospecha y confirmación diagnóstica, garantía de oportunidad, tratamiento y seguimiento.
- **Flujo de ingreso al sistema GES** explicado por problema: en qué nivel de la red se confirma y notifica el caso (APS, urgencias, nivel secundario o vías mixtas).
- **Guías Rápidas SIGGES embebidas en PDF** (visor con búsqueda dentro del documento), disponibles sin conexión.
- **Búsqueda instantánea** por número, nombre, descripción o población objetivo, insensible a mayúsculas y tildes, con *debounce* de 200 ms.
- **Filtro por categoría** (15 categorías clínicas) y **ordenamiento** por número, nombre o categoría — ambos se conservan entre lanzamientos.
- **Favoritos** persistentes, marcables con deslizamiento o menú contextual.
- **Avisos del DS N°29**: banner naranja en los problemas nuevos o modificados por el decreto vigente.
- **Quick Actions** desde el ícono de la app: *Mis Favoritos* y *Buscar PS*.
- **Accesibilidad de primera clase**: VoiceOver, Control por Voz (alias cortos de entrada), Dynamic Type (incluidos tamaños de accesibilidad) y soporte de contraste/transparencia reducida.

---

## Arquitectura

App SwiftUI de **target único**, **100% offline**. Todos los datos son estáticos: no hay red, ni backend, ni persistencia más allá de los favoritos. Proyecto Xcode puro — sin SPM, CocoaPods ni dependencias externas.

```
GESApp.swift           @main — WindowGroup → ContentView; AppDelegate/SceneDelegate para Quick Actions
ContentView.swift      Lista + búsqueda + filtro por categoría + favoritos + ordenamiento
DetalleGESView.swift   Pantalla de detalle de un problema GES
ProblemaGES.swift      Modelos: ProblemaGES, CategoriaGES, NivelIngresoGES, EstadoDS29
DatosGES.swift         Datos estáticos: ProblemaGES.todos — 90 entradas
GuiaSIGGESView.swift   Visor de PDF (PDFKit) con búsqueda dentro del documento
InfoView.swift         Hoja modal "Acerca de"
IntegridadDatos.swift  Validaciones de integridad (solo DEBUG), desde GESApp.init()
GES/Guias Rapidas SIGGES/   90 PDFs de las guías SIGGES (recursos del bundle)
```

### Flujo de datos

`ProblemaGES.todos` (los 90 problemas) → `ContentView.aplicarFiltros()` combina el texto de búsqueda, la categoría seleccionada, el estado de "solo favoritos" y el orden elegido para producir `resultados`, que alimenta la `List`. Con solo 90 entradas el filtrado corre en línea por cada cambio, sin índice precomputado.

Los favoritos se guardan como un string de IDs separados por comas en `@AppStorage("favoritos")` y se propagan a `DetalleGESView`. El orden y el filtro de categoría también persisten vía `@AppStorage`.

### Guías PDF

`ProblemaGES.archivoGuiaSIGGES` es un nombre de archivo opcional. Cuando no es `nil`, las vistas muestran el botón **"Ver Guía para SIGGES"**; cuando es `nil`, se omite. Los PDFs viven en `GES/Guias Rapidas SIGGES/` y se cargan desde `Bundle.main.resourceURL`. `GuiaSIGGESView` los renderiza con PDFKit, carga el documento fuera del hilo principal y ofrece búsqueda con navegación entre coincidencias.

---

## Componentes y funciones clave

### Modelos (`ProblemaGES.swift`)

**`ProblemaGES`** — un problema de salud GES. Campos, en orden:

```
id, nombre, categoria, nivelIngreso, descripcion, poblacionObjetivo,
sospechaDiagnostica, confirmacionDiagnostica, garantiaOportunidad, tratamiento, seguimiento,
archivoGuiaSIGGES (String? = nil), estadoDS29 (EstadoDS29 = .vigente)
```

**`CategoriaGES`** — 15 categorías clínicas (cardiovascular, oncológico, respiratorio, neurológico, salud mental, etc.). Cada caso expone un `icono` (SF Symbol) y un `color`. Algunos colores se ajustan a mano para cumplir el contraste mínimo WCAG AA.

**`NivelIngresoGES`** — 6 vías de ingreso al sistema GES, cada una con `icono`, `color` y un texto `procesoGES` que describe el flujo:

| Caso | Significado |
|------|-------------|
| `.primaria` | Confirmación y notificación en APS/CESFAM. |
| `.secundaria` | SIC de derivación simple; el caso abre al confirmar el especialista. |
| `.urgencias` | Se confirma y notifica directamente en el Servicio de Urgencia. |
| `.ambos` | Vía mixta: ingreso en APS o nivel secundario según el caso. |
| `.cualquierNivel` | Puede iniciarse en urgencias, APS o nivel secundario. |
| `.derivaSecundaria` | APS emite SIC que registra la **sospecha en SIGGES** (inicia la garantía) y deriva siempre a nivel secundario. |

**`EstadoDS29`** — `.vigente` / `.modificado` / `.nuevo`. Las entradas no vigentes muestran un banner naranja en el detalle; las modificadas muestran además la guía del decreto anterior con su subtítulo.

### `ContentView.swift`

Pantalla principal. Funciones destacadas:

- **`aplicarFiltros()`** — el corazón del filtrado: aplica favoritos, categoría y búsqueda (con `folding` insensible a mayúsculas/tildes sobre `id + nombre + descripción + población`), luego ordena.
- **`toggleFavorito(_:)`** — añade/quita un favorito y reescribe el string de `@AppStorage`.
- **`ejecutar(_:)` / `activarBusqueda()`** — manejan las Quick Actions del ícono (favoritos / buscar), incluyendo el arranque en frío.
- Acciones de deslizamiento (favorito y abrir guía) y menú contextual por fila.

### `DetalleGESView.swift`

Detalle de un problema: cabecera con categoría y nivel de ingreso, banner de aviso DS N°29 cuando corresponde, las siete secciones de contenido clínico, el botón de guía SIGGES y el toggle de favorito. Adapta el layout (apila las píldoras) en tamaños de texto de accesibilidad y refuerza el contraste de los fondos cuando el usuario lo pide.

### `GuiaSIGGESView.swift`

Visor de PDF sobre PDFKit (`PDFKitView` envuelve `PDFView`). Carga el documento en segundo plano, ofrece búsqueda con barra de navegación entre coincidencias y se adapta a "Reducir transparencia".

### `IntegridadDatos.swift` (solo DEBUG)

Sustituye a un target de tests. En cada arranque DEBUG valida que:
1. Los IDs sean únicos y secuenciales `1...N`.
2. Toda guía referenciada exista en el bundle.
3. Avisa (sin abortar) de PDFs huérfanos en el bundle que nadie referencia, para no inflar la descarga.

### `GESApp.swift`

Punto de entrada `@main`. Configura las Quick Actions vía `AppDelegate`/`SceneDelegate` y dispara la validación de integridad en DEBUG.

---

## Compilar y ejecutar

Requisitos:

- **Xcode** (proyecto con `IPHONEOS_DEPLOYMENT_TARGET = 26.4`, Swift 5).
- iOS / simulador compatible.

```bash
git clone https://github.com/alvarezaraya/GESApp.git
cd GESApp
open GES.xcodeproj
```

Selecciona un simulador o dispositivo y pulsa **Run** (⌘R). No hay pasos de dependencias: el proyecto es autónomo.

---

## Aviso

Esta aplicación es una **herramienta de consulta** y no reemplaza el juicio clínico, la normativa oficial ni los documentos vigentes del Ministerio de Salud. Ante cualquier discrepancia, prevalece el **Decreto Supremo N° 29** y las **Guías Clínicas / Guías SIGGES oficiales**.

---

## Licencia

Sin licencia declarada. Todos los derechos reservados por el autor salvo indicación contraria. Las Guías Rápidas SIGGES incluidas son propiedad del Ministerio de Salud de Chile.
