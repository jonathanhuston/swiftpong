import SwiftUI

// MARK: - Common CGA-styled components

private let monoFont = Font.system(size: 16, design: .monospaced)
private let titleFont = Font.system(size: 20, weight: .bold, design: .monospaced)

private struct CGABackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cgaBlack)
    }
}

private struct CGATitle: View {
    var body: some View {
        Text("P O N G !")
            .font(titleFont)
            .foregroundColor(.cgaMagenta)
            .padding(.top, 20)
    }
}

// MARK: - Player Names

struct PlayerNamesView: View {
    @ObservedObject var state: GameState
    @State private var name1 = ""
    @State private var name2 = ""
    @State private var showError = false
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack(spacing: 20) {
            CGATitle()
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("Player 1, what is your name?")
                    .font(monoFont)
                    .foregroundColor(.cgaLightRed)
                TextField("", text: $name1)
                    .font(monoFont)
                    .foregroundColor(.cgaLightRed)
                    .textFieldStyle(.plain)
                    .padding(6)
                    .background(Color.cgaBlack)
                    .overlay(Rectangle().stroke(Color.cgaLightRed, lineWidth: 1))
                    .focused($focusedField, equals: 1)
                    .onChange(of: name1) { _, newValue in
                        // Strip spaces and limit to 15 chars
                        let filtered = String(newValue.replacingOccurrences(of: " ", with: "").prefix(15))
                        if filtered != newValue { name1 = filtered }
                    }
            }
            .padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: 16) {
                Text("Player 2, what is your name?")
                    .font(monoFont)
                    .foregroundColor(.cgaLightBlue)
                TextField("", text: $name2)
                    .font(monoFont)
                    .foregroundColor(.cgaLightBlue)
                    .textFieldStyle(.plain)
                    .padding(6)
                    .background(Color.cgaBlack)
                    .overlay(Rectangle().stroke(Color.cgaLightBlue, lineWidth: 1))
                    .focused($focusedField, equals: 2)
                    .onChange(of: name2) { _, newValue in
                        let filtered = String(newValue.replacingOccurrences(of: " ", with: "").prefix(15))
                        if filtered != newValue { name2 = filtered }
                    }
            }
            .padding(.horizontal, 40)

            if showError {
                Text("Names must be different and non-empty!")
                    .font(monoFont)
                    .foregroundColor(.cgaYellow)
            }

            Spacer()

            Button(action: submit) {
                Text("Continue")
                    .font(monoFont)
                    .foregroundColor(.cgaBlack)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.cgaLightGray)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 30)
        }
        .modifier(CGABackground())
        .onAppear { focusedField = 1 }
    }

    private func submit() {
        let n1 = name1.trimmingCharacters(in: .whitespaces)
        let n2 = name2.trimmingCharacters(in: .whitespaces)
        guard !n1.isEmpty, !n2.isEmpty, n1 != n2 else {
            showError = true
            return
        }
        state.playerName = [n1, n2]
        state.advanceSetup()
    }
}

// MARK: - Sound Toggle

struct SoundToggleView: View {
    @ObservedObject var state: GameState

    var body: some View {
        VStack(spacing: 20) {
            CGATitle()
            Spacer()

            Text("Sound? Y/N")
                .font(titleFont)
                .foregroundColor(.cgaLightGray)

            HStack(spacing: 30) {
                Button(action: { state.soundEnabled = true; state.advanceSetup() }) {
                    Text("Y")
                        .font(titleFont)
                        .foregroundColor(.cgaBlack)
                        .frame(width: 60, height: 40)
                        .background(Color.cgaLightGray)
                }
                .buttonStyle(.plain)

                Button(action: { state.soundEnabled = false; state.advanceSetup() }) {
                    Text("N")
                        .font(titleFont)
                        .foregroundColor(.cgaBlack)
                        .frame(width: 60, height: 40)
                        .background(Color.cgaLightGray)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .modifier(CGABackground())
    }
}

// MARK: - Max Points

struct MaxPointsView: View {
    @ObservedObject var state: GameState
    @State private var points: Int = 21

    var body: some View {
        VStack(spacing: 20) {
            CGATitle()
            Spacer()

            Text("Maximum points")
                .font(monoFont)
                .foregroundColor(.cgaLightGray)

            HStack(spacing: 16) {
                Button(action: { if points > 1 { points -= 1 } }) {
                    Text("<")
                        .font(titleFont)
                        .foregroundColor(.cgaLightGray)
                        .frame(width: 40, height: 40)
                        .overlay(Rectangle().stroke(Color.cgaLightGray, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Text("\(points)")
                    .font(titleFont)
                    .foregroundColor(.cgaWhite)
                    .frame(width: 60)

                Button(action: { if points < 100 { points += 1 } }) {
                    Text(">")
                        .font(titleFont)
                        .foregroundColor(.cgaLightGray)
                        .frame(width: 40, height: 40)
                        .overlay(Rectangle().stroke(Color.cgaLightGray, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button(action: { state.maxPoints = points; state.advanceSetup() }) {
                Text("Continue")
                    .font(monoFont)
                    .foregroundColor(.cgaBlack)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.cgaLightGray)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 30)
        }
        .modifier(CGABackground())
    }
}

// MARK: - Paddle Length

struct PaddleLengthView: View {
    @ObservedObject var state: GameState
    @State private var length1: Int = 6
    @State private var length2: Int = 6

    var body: some View {
        VStack(spacing: 20) {
            CGATitle()
            Spacer()

            ForEach(0..<2, id: \.self) { idx in
                let color = state.playerColor[idx]
                VStack(spacing: 8) {
                    Text("Paddle length for \(state.playerName[idx])")
                        .font(monoFont)
                        .foregroundColor(.cgaLightGray)

                    HStack(spacing: 16) {
                        Button(action: { adjustLength(idx, delta: -1) }) {
                            Text("<")
                                .font(titleFont)
                                .foregroundColor(color)
                                .frame(width: 36, height: 36)
                                .overlay(Rectangle().stroke(color, lineWidth: 1))
                        }
                        .buttonStyle(.plain)

                        // Visual paddle preview
                        HStack(spacing: 1) {
                            ForEach(0..<currentLength(idx), id: \.self) { _ in
                                Rectangle()
                                    .fill(color)
                                    .frame(width: 14, height: 20)
                            }
                        }
                        .frame(width: 180, alignment: .leading)

                        Button(action: { adjustLength(idx, delta: 1) }) {
                            Text(">")
                                .font(titleFont)
                                .foregroundColor(color)
                                .frame(width: 36, height: 36)
                                .overlay(Rectangle().stroke(color, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }

            Spacer()

            Button(action: {
                state.paddleLength = [length1, length2]
                state.advanceSetup()
            }) {
                Text("Continue")
                    .font(monoFont)
                    .foregroundColor(.cgaBlack)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.cgaLightGray)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 30)
        }
        .modifier(CGABackground())
    }

    private func currentLength(_ idx: Int) -> Int {
        idx == 0 ? length1 : length2
    }

    private func adjustLength(_ idx: Int, delta: Int) {
        if idx == 0 {
            length1 = max(1, min(12, length1 + delta))
        } else {
            length2 = max(1, min(12, length2 + delta))
        }
    }
}

// MARK: - Ball Speed

struct BallSpeedView: View {
    @ObservedObject var state: GameState
    @State private var tempo: Int = 10
    @State private var ballX: CGFloat = 0
    @State private var ballDirection: CGFloat = 1

    var body: some View {
        VStack(spacing: 20) {
            CGATitle()
            Spacer()

            Text("Ball speed")
                .font(monoFont)
                .foregroundColor(.cgaLightGray)

            // Speed preview area
            ZStack {
                Rectangle()
                    .fill(Color.cgaBlack)
                    .frame(height: 40)
                    .overlay(Rectangle().stroke(Color.cgaYellow, lineWidth: 1))

                Circle()
                    .fill(Color.cgaWhite)
                    .frame(width: 12, height: 12)
                    .offset(x: ballX)
            }
            .frame(width: 320, height: 40)
            .onAppear { startBallAnimation() }

            HStack(spacing: 16) {
                Button(action: { if tempo < 25 { tempo += 1; restartBall() } }) {
                    Text("Slower")
                        .font(monoFont)
                        .foregroundColor(.cgaLightGray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(Rectangle().stroke(Color.cgaLightGray, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Text("Speed: \(25 - tempo)")
                    .font(monoFont)
                    .foregroundColor(.cgaWhite)
                    .frame(width: 120)

                Button(action: { if tempo > 0 { tempo -= 1; restartBall() } }) {
                    Text("Faster")
                        .font(monoFont)
                        .foregroundColor(.cgaLightGray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(Rectangle().stroke(Color.cgaLightGray, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button(action: { state.tempo = tempo; state.advanceSetup() }) {
                Text("Start Game!")
                    .font(titleFont)
                    .foregroundColor(.cgaBlack)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.cgaLightGray)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 30)
        }
        .modifier(CGABackground())
    }

    private func startBallAnimation() {
        animateBall()
    }

    private func restartBall() {
        ballX = 0
        ballDirection = 1
    }

    private func animateBall() {
        let stepDuration = Double(tempo + 3) * 0.004
        let totalWidth: CGFloat = 300
        let step: CGFloat = 8

        withAnimation(.linear(duration: stepDuration)) {
            ballX += step * ballDirection
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
            if abs(ballX) >= totalWidth / 2 {
                ballDirection = -ballDirection
                SoundManager.shared.wall(enabled: state.soundEnabled)
            }
            animateBall()
        }
    }
}
