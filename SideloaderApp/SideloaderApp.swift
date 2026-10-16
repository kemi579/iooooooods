import SwiftUI

@main
struct SideloaderRoot: App {
    @StateObject private var store = CertStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                SignView()
                    .tabItem { Label("Подпись", systemImage: "signature") }
                CertsView()
                    .tabItem { Label("Сертификаты", systemImage: "key") }
            }
            .environmentObject(store)
        }
    }
}
