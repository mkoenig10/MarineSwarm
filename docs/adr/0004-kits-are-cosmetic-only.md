# Kits are cosmetic-only and belong to the Profile

Marine customization (the Armory / Kit system) changes only how a marine is drawn and what
its gunfire sounds like — never a stat. Every number still flows through `CFG`/`STAT`/
upgrades/Battle Rules exactly as before; a Kit is applied per team as a render/audio input
(`T.kit`), read only by the sprite atlas, the muzzle-offset table, and `AudioSys.shot`. The
Kit lives on the Profile next to color and emblem, dresses the whole army in every mode, and
non-player forces (AI foes, the Horde, Versus P2, the menu demo) always wear the stock look.

Rejected alternatives worth remembering: weapons with stat trade-offs, or a full pre-battle
loadout system (each is effectively a second upgrade system — it would touch `STAT`, AI buy
logic, Versus fairness, and the Gauntlet tuning fence, and every skin choice would become a
balance decision); per-match cosmetic selection (doesn't cover Campaign/Endless/Gauntlet and
duplicates identity the Profile already owns); random foe styles (dilutes "this look = me"
and multiplies atlas memory per team).

Two guardrails will surprise a future reader. First, the secondary color is picked from its
own palette of tones deliberately distinct from the six team colors — chosen over remap-on-
collision or accepting clashes — so a player's Kit can never impersonate an enemy team in a
swarm fight by construction, with zero per-match logic. Second, all ten weapon skins are
constrained to single-shot gun fantasies (no shotguns/miniguns/beams): stats are identical
including cadence, and a fantasy that implies burst or spread would read as a bug. Canonical
language in CONTEXT.md (Armory / Kit / Stock look / Secondary color).
