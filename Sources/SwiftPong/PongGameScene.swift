import SpriteKit
import SwiftUI

/// SpriteKit scene replicating the original 40×25 CGA text-mode Pong game.
///
/// Coordinate mapping: The original game uses a 40-column × 25-row text grid.
/// Row 1 = title, Row 2 = top border, Rows 3–23 = play area, Row 24 = bottom border, Row 25 = score.
/// Columns 1 and 40 are the paddle columns.
class PongGameScene: SKScene {

    // MARK: - Grid constants
    static let gridCols = 40
    static let gridRows = 25

    // MARK: - Game state reference
    var gameState: GameState!

    // MARK: - Nodes
    private var ballNode: SKShapeNode!
    private var paddle1Node: SKShapeNode!
    private var paddle2Node: SKShapeNode!
    private var score1Label: SKLabelNode!
    private var score2Label: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var topBorder: SKShapeNode!
    private var bottomBorder: SKShapeNode!

    // MARK: - Cell size (computed from scene size)
    private var cellWidth: CGFloat = 0
    private var cellHeight: CGFloat = 0

    // MARK: - Ball state (replicating Pascal variables)
    private var ballGridX: Int = 20  // 1..40
    private var ballGridY: Int = 12  // 2..24
    private var spalte: Int = 1      // dx: -1 or 1
    private var zeile: Int = 1       // dy: -1 or 1

    // MARK: - Paddle state
    private var paddlePos: [Int] = [10, 10]  // top row of each paddle (3..23-length)

    // MARK: - Timing
    private var tickInterval: TimeInterval = 0.05
    private var lastUpdateTime: TimeInterval = 0
    private var timeSinceLastTick: TimeInterval = 0

    // MARK: - Key tracking
    private var keysPressed: Set<String> = []

    // MARK: - Kickoff state
    private var waitingForKickoff = true

    // MARK: - Colors (NSColor for SpriteKit)
    private let cgaBlack     = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
    private let cgaLightRed  = NSColor(red: 1.0, green: 1.0/3, blue: 1.0/3, alpha: 1)
    private let cgaLightBlue = NSColor(red: 1.0/3, green: 1.0/3, blue: 1.0, alpha: 1)
    private let cgaYellow    = NSColor(red: 1.0, green: 1.0, blue: 1.0/3, alpha: 1)
    private let cgaWhite     = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    private let cgaLightGray = NSColor(red: 2.0/3, green: 2.0/3, blue: 2.0/3, alpha: 1)
    private let cgaMagenta   = NSColor(red: 2.0/3, green: 0, blue: 2.0/3, alpha: 1)

    // MARK: - Scene setup

    override func didMove(to view: SKView) {
        backgroundColor = cgaBlack
        cellWidth = size.width / CGFloat(Self.gridCols)
        cellHeight = size.height / CGFloat(Self.gridRows)

        // Speed: original is Delay((tempo+3)*4) ms per tick
        tickInterval = Double(gameState.tempo + 3) * 0.004

        // Initial paddle positions: (25 - length) / 2, matching Pascal integer division
        paddlePos[0] = (25 - gameState.paddleLength[0]) / 2
        paddlePos[1] = (25 - gameState.paddleLength[1]) / 2

        setupTitle()
        setupBorders()
        setupBall()
        setupPaddles()
        setupScoreLabels()
        updateScoreLabels()

        kickoff()
    }

    // MARK: - Grid ↔ Scene coordinate conversion

    /// Convert grid position (1-based col, 1-based row) to scene point (center of cell).
    /// Row 1 is at the top of the screen, row 25 at the bottom (matching CGA text mode).
    private func gridToScene(col: Int, row: Int) -> CGPoint {
        let x = (CGFloat(col) - 0.5) * cellWidth
        let y = size.height - (CGFloat(row) - 0.5) * cellHeight
        return CGPoint(x: x, y: y)
    }

    // MARK: - Setup methods

    private func setupTitle() {
        titleLabel = SKLabelNode(text: "P O N G !")
        titleLabel.fontName = "Menlo-Bold"
        titleLabel.fontSize = cellHeight * 0.8
        titleLabel.fontColor = cgaMagenta
        titleLabel.position = gridToScene(col: 20, row: 1)
        titleLabel.verticalAlignmentMode = .center
        addChild(titleLabel)
    }

    private func setupBorders() {
        let borderThickness = cellHeight * 0.15

        // Top border at row 2
        topBorder = SKShapeNode(rectOf: CGSize(width: size.width, height: borderThickness))
        topBorder.fillColor = cgaYellow
        topBorder.strokeColor = .clear
        topBorder.position = CGPoint(x: size.width / 2, y: gridToScene(col: 1, row: 2).y)
        addChild(topBorder)

        // Bottom border at row 24
        bottomBorder = SKShapeNode(rectOf: CGSize(width: size.width, height: borderThickness))
        bottomBorder.fillColor = cgaYellow
        bottomBorder.strokeColor = .clear
        bottomBorder.position = CGPoint(x: size.width / 2, y: gridToScene(col: 1, row: 24).y)
        addChild(bottomBorder)
    }

    private func setupBall() {
        let ballSize = min(cellWidth, cellHeight) * 0.7
        ballNode = SKShapeNode(rectOf: CGSize(width: ballSize, height: ballSize))
        ballNode.fillColor = cgaWhite
        ballNode.strokeColor = .clear
        ballNode.position = gridToScene(col: ballGridX, row: ballGridY)
        addChild(ballNode)
    }

    private func setupPaddles() {
        paddle1Node = createPaddleNode(playerIndex: 0)
        addChild(paddle1Node)

        paddle2Node = createPaddleNode(playerIndex: 1)
        addChild(paddle2Node)

        updatePaddleNode(playerIndex: 0)
        updatePaddleNode(playerIndex: 1)
    }

    private func createPaddleNode(playerIndex: Int) -> SKShapeNode {
        let node = SKShapeNode()
        node.fillColor = playerIndex == 0 ? cgaLightRed : cgaLightBlue
        node.strokeColor = .clear
        return node
    }

    private func updatePaddleNode(playerIndex: Int) {
        let node = playerIndex == 0 ? paddle1Node! : paddle2Node!
        let col = playerIndex == 0 ? 1 : Self.gridCols
        let length = gameState.paddleLength[playerIndex]
        let topRow = paddlePos[playerIndex]

        // Paddle spans from topRow to topRow+length-1
        let paddleHeight = cellHeight * CGFloat(length)
        let paddleWidth = cellWidth * 0.8

        let topPoint = gridToScene(col: col, row: topRow)
        let bottomPoint = gridToScene(col: col, row: topRow + length - 1)
        let centerY = (topPoint.y + bottomPoint.y) / 2

        let path = CGPath(
            rect: CGRect(x: -paddleWidth / 2, y: -paddleHeight / 2, width: paddleWidth, height: paddleHeight),
            transform: nil
        )
        node.path = path
        node.position = CGPoint(x: topPoint.x, y: centerY)
    }

    private func setupScoreLabels() {
        // Player 1 name + score (left side)
        let name1Label = SKLabelNode(text: gameState.playerName[0])
        name1Label.fontName = "Menlo"
        name1Label.fontSize = cellHeight * 0.7
        name1Label.fontColor = cgaLightRed
        name1Label.position = gridToScene(col: 6, row: 25)
        name1Label.verticalAlignmentMode = .center
        name1Label.horizontalAlignmentMode = .left
        addChild(name1Label)

        score1Label = SKLabelNode(text: "0")
        score1Label.fontName = "Menlo"
        score1Label.fontSize = cellHeight * 0.8
        score1Label.fontColor = cgaLightRed
        score1Label.position = gridToScene(col: 14, row: 25)
        score1Label.verticalAlignmentMode = .center
        addChild(score1Label)

        // Player 2 name + score (right side)
        let name2Label = SKLabelNode(text: gameState.playerName[1])
        name2Label.fontName = "Menlo"
        name2Label.fontSize = cellHeight * 0.7
        name2Label.fontColor = cgaLightBlue
        name2Label.position = gridToScene(col: 34, row: 25)
        name2Label.verticalAlignmentMode = .center
        name2Label.horizontalAlignmentMode = .right
        addChild(name2Label)

        score2Label = SKLabelNode(text: "0")
        score2Label.fontName = "Menlo"
        score2Label.fontSize = cellHeight * 0.8
        score2Label.fontColor = cgaLightBlue
        score2Label.position = gridToScene(col: 26, row: 25)
        score2Label.verticalAlignmentMode = .center
        addChild(score2Label)
    }

    private func updateScoreLabels() {
        score1Label.text = "\(gameState.scores[0])"
        score2Label.text = "\(gameState.scores[1])"
    }

    // MARK: - Kickoff

    private func kickoff() {
        // Original: X := Random(8)+17 → 17..24, Y := Random(16)+5 → 5..20
        ballGridX = Int.random(in: 17...24)
        ballGridY = Int.random(in: 5...20)

        // Random initial direction
        spalte = Bool.random() ? 1 : -1
        zeile = Bool.random() ? 1 : -1

        ballNode.position = gridToScene(col: ballGridX, row: ballGridY)
        ballNode.isHidden = false

        waitingForKickoff = true
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval
        if lastUpdateTime == 0 {
            dt = 0
        } else {
            dt = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime
        timeSinceLastTick += dt

        guard timeSinceLastTick >= tickInterval else { return }
        timeSinceLastTick = 0

        processPaddleInput()

        if waitingForKickoff {
            // In original, kickoff waits for space bar
            if keysPressed.contains(" ") {
                waitingForKickoff = false
                keysPressed.remove(" ")
            }
            return
        }

        moveBall()
    }

    private func processPaddleInput() {
        // Q = Player 1 up, A = Player 1 down
        if keysPressed.contains("q") && paddlePos[0] > 3 {
            paddlePos[0] -= 1
            updatePaddleNode(playerIndex: 0)
        }
        if keysPressed.contains("a") && paddlePos[0] + gameState.paddleLength[0] < 24 {
            paddlePos[0] += 1
            updatePaddleNode(playerIndex: 0)
        }
        // P = Player 2 up, L = Player 2 down
        if keysPressed.contains("p") && paddlePos[1] > 3 {
            paddlePos[1] -= 1
            updatePaddleNode(playerIndex: 1)
        }
        if keysPressed.contains("l") && paddlePos[1] + gameState.paddleLength[1] < 24 {
            paddlePos[1] += 1
            updatePaddleNode(playerIndex: 1)
        }
    }

    private func moveBall() {
        // Surprise: 1/80 chance to flip dy
        if Int.random(in: 0..<80) == 0 {
            zeile = -zeile
            SoundManager.shared.surprise(enabled: gameState.soundEnabled)
        }

        // Wall bounce: check if next Y would hit border
        if ballGridY + zeile == 24 || ballGridY + zeile == 2 {
            SoundManager.shared.wall(enabled: gameState.soundEnabled)
            zeile = -zeile
        }

        // Move ball
        ballGridX += spalte
        ballGridY += zeile
        ballNode.position = gridToScene(col: ballGridX, row: ballGridY)

        // Check paddle 2 (right side): if next step would reach column 40
        if ballGridX + spalte == 40 {
            if ballGridY <= paddlePos[1] + gameState.paddleLength[1] &&
               ballGridY >= paddlePos[1] - 1 {
                SoundManager.shared.paddle(enabled: gameState.soundEnabled)
                spalte = -1
            } else {
                // Player 1 scores
                SoundManager.shared.miss(enabled: gameState.soundEnabled)
                gameState.scores[0] += 1
                updateScoreLabels()
                if checkWin() { return }
                kickoff()
                return
            }
        }

        // Check paddle 1 (left side): if next step would reach column 1
        if ballGridX + spalte == 1 {
            if ballGridY <= paddlePos[0] + gameState.paddleLength[0] &&
               ballGridY >= paddlePos[0] - 1 {
                SoundManager.shared.paddle(enabled: gameState.soundEnabled)
                spalte = 1
            } else {
                // Player 2 scores
                SoundManager.shared.miss(enabled: gameState.soundEnabled)
                gameState.scores[1] += 1
                updateScoreLabels()
                if checkWin() { return }
                kickoff()
                return
            }
        }
    }

    private func checkWin() -> Bool {
        if gameState.scores[0] >= gameState.maxPoints {
            gameState.winner = 0
            gameState.phase = .ended
            return true
        }
        if gameState.scores[1] >= gameState.maxPoints {
            gameState.winner = 1
            gameState.phase = .ended
            return true
        }
        return false
    }

    // MARK: - Keyboard input

    override func keyDown(with event: NSEvent) {
        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return }
        keysPressed.insert(chars)
    }

    override func keyUp(with event: NSEvent) {
        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return }
        keysPressed.remove(chars)
    }
}
