# Director Knowledge Maps — Examples & Event Notes

Concise examples of what feeds each map and how they are intended to be used by the director/squads. This is reference only (not exhaustive).

## Heat Map — “What just happened”
- Combat: shots fired, explosions, damage events, deaths (player or AI), turret firing bursts.
- Logistics: hauler pickups/drops, sabotaged conveyors, depot usage spikes.
- Movement: player or squad sprinting, door openings, rapid pathing through chokepoints.
- Construction/repair: turrets built/sold, barricades placed/removed, repairs performed.
- Environment: alarms tripped, cameras spotting, traps triggered.
- Behavior: immediate/local; recency-weighted decay; no spatial propagation.

## Belief Map — “Where we think things might be”
- Last-known player position: seed belief that diffuses along reachable navmesh; boosted by new noises/footsteps/suppressed fire.
- Lost contact: when scouts lose LOS, spawn a belief cone ahead of last facing or along likely escape routes.
- Intel updates: sensor pings, hacked consoles, captured drones sending coarse position; add soft probability in a region.
- Deception/noise-makers: false positives with lower confidence and faster decay.
- Patrol priors: baseline belief along high-traffic corridors to keep coverage even without sightings.
- Behavior: probabilistic, diffuses and decays; confidence drops on negative scans.

## Influence Map — “Who controls/pressures space”
- Faction control: friendly turrets, squads holding positions, active patrol paths add positive influence; player-owned structures add opposing influence.
- Threat projection: turret arcs, sniper lanes, artillery min/max ranges stamped as gradients.
- Vulnerability/pressure: damaged hubs, exposed logistics links, power relays reduce friendly influence; repeated player hits invert influence locally.
- Mobility/denial: mined tiles, slowing fields, locked doors increase friendly influence; breaches/blown doors reduce it and raise opposing influence.
- Conflict fronts: overlap of opposing influence marks contested zones for surge/defend tasking.
- Behavior: aggregated fields from units/structures/terrain; recomputed periodically; used for control/contest assessment.

## Interplay Ideas (director usage)
- Send scouts to high-belief regions that have low friendly influence (likely player, weak control).
- Pressure tasks toward high-heat but low-friendly-influence areas (player just struck where we’re thin).
- Fortify hubs where friendly influence is eroding and recent heat is rising.
- Patrol routes seeded along decayed belief trails to re-acquire the player.
