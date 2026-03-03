# Flappy Bird 8086

A text-mode Flappy Bird clone written in **8086 Assembly** for DOS `.COM` binaries.

The game runs in `80x25` text mode by writing directly to VGA text memory (`0xB800`) and uses hardware interrupts for responsive input and timing.

## Features

- Classic Flappy Bird gameplay: flap, gravity, moving pillars, collision, and scoring
- Text-mode rendering with direct video memory access
- Custom keyboard ISR hook (`INT 09h`) for controls
- Custom timer ISR hook (`INT 08h`) for game ticks
- In-game UI screens: start, instructions, pause, and game over
- PC speaker music integrated with gameplay
- Two playable variants (base and VSync)

## Game Variants

This repository includes two executable variants:

- `build/flappy.com` (`src/flappy_base.asm`): standard base version
- `build/pvsync.com` (`src/flappy_vsync.asm`): vertical-retrace synchronized version for reduced flicker

## Controls

- `Enter` - Start game from title screen
- `Any key` - Continue after instructions screen
- `Up Arrow` - Flap
- `Esc` - Pause
- `n` - Resume from pause
- `y` - Quit from pause

## Requirements

- [NASM](https://www.nasm.us/)
- [DOSBox](https://www.dosbox.com/)

## Build

From the project root:

```bash
nasm -f bin src/flappy_base.asm -o build/flappy.com
nasm -f bin src/flappy_vsync.asm -o build/pvsync.com
```

## Run

### Run Variant 1: Base Build (`flappy.com`)

Using provided DOSBox config:

```bash
dosbox -conf config/dosbox.base.conf
```

Manual DOSBox launch:

```text
mount c "<project-path>"
c:
cd build
flappy.com
```

### Run Variant 2: VSync Build (`pvsync.com`)

Using provided DOSBox config:

```bash
dosbox -conf config/dosbox.vsync.conf
```

Manual DOSBox launch:

```text
mount c "<project-path>"
c:
cd build
pvsync.com
```

## Music Attribution

- In-game tune: **"Houdini" (8-bit arrangement)** by **Dua Lipa**
- Original song: *Houdini* (single, 2023), from the album *Radical Optimism* (2024)
- Local asset in this repository: `assets/Houdini.wav`

## Project Structure

- `src/flappy_base.asm` - Main game source (base variant)
- `src/flappy_vsync.asm` - Main game source with vertical retrace sync (`wait_vsync`)
- `src/ui.asm` - UI buffers and routines (start, instructions, pause, game over)
- `src/music.asm` - Music routine
- `src/prng.asm` - Randomization helper for gameplay elements
- `config/dosbox.base.conf` - DOSBox autoexec config for base variant
- `config/dosbox.vsync.conf` - DOSBox autoexec config for VSync variant
- `build/flappy.com` - Built base executable
- `build/pvsync.com` - Built VSync executable
- `assets/Houdini.wav` - Audio asset

## Technical Overview

- Program format: `.COM` (`[org 0x0100]`)
- Rendering target: VGA text memory segment `0xB800`
- Runtime behavior:
  - Saves existing keyboard and timer vectors
  - Hooks custom ISRs for gameplay
  - Restores original vectors on exit
- Core game systems:
  - Bird movement and flap timing
  - Pillar scrolling and randomized gaps
  - Collision detection against obstacles and ground
  - Score increment and on-screen score rendering

## Notes

- Designed for DOS/DOSBox environments
- Text-mode visuals are intentionally character-cell based
- Timing and feel can vary slightly depending on emulator settings

## Authors

- Bilal Kashif (`23L-0757`)
- Mohammad Hamza Iqbal (`23L-0848`)
