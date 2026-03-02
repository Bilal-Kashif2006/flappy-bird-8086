# Flappy Bird 8086

A Flappy Bird clone written in 8086 Assembly for DOS text mode.

## Overview

This project recreates Flappy Bird mechanics in low-level x86 Assembly:

- Real-time bird movement and gravity
- Procedurally cycling pillars with gaps
- Collision detection (pipes + ground)
- Score tracking and end screen
- Start, instructions, pause, and game-over UI
- Keyboard and timer interrupt handling
- PC speaker music task running alongside gameplay

## Controls

- `Enter` - Start from title screen
- `Any key` - Continue from instructions screen
- `Up Arrow` - Flap / move bird up
- `Esc` - Pause game
- `n` - Resume from pause
- `y` - Quit from pause

## Project Files

- `phas5.asm` - Main game source (entry point)
- `phas5vsync.asm` - Flicker-free variant with vertical retrace sync
- `UI_5.asm` - Start/instructions/pause/game-over UI routines
- `mus.asm` - Music routine
- `prng_1.asm` - Random number generation helper
- `phas5.com` - Prebuilt DOS executable
- `phas5vsync.com` - Prebuilt flicker-free executable
- `dosbox.conf` - DOSBox auto-run config for `phas5.com`
- `dosboxvsync.conf` - DOSBox auto-run config for `phas5vsync.com`

## Build

Requirements:

- `nasm` (verified with NASM 3.01)

Build command:

```bash
nasm -f bin phas5.asm -o phas5.com
```

## Run

### Option 1: Run prebuilt binary with DOSBox config

```bash
dosbox -conf dosbox.conf
```

### Option 2: Manual DOSBox run

1. Start DOSBox.
2. Mount this project folder as a DOS drive:
   `mount c "<path-to-this-project>"`
3. Run:
   `c:`
   `phas5.com`

## Credits

- Bilal Kashif (`23L-0757`)
- Mohammad Hamza Iqbal (`23L-0848`)
