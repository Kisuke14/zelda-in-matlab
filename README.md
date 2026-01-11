# Recreating The Legend of Zelda (NES) in MATLAB

This project is a fan-made recreation of the original *The Legend of Zelda* (NES, 1986) implemented in MATLAB.

It aims to reproduce the core gameplay mechanics of the original game, such as player movement, enemy behavior, map transitions, and basic combat, while exploring the possibilities of real-time game development using MATLAB.

This is an ongoing project and **not yet a full remake** of the original game.

---

## Features

- NES-style top-down 2D gameplay
- Tile-based map system
- Player movement and collision detection
- Sword attack system
- Area transitions and cave entry/exit
- Enemy spawning and basic interaction
- Damage display for both player and enemies
- MATLAB-based rendering and game loop
- Keyboard control
- Optional Joy-Con support (via HID API)

---

## Screenshots / Demo

(Add screenshots or GIFs here)

Example:

![Gameplay Demo](images/demo.gif)

---

## Environment

Tested on:

- Windows 11
- MATLAB R2024b
- Surface Pro 8

---

## How to Run

1. Clone this repository:

```bash
git clone https://github.com/your-username/zelda-in-matlab.git
```

2. Open MATLAB.
3. Navigate to the project folder.
4. Run the main script:

---

## Controls

### Keyboard
- W / A / S / D — Move
- Mouse click — Attack

### Controller (Optional)
- Joy-Con supported via HID API (if connected and configured)

---

## Project Structure

```
zelda-in-matlab/
├── ClassDef/              # Class definitions
│   ├── matlab-hidapi-master
│   ├── UI.m
│   ├── HUD.m
│   ├── Field.m
│   ├── PlayerCharacter.m
│   ├── Enemy.m
│   ├── NonPlayerCharacter.m
│   ├── JoyController.m
│   ├── mapPolygon.xlsx
│   ├── cavePolygon.xlsx
│   └── posEnemy.xlsx
├── Images/               # Sprite images and assets
├── main.m                # Entry point
├── getPlayerOperation.m  # Input handling
└── README.md
```

---

## Assets and Credits

Some of the sprite images used in this project were sourced from The Spriters Resource:

https://www.spriters-resource.com/nes/legendofzelda/

All rights to these assets belong to their respective owners.

---

## Disclaimer

This is a fan-made, non-commercial project and is not affiliated with or endorsed by Nintendo.
All trademarks and copyrights belong to their respective owners.

---

## Motivation

This project was created as a technical and educational challenge to explore:
- Game development using MATLAB
- Real-time rendering and game loops
- Object-oriented design in MATLAB
- Reproducing classic NES game mechanics

---

## Limitations / ToDo

The following features are not implemented yet:
- Shield usage
- Sword beams
- Items other than sword
- Dungeon mechanics
- Boss enemies
- Title screen
- Pause menu

---

## Future Work

- Sound effects and background music
- More enemy types
- Additional areas
- Inventory system
- Save / load functionality

---

## License

This project is released for educational purposes only.
Please check individual asset licenses before redistributing.
