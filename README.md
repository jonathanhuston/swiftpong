# SwiftPong

A faithful macOS port of [PONG!](https://github.com/jonathanhuston/pong), originally written in Turbo Pascal 3 and published in *Pascal International*, February 1988.

SwiftPong recreates the original game's CGA-era aesthetics and gameplay mechanics using modern Swift, SwiftUI, and SpriteKit — right down to the 40x25 text grid, the color palette, and the 1-in-80 chance "surprise" direction change.

## Requirements

- macOS 14.0+
- Swift 5.10+

## Building

**Run from source:**

```sh
swift run
```

**Build a standalone .app bundle:**

```sh
./build-app.sh
```

This creates `SwiftPong.app` in the project directory.

## How to Play

SwiftPong is a two-player game. After launching, you'll configure the match through a series of setup screens:

1. **Player names** — enter names for each player (1-15 characters)
2. **Sound** — toggle sound effects on or off
3. **Max points** — set the score needed to win (1-100)
4. **Paddle length** — each player chooses their paddle size (1-12)
5. **Ball speed** — set the tempo (0 = fastest, 25 = slowest)

### Controls

| Action         | Player 1 (left) | Player 2 (right) |
|----------------|------------------|-------------------|
| Move up        | Q                | P                 |
| Move down      | A                | L                 |
| Serve ball     | Space            | Space             |

Press **Space** to serve at the start of each round. First player to reach the point target wins.

## History

The original PONG! was written in Turbo Pascal 3 targeting DOS with CGA graphics. SwiftPong preserves the original game logic — including the ball physics, paddle collision, scoring, and the random "surprise" direction flip — while replacing the DOS text-mode rendering with a SpriteKit scene that emulates the same 640x400, 40x25 character grid and CGA color palette.
