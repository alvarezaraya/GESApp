import SwiftUI

@main
struct GESApp: App {
    init() {
        // Fuerza la inicialización del static let antes del primer render.
        _ = ProblemaGES.todos
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(
                    // Text oculto con la fuente exacta de los números de fila:
                    // fuerza a CoreText a cargar el atlas de New York (serif)
                    // antes de cualquier interacción del usuario.
                    Text("0123456789")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .hidden()
                )
        }
    }
}
