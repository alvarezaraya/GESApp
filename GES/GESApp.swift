import SwiftUI
import UIKit
import CoreSpotlight
import AppIntents

@main
struct GESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        _ = ProblemaGES.todos
        #if DEBUG
        IntegridadDatos.validar()
        #endif
        indexarParaSpotlight()
    }

    /// Dona todos los PS al índice de Spotlight para que aparezcan como resultados
    /// del sistema (App Intents · `IndexedEntity`).
    private func indexarParaSpotlight() {
        // `ProblemaGES.todos` está aislado al actor principal (default-isolation =
        // MainActor); construimos las entidades ahí y donamos al índice.
        Task { @MainActor in
            let entidades = ProblemaGES.todos.map(ProblemaGESEntity.init)
            try? await CSSearchableIndex.default().indexAppEntities(entidades)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(
                    Text("0123456789")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .hidden()
                )
        }
    }
}

enum QuickAction: String {
    case favoritos = "com.ges.favoritos"
    case buscar    = "com.ges.buscar"
}

extension Notification.Name {
    static let abrirFavoritos  = Notification.Name("GES.abrirFavoritos")
    static let enfocarBusqueda = Notification.Name("GES.enfocarBusqueda")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    /// Acción pendiente en arranque frío. ContentView la consume en onAppear.
    static var accionPendiente: QuickAction?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.shortcutItems = [
            UIApplicationShortcutItem(
                type: QuickAction.favoritos.rawValue,
                localizedTitle: "Mis Favoritos",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "star.fill")
            ),
            UIApplicationShortcutItem(
                type: QuickAction.buscar.rawValue,
                localizedTitle: "Buscar PS",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass")
            ),
        ]
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Arranque frío vía quick action: ContentView la consume en onAppear.
        if let item = connectionOptions.shortcutItem {
            AppDelegate.accionPendiente = QuickAction(rawValue: item.type)
        }
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        switch QuickAction(rawValue: shortcutItem.type) {
        case .favoritos:
            NotificationCenter.default.post(name: .abrirFavoritos, object: nil)
        case .buscar:
            NotificationCenter.default.post(name: .enfocarBusqueda, object: nil)
        case nil:
            break
        }
        completionHandler(true)
    }
}
