# TDRPG Context (Design + Vocabulary)

This document exists so coding agents can make changes that stay aligned with the game’s intent.

## One-paragraph pitch
TDRPG is a space-themed tower-defense roguelike with logistics automation and RTS-lite squad control.
You are a lone survivor (Custodian-style role) waking on a massive generation ship. Threats include
mutants and berserk automatons. You explore, loot, build/upgrade, automate, and expand—while the ship
fights back.

## Core loop (high level)
Explore → loot → return → build/automate/upgrade → repeat.

Notes:
- Travel is freeform (not “wave-based” by default).
- Towers can be placed broadly and may be destructible; defense is about resilient systems, not indestructible walls.

## Pillars / invariants
- Multiple bases/hubs: defenses are distributed; raids can happen anywhere.
- Logistics matters: ammo, power, repairs, and information can be constrained by networks.
- Intel matters: fog of war is expected; towers may operate autonomously with limited feedback.
- Runs should teach: failure should reveal why your system failed (insufficient coverage, wrong damage type, missing supply),
  not feel like random punishment.

## Enemy/encounter philosophy
- Enemies have archetypes and tags (swarm, tanky, regen, etc.). Both hero and towers can specialize.
- Enemies can breach/attack doors, flank routes, and may open new pathways if chokepointed.

## World structure
- Ship is procedurally generated with stages/sectors.
- Rooms/cells are hidden until opened (fog of war). Player may leave some areas unknown.
- Boss/endgame concepts can involve door breaking, system control, room hazards, or stealth pathing.

## Vocabulary (use consistently)
- Squad: a group of combatants that move together under a directive.
- Directive: the current high-level intent for a squad (move/hold/patrol/retreat/etc.).
- Anchor: the squad’s “center” reference position used for cohesion and slotting.
- Hauler: an automaton focused on logistics tasks (transporting resources, servicing bases, etc.).
- Hub/Base: a defensible location with expanded capabilities; never perfectly safe.

## Locomotion Layers (AI movement model)
- Policy (intent / why + what): chooses the objective and constraints (move, hold, patrol, return to formation, retreat to tether, etc.), emitting an intention plus parameters like urgency, formation mode, and tolerances—without picking each agent’s final point.
- Target (targeting / where): resolves the policy intent into concrete goals such as squad anchors, patrol points, and especially per-combatant slot targets or reassignment rules. This layer decides “what exact point should this agent aim for right now?” and prevents clumping by keeping goals unique.
- Execution (how / per-tick motion): turns the target into continuous movement: path following via NavigationAgent2D, repath/slowdown gating, steering and avoidance, unsticking (shear, micro-detours, separation), and outputs direction/speed to the motor while coping with local collisions and congestion.

## “Do not break these by accident”
- Godot metadata stability: avoid rewriting .tscn/.tres formatting and UIDs unless you are migrating.
- Maintain separation: runtime simulation logic should not depend directly on debug UI/draw code.
- Prefer explicit seams: subsystems should expose stable interfaces that other systems call through.
