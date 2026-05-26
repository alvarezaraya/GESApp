import SwiftUI

@main
struct GESApp: App {
    init() {
        // Fuerza la inicialización del static let antes del primer render,
        // evitando que ocurra durante una animación o interacción del usuario.
        _ = ProblemaGES.todos
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
