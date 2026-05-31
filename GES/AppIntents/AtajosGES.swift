import AppIntents

/// Atajos de app: aparecen automáticamente en la app Atajos, Spotlight y Siri sin
/// configuración del usuario. Las frases deben incluir el token `\(.applicationName)`.
struct GESAppShortcuts: AppShortcutsProvider {
    static let shortcutTileColor: ShortcutTileColor = .navy

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: BuscarGESIntent(),
            phrases: [
                "Buscar en \(.applicationName)",
                "Buscar un problema de salud en \(.applicationName)",
                "Buscar un PS en \(.applicationName)"
            ],
            shortTitle: "Buscar PS",
            systemImageName: "magnifyingglass"
        )

        AppShortcut(
            intent: AbrirFavoritosIntent(),
            phrases: [
                "Abrir mis favoritos en \(.applicationName)",
                "Ver mis favoritos en \(.applicationName)",
                "Mostrar favoritos en \(.applicationName)"
            ],
            shortTitle: "Favoritos",
            systemImageName: "star.fill"
        )

        AppShortcut(
            intent: ConsultarProblemaIntent(),
            phrases: [
                "Consultar \(\.$problema) en \(.applicationName)",
                "Ver resumen de \(\.$problema) en \(.applicationName)"
            ],
            shortTitle: "Consultar PS",
            systemImageName: "doc.text.magnifyingglass"
        )

        AppShortcut(
            intent: AbrirProblemaIntent(),
            phrases: [
                "Abrir \(\.$target) en \(.applicationName)",
                "Abrir la ficha de \(\.$target) en \(.applicationName)"
            ],
            shortTitle: "Abrir PS",
            systemImageName: "cross.case.fill"
        )

        AppShortcut(
            intent: FiltrarPorCategoriaIntent(),
            phrases: [
                "Ver problemas de \(\.$categoria) en \(.applicationName)",
                "Mostrar categoría \(\.$categoria) en \(.applicationName)"
            ],
            shortTitle: "Ver categoría",
            systemImageName: "line.3.horizontal.decrease.circle"
        )
    }
}
