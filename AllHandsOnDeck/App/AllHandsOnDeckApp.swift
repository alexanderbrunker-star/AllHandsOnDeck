import SwiftUI

@main
struct AllHandsOnDeckApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var linkHandler = UniversalLinkHandler()

    init() {
        UINavigationBar.appearance().tintColor = UIColor(Theme.gold)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
                .environmentObject(linkHandler)
                .preferredColorScheme(.dark)
                .tint(Theme.gold)
                .onOpenURL { url in
                    // Custom-scheme: allhands://join?session=ABC
                    linkHandler.handle(url: url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    // Universal Link: https://allhands.captainleopard.app/join/<id>
                    if let url = activity.webpageURL {
                        linkHandler.handle(url: url)
                    }
                }
        }
    }
}
