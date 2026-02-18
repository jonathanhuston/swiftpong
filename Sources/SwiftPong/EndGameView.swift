import SwiftUI

struct EndGameView: View {
    @ObservedObject var state: GameState
    @State private var blinkVisible = true

    private let monoFont = Font.system(size: 16, design: .monospaced)
    private let titleFont = Font.system(size: 20, weight: .bold, design: .monospaced)

    var body: some View {
        VStack(spacing: 20) {
            Text("P O N G !")
                .font(titleFont)
                .foregroundColor(.cgaMagenta)
                .padding(.top, 20)

            Spacer()

            // Scores
            ForEach(0..<2, id: \.self) { idx in
                HStack {
                    Text("\(state.playerName[idx]) score:")
                        .font(monoFont)
                        .foregroundColor(state.playerColor[idx])
                    Spacer()
                    Text("\(state.scores[idx])")
                        .font(titleFont)
                        .foregroundColor(state.playerColor[idx])
                }
                .padding(.horizontal, 60)
            }

            Spacer()

            // Winner announcement with blink
            if let winner = state.winner {
                Text("Bravo, \(state.playerName[winner])!")
                    .font(titleFont)
                    .foregroundColor(state.playerColor[winner])
                    .opacity(blinkVisible ? 1 : 0)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                            blinkVisible.toggle()
                        }
                    }
            }

            Spacer()

            // Play again prompt
            Text("Play again?")
                .font(monoFont)
                .foregroundColor(.cgaLightGray)

            HStack(spacing: 30) {
                Button(action: { state.resetForNewGame() }) {
                    Text("Y")
                        .font(titleFont)
                        .foregroundColor(.cgaBlack)
                        .frame(width: 60, height: 40)
                        .background(Color.cgaLightGray)
                }
                .buttonStyle(.plain)

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text("N")
                        .font(titleFont)
                        .foregroundColor(.cgaBlack)
                        .frame(width: 60, height: 40)
                        .background(Color.cgaLightGray)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cgaBlack)
    }
}
