import SwiftUI
import Observation

/// Fuente de verdad para la navegación dirigida desde App Intents (Siri, Atajos,
/// Spotlight, botón de Acción). Los intents corren en el proceso de la app cuando
/// se ejecutan en primer plano (`openAppWhenRun`), depositan aquí la intención de
/// navegación y `ContentView` la consume —tanto en arranque frío (`onAppear`) como
/// en caliente (`onChange`)—.
///
/// Las solicitudes son banderas/opcionales de un solo uso: `ContentView` las
/// limpia tras consumirlas para evitar re-disparos.
@MainActor
@Observable
final class NavegadorGES {
    static let shared = NavegadorGES()
    private init() {}

    /// PS que se debe abrir en la vista de detalle.
    var problemaParaAbrir: ProblemaGES?

    /// Categoría por la que se debe filtrar la lista.
    var categoriaParaFiltrar: CategoriaGES?

    /// Solicitud de mostrar solo favoritos.
    var debeAbrirFavoritos = false

    /// Solicitud de activar la búsqueda. `textoBusqueda` puede traer texto inicial.
    var debeAbrirBusqueda = false
    var textoBusqueda = ""

    // MARK: - API para intents

    func abrir(_ problema: ProblemaGES) {
        problemaParaAbrir = problema
    }

    func filtrar(_ categoria: CategoriaGES) {
        categoriaParaFiltrar = categoria
    }

    func mostrarFavoritos() {
        debeAbrirFavoritos = true
    }

    func buscar(_ texto: String = "") {
        textoBusqueda = texto
        debeAbrirBusqueda = true
    }
}
