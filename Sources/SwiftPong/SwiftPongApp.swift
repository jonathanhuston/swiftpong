import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct SwiftPongApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            ContentView(state: gameState)
                .frame(width: 640, height: 400)
                .background(Color.cgaBlack)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @ObservedObject var state: GameState

    var body: some View {
        Group {
            switch state.phase {
            case .setupNames:
                PlayerNamesView(state: state)
            case .setupSound:
                SoundToggleView(state: state)
            case .setupMaxPoints:
                MaxPointsView(state: state)
            case .setupPaddleLength:
                PaddleLengthView(state: state)
            case .setupSpeed:
                BallSpeedView(state: state)
            case .playing:
                GameView(state: state)
            case .ended:
                EndGameView(state: state)
            }
        }
    }
}
