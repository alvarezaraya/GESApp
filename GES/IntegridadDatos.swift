#if DEBUG
import Foundation

/// Validaciones de integridad del catálogo GES, ejecutadas solo en builds DEBUG
/// (y en SwiftUI previews). No tienen coste en release.
///
/// Sustituyen a un target de tests dedicado: detectan en tiempo de desarrollo los
/// errores de contenido más comunes en este proyecto —IDs mal numerados, guías
/// referenciadas que faltan en el bundle, y PDFs huérfanos que solo inflan la
/// descarga—. Se invocan desde `GESApp.init()`.
enum IntegridadDatos {

    static func validar() {
        let problemas = ProblemaGES.todos

        // 1. IDs únicos y secuenciales 1...N.
        let ids = problemas.map(\.id)
        let esperados = Array(1...problemas.count)
        assert(
            ids == esperados,
            "IDs de ProblemaGES.todos no son secuenciales 1...\(problemas.count). " +
            "Encontrados: \(ids.filter { !esperados.contains($0) })"
        )

        // 2. Cada guía referenciada existe en el bundle.
        for p in problemas {
            guard let archivo = p.archivoGuiaSIGGES else { continue }
            assert(
                Bundle.main.resourceURL.map {
                    FileManager.default.fileExists(atPath: $0.appendingPathComponent(archivo).path)
                } ?? false,
                "PS \(p.id) (\(p.nombre)) referencia una guía ausente del bundle: \"\(archivo)\""
            )
        }

        // 3. Aviso (no fatal) de PDFs en el bundle que nadie referencia.
        let referenciados = Set(problemas.compactMap(\.archivoGuiaSIGGES))
        if let recursos = Bundle.main.resourceURL,
           let contenido = try? FileManager.default.contentsOfDirectory(atPath: recursos.path) {
            let huerfanos = contenido
                .filter { $0.hasSuffix(".pdf") }
                .filter { !referenciados.contains($0) }
            if !huerfanos.isEmpty {
                print("⚠️ [IntegridadDatos] PDFs huérfanos en el bundle (inflan la descarga):")
                huerfanos.sorted().forEach { print("   • \($0)") }
            }
        }
    }
}
#endif
