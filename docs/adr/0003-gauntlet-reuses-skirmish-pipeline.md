# The Gauntlet is a seeded ladder of ordinary skirmishes plus a perk layer

The Gauntlet (roguelike run mode) is not a new battle system: each rung is a plain skirmish
def produced by the existing `buildSkirmishDef` pipeline under `RULE_DEFAULT`, with a per-rung
difficulty budget choosing the arguments (foe count, foe difficulty, map type), and the Finale
reusing the campaign's `foesOwn` grid setup (two entrenched hard foes). The only genuinely new
machinery is the perk layer: drafted, run-long modifiers applied to the player's team on top of
`STAT` — a mixed pool of stackable stat multipliers (slotting in exactly like `S.rules`
multipliers) and a few unique rule-benders hooking already-isolated seams (defection, Stim,
capture rate, starting minerals). Upgrades and minerals still reset every battle, so all
existing per-battle tuning holds untouched. This is the third instance of the "new mode reuses
an existing pipeline" pattern (ADR-0001: Grid reuses pads; ADR-0002: Horde reuses teams).

Rejected alternatives worth remembering: an endless escalating ladder (duplicates Endless's
identity — Endless is unwinnable survival, a Run is a winnable gauntlet); carrying upgrade
levels or surviving armies between battles (blurs the two currencies / double-punishes pyrrhic
wins, and both force re-tuning the core battle); custom Battle Rules or difficulty selects
(break budget tuning and record comparability — the mode is zero-config like Endless);
persistent meta-power across runs (fights permadeath; only records — runs won, deepest rung —
persist per profile, mirroring `endlessBest`).

Two choices here will surprise a future reader. First, a run is fully deterministic from one
seed: battle defs *and* each draft's three offers derive from `seed + rung`, so the resumable
save is just `{rung, perks, seed}`, reload-scumming is impossible by construction, and daily
seeds come free later. Second, abandoning an in-progress battle counts as losing it — resume
exists only at the between-battles boundary; without this, quitting a losing battle would be a
free retry under permadeath. Canonical language in CONTEXT.md (Gauntlet / Run / Rung / Perk /
Draft / Finale).
