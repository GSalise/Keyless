# Keyless: Game Design Document
 
**Game Name:** Keyless  
**Company Name:** CHIP GAMES STUDIOS  
**Team Name:** CHIP

## Team Members and Roles

| Member                             | Roles                                       |
| :--------------------------------- | :------------------------------------------ |
| **Colon, Ezekiel Angelo**          | Audio & UI / Tester and Game/Level Designer |
| **Refugio, Zechariah Jose**        | Programmer and Artist & Animator            |
| **Salise, George Adriane Dean P.** | Lead Programmer                             |

---

## Game Overview and Concept

### Summary

In Keyless, you play as a wrongfully imprisoned inmate trapped inside a high-security prison designed to be impossible to escape. Using stealth, strategy, and quick thinking, you must outmaneuver guards, solve intricate puzzles, and uncover a path to freedom before the system closes in on you, all the while fighting off rival gangs when things go loud.

- **Genre:** 2D Stealth & Puzzle
- **Target Audience:** Ages 6+, Casual
- **Unique Selling Point (USP):** A prison escape game that seamlessly shifts between stealth and combat when things go wrong.
- **Core Theme / Mood / Art Style:** A gritty prison setting in 2D pixel art style.
- **High-level Story / Setting:** A wrongfully imprisoned inmate trying to escape the prison to prove his innocence. While it does sound counterintuitive, the inmate has a plan which will be revealed in the ending.

## Core Gameplay and Mechanics

### Core Loop

The player starts in a prison cell, escapes, and navigates corridors using stealth while avoiding guards (as getting caught results in game over). Players encounter rival gangs that must be fought if engaged, search for keys, tools, or clues, and solve puzzles to unlock new paths, ultimately finding the exit to progress to the next area.

### Key Mechanics

- **Interactable environment:** Objects the player can engage with to progress.
- **Line of Sight:** NPCs have a visible line of vision integral to stealth gameplay.
- **Combat:** Mini battles with hostile gangs.
- **Puzzles:** Logic-based obstacles required for progression.

### Controls Summary

- **Movement:** WASD or Arrow Keys
- **Punch:** Right Mouse Click

### Win/Lose Conditions

- **Win Condition:** Exit the prison before time runs out.
- **Lose Conditions:** Getting caught by guards or being defeated by hostile gangs.

## Scope and Feasibility

### Core Features

- Player controller with 4-directional movement.
- Stealth system (detection and line-of-sight awareness).
- Combat system (basic fighting mechanics).
- Puzzle interactions (keys, tools, switches).
- 3 hand-crafted levels with progression.
- Basic enemy AI behaviors.
- UI/HUD (health, pause menu).
- Sound effects and background music.
- Export to PC.

### Stretch Goals

- Boss Fight.
- Mobile Export.

### Risks and Mitigation

- **AI Complexity:** Use simple state-based AI (patrol, chase, attack) instead of advanced pathfinding. Fallback to fixed patrol routes if needed.
- **Project Scope:** Prioritize core gameplay (movement, stealth, win/lose) first; reduce level complexity if behind schedule.
- **Combat Balancing:** Keep combat simple (basic attack + health). If implementation is difficult, focus more heavily on stealth.
- **Deadline Bugs:** Allocate Weeks 9–10 for testing and keep code modular.

## Phased Timeline

- **Week 1:** Player movement and basic scene prototype.
- **Weeks 2–4:** Level design, basic UI, and enemy integration.
- **Weeks 5–6:** Art, audio, and UI polish.
- **Week 7:** Playtesting, bug fixing, and optimization.
- **Final Week:** Trailer, builds, and documentation.

## Technical and Godot Plan

### Key Godot Features

- **Nodes/Scenes:** `CharacterBody2D` for entities, `TileMap` for levels, `CollisionShape2D` for physics, `AnimatedSprite2D` for visuals, and `CanvasLayer` for UI.
- **Signals & Scripts:** Custom signals for events (detection, damage). Enemy AI using state machines. `Area2D` for vision cones.
- **Other:** `AudioStreamPlayer2D` for sound; `NavigationAgent2D` (optional) for pathfinding.

### Object-Oriented Approach

- **Base Entity Class:** Handles movement, health, and basic behavior.
- **Inheritance:** Player and enemies inherit from the Entity class.
- **Modular Scripts:** Separate logic for player controls, enemy behavior, and game management (win/lose conditions, level transitions).

## Art, Audio, and UI Strategy

- **Art Style:** Pixel 2D assets gathered from itch.io, craftpix.net, or designed in-house.
- **Audio Plan:** Sound assets gathered from freesound.org or itch.io.
- **UI/HUD:** Features include a health bar, main menu, and pause menu.

## Ethical and Social Responsibility

### Accessibility

- Simple and intuitive controls.
- Visual indicators for stealth (vision cones and alerts).
- High contrast between entities and the environment.
- Minimal reliance on audio cues for gameplay.

### Societal Impact

- Encourages problem-solving and strategic thinking.
- Promotes themes of justice and perseverance.
- Avoids glorifying violence by framing combat as a tool for survival.
