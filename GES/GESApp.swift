import SwiftUI
import UIKit

@main
struct GESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        _ = ProblemaGES.todos
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appDelegate, appDelegate)
                .background(
                    Text("0123456789")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .hidden()
                )
        }
    }

}

private struct AppDelegateKey: EnvironmentKey {
    static let defaultValue = AppDelegate()
}

extension EnvironmentValues {
    var appDelegate: AppDelegate {
        get { self[AppDelegateKey.self] }
        set { self[AppDelegateKey.self] = newValue }
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
    // Acción pendiente cuando la app arranca fría desde un quick action.
    // ContentView la consume en onAppear.
    var accionPendiente: QuickAction?

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
        // Arranque frío desde quick action
        if let item = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            accionPendiente = QuickAction(rawValue: item.type)
        }
        return true
    }

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        // App ya en background: la UI está activa, notificación directa
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
