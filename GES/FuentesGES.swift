import Foundation

/// Fuentes oficiales citadas por la app. Centralizadas para que las citas
/// (Guideline 1.4.1 de App Store) sean consistentes y fáciles de actualizar.
enum FuentesGES {
    /// Texto oficial del Decreto Supremo N° 29 (2025) en LeyChile (Biblioteca del
    /// Congreso Nacional de Chile). Es la norma vigente que fija las GES 2025–2028.
    static let decretoURL = URL(string: "https://www.bcn.cl/leychile/navegar?idNorma=1218907")!

    /// Sitio oficial AUGE/GES del Ministerio de Salud (guías clínicas y SIGGES).
    static let minsalURL = URL(string: "https://auge.minsal.cl")!

    /// Cita textual breve de la norma de origen.
    static let decretoCita = "Decreto Supremo N° 29 de 2025, Ministerio de Salud de Chile (publicado el 28 de noviembre de 2025, vigente desde el 1 de diciembre de 2025)."
}
