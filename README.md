# Flappy Bird 8086

A text-mode Flappy Bird clone written in **8086 Assembly** for DOS `.COM` binaries.

The game runs in `80x25` text mode by drawing directly to VGA text memory (`0xB800`) and uses hardware interrupts for responsive input and timing.

## Features

- Classic Flappy Bird gameplay: flap, gravity, moving pillars, collision, score
- Text-mode rendering with direct writes to video memory
- Custom keyboard ISR hook (`INT 09h`) for controls
- Custom timer ISR hook (`INT 08h`) for motion/tick updates
- In-game UI screens: start, instructions, pause, game over
- PC speaker music routine integrated with gameplay
- Two playable builds:
  - `phas5.com` (base build)
  - `phas5vsync.com` (vertical-retrace synced, less flicker)

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
nasm -f bin phas5.asm -o phas5.com
nasm -f bin phas5vsync.asm -o phas5vsync.com
```

## Run

### Option 1: Use included DOSBox configs

Base build:

```bash
dosbox -conf dosbox.conf
```

VSync build:

```bash
dosbox -conf dosboxvsync.conf
```

### Option 2: Run manually in DOSBox

```text
mount c "<project-path>"
c:
phas5.com
```

For the synced build, run `phas5vsync.com` instead.

## Project Structure

- `phas5.asm` - Main game source (base)
- `phas5vsync.asm` - Main game source with vertical retrace sync (`wait_vsync`)
- `UI_5.asm` - UI buffers and routines (start, instructions, pause, end)
- `mus.asm` - Music routine
- `prng_1.asm` - Randomization helper for gameplay elements
- `dosbox.conf` - DOSBox autoexec for `phas5.com`
- `dosboxvsync.conf` - DOSBox autoexec for `phas5vsync.com`
- `phas5.com` - Prebuilt base executable
- `phas5vsync.com` - Prebuilt synced executable

## Technical Overview

- Program format: `.COM` (`[org 0x0100]`)
- Rendering target: VGA text memory segment `0xB800`
- Runtime behavior:
  - Saves existing keyboard/timer vectors
  - Hooks custom ISRs for gameplay
  - Restores original vectors on exit
- Core game systems:
  - Bird movement and flap timing
  - Pillar scrolling and randomized gaps
  - Collision detection against obstacles/ground
  - Score increment + on-screen score rendering

## Notes

- Designed for DOS/DOSBox only
- Text-mode visuals are intentionally character-cell based
- Timing and feel can vary slightly with emulator settings

## Authors

- Bilal Kashif (`23L-0757`)
- Mohammad Hamza Iqbal (`23L-0848`)
