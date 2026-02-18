import SwiftUI
import SpriteKit

/// Bridges SpriteKit scene into SwiftUI, with a score overlay and "Press SPACE" prompt.
struct GameView: View {
    @ObservedObject var state: GameState
    @State private var scene: PongGameScene?

    var body: some View {
        ZStack {
            if let scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .ignoresSafeArea()
            }

            // "Press SPACE to start" overlay
            VStack {
                Spacer()
                Text("Press SPACE to start each round")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.cgaLightGray.opacity(0.6))
                    .padding(.bottom, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cgaBlack)
        .onAppear {
            if scene == nil {
                let s = PongGameScene(size: CGSize(width: 640, height: 400))
                s.scaleMode = .aspectFit
                s.gameState = state
                scene = s
            }
        }
    }
}
