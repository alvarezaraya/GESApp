import AppIntents
import SwiftUI

// MARK: - Errores

enum NavegacionGESError: Error, CustomLocalizedStringResourceConvertible {
    case problemaNoEncontrado

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .problemaNoEncontrado: "No se encontró ese Problema de Salud GES."
        }
    }
}

// MARK: - Abrir un PS (abre la app en la ficha de detalle)

struct AbrirProblemaIntent: OpenIntent {
    static let title: LocalizedStringResource = "Abrir problema de salud"
    static let description = IntentDescription(
        "Abre la ficha de un Problema de Salud GES.",
        categoryName: "Navegación"
    )

    @Parameter(title: "Problema de salud")
    var target: ProblemaGESEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let problema = target.problema else {
            throw NavegacionGESError.problemaNoEncontrado
        }
        NavegadorGES.shared.abrir(problema)
        return .result()
    }
}

// MARK: - Consultar un PS (resumen en un snippet, sin abrir la app)

struct ConsultarProblemaIntent: AppIntent {
    static let title: LocalizedStringResource = "Consultar problema de salud"
    static let description = IntentDescription(
        "Muestra un resumen de un Problema de Salud GES sin abrir la app.",
        categoryName: "Consulta"
    )
    static let openAppWhenRun = false

    @Parameter(title: "Problema de salud")
    var problema: ProblemaGESEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let p = problema.problema else {
            throw NavegacionGESError.problemaNoEncontrado
        }
        return .result(
            dialog: "PS \(p.id): \(p.nombre)",
            view: ResumenPSView(problema: p)
        )
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar \(\.$problema)")
    }
}

// MARK: - Buscar (abre la app y activa la búsqueda)

struct BuscarGESIntent: AppIntent {
    static let title: LocalizedStringResource = "Buscar problemas GES"
    static let description = IntentDescription(
        "Abre la app y activa la búsqueda de Problemas de Salud GES.",
        categoryName: "Navegación"
    )
    static let openAppWhenRun = true

    @Parameter(title: "Texto de búsqueda")
    var texto: String?

    @MainActor
    func perform() async throws -> some IntentResult {
        NavegadorGES.shared.buscar(texto ?? "")
        return .result()
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Buscar \(\.$texto) en GES")
    }
}

// MARK: - Abrir favoritos

struct AbrirFavoritosIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir mis favoritos"
    static let description = IntentDescription(
        "Abre la app mostrando solo los Problemas de Salud marcados como favoritos.",
        categoryName: "Navegación"
    )
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NavegadorGES.shared.mostrarFavoritos()
        return .result()
    }
}

// MARK: - Filtrar por categoría

struct FiltrarPorCategoriaIntent: AppIntent {
    static let title: LocalizedStringResource = "Ver categoría GES"
    static let description = IntentDescription(
        "Abre la app mostrando los Problemas de Salud de una categoría.",
        categoryName: "Navegación"
    )
    static let openAppWhenRun = true

    @Parameter(title: "Categoría")
    var categoria: CategoriaGES

    @MainActor
    func perform() async throws -> some IntentResult {
        NavegadorGES.shared.filtrar(categoria)
        return .result()
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Ver problemas de \(\.$categoria)")
    }
}
