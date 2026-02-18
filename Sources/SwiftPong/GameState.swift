import SwiftUI

// CGA color palette matching the original Turbo Pascal constants
extension Color {
    static let cgaBlack      = Color(red: 0, green: 0, blue: 0)
    static let cgaLightRed   = Color(red: 1.0, green: 1/3, blue: 1/3)
    static let cgaLightBlue  = Color(red: 1/3, green: 1/3, blue: 1.0)
    static let cgaYellow     = Color(red: 1.0, green: 1.0, blue: 1/3)
    static let cgaWhite      = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let cgaLightGray  = Color(red: 2/3, green: 2/3, blue: 2/3)
    static let cgaMagenta    = Color(red: 2/3, green: 0, blue: 2/3)
}

enum GamePhase: Equatable {
    case setupNames
    case setupSound
    case setupMaxPoints
    case setupPaddleLength
    case setupSpeed
    case playing
    case ended
}

@MainActor
class GameState: ObservableObject {
    @Published var phase: GamePhase = .setupNames

    // Player settings
    @Published var playerName: [String] = ["", ""]
    @Published var soundEnabled: Bool = true
    @Published var maxPoints: Int = 21
    @Published var paddleLength: [Int] = [6, 6]
    @Published var tempo: Int = 10  // 0..25, higher = slower

    // Game scores
    @Published var scores: [Int] = [0, 0]
    @Published var winner: Int? = nil  // 0 or 1

    let playerColor: [Color] = [.cgaLightRed, .cgaLightBlue]

    func resetForNewGame() {
        scores = [0, 0]
        winner = nil
        phase = .setupNames
    }

    func advanceSetup() {
        switch phase {
        case .setupNames:       phase = .setupSound
        case .setupSound:       phase = .setupMaxPoints
        case .setupMaxPoints:   phase = .setupPaddleLength
        case .setupPaddleLength: phase = .setupSpeed
        case .setupSpeed:       phase = .playing
        default: break
        }
    }
}
