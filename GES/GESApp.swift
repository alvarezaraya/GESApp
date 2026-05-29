import SwiftUI
import UIKit

@main
struct GESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        _ = ProblemaGES.todos
        registrarQuickActions()
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

    private func registrarQuickActions() {
        UIApplication.shared.shortcutItems = [
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
    func application(
        _ application: UIApplication,
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
