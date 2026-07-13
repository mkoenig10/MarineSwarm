# Marine Swarm — Zone Command

Single-file HTML5 swarm-RTS: Liquid-Swarm-style army movement plus beacon capture and per-team upgrades. This glossary pins the language for the game's concepts.

## Language

### HUD

**HUD**:
The DOM overlay shown during play — topbar, upgrade trays, hint box, tooltip, toasts. Distinct from in-world canvas indicators (zone rings, command-point marker), which are not part of the HUD.
_Avoid_: overlay, UI (too broad — UI includes menu screens)

**Topbar**:
The strip across the top of the HUD showing minerals, supply, zones held, the objective, and the pause/sound buttons.

**Tray**:
The row of upgrade buttons at the bottom of the HUD in solo modes (campaign/skirmish).
_Avoid_: toolbar, dock

**Side tray**:
The narrow vertical upgrade column on each screen half in Versus mode (icon-only, 4 upgrades per player).

**Upgrade button**:
One purchasable upgrade in a tray: icon, label (solo only), level pips, and cost. Buying happens on tap; holding opens the hold-tooltip instead.
_Avoid_: ub (code class name, not spoken language)

**Hold-tooltip**:
The inspection panel opened by holding an upgrade button ~420ms: shows the upgrade's description and NOW → NEXT values without buying.

**Affordability pulse**:
A one-shot glow on an upgrade button at the moment it first becomes affordable. Fires once per affordability flip, never loops.

**Hotkey**:
The keyboard key printed on a tray button that triggers it — number-row keys buy upgrades, Space/Enter fire Stim. Same mapping philosophy in every mode.
_Avoid_: shortcut, keybind

**Supply-capped**:
The state where a team's unit count has reached its supply value, halting reinforcements. Surfaced in the topbar by color (amber near cap, red at cap).

### Game

**Profile**:
A local, per-device player identity: name, profile color, and emblem, plus that player's campaign progress, Battle Rules, and match setup. No account, no login — profiles live in this browser's storage only. The last-used profile is auto-selected at boot; the menu chip switches it.
_Avoid_: account, login, user (nothing is authenticated)

**Profile color**:
The palette color a profile chooses; it becomes that player's team color in every mode. A scripted foe holding the same color is remapped to the first unused palette color.

**Emblem**:
A procedurally drawn insignia chosen per profile, rendered in the profile color. Appears on the menu chip, profile and end screens, Versus headers, and faintly on the owner's command-point beacon and home pad.
_Avoid_: avatar, logo, icon

**Reinforce**:
The upgrade that shortens the spawn interval — faster arrivals, same army ceiling.
_Avoid_: spawn rate (in player-facing text)

**Supply**:
The upgrade (and stat) that raises the maximum army size.
_Avoid_: cap, pop

**Ability**:
An activatable power with a per-use price, triggered in the moment. Distinct from an upgrade, which is a permanent stat purchase. Stimpack is the first ability.

**Stimpack**:
The one-time expensive unlock a team buys to gain the Stim ability. Until bought, its tray button shows the purchase; after, it becomes the activation button.
_Avoid_: stim upgrade (it is an ability unlock, not a stat level)

**Stim**:
The army-wide activation of Stimpack: every living marine trades a fixed slice of health (never lethal) for a burst of attack speed and move speed. Cannot be re-fired while a stim is active — spent health is the only other limiter.
_Avoid_: adrenaline, boost

**Command point**:
The per-team location units flow toward, driven by pointer or keys.
_Avoid_: cursor, target point

**Pad**:
A circular capturable beacon on the battlefield. Mines minerals and reinforces marines for its owner; captured by net unit advantage standing on it. Big pads mine double and reinforce faster.
_Avoid_: zone, beacon (zone survives only in code identifiers and the game's subtitle)

**Cell**:
One square of grid territory on a Grid battlefield. Behaves as a scaled-down pad — mines and reinforces for its owner, painted in the owner's color. Uniform: no big cells.
_Avoid_: zone, sector, tile

**Endless**:
The survival mode: one player defends against escalating Waves of the Horde on a single dedicated map, under standard rules, until their army is wiped. A run lasts one sitting; the score is the wave number reached, and each profile keeps its best.
_Avoid_: survival, horde mode (Horde names the enemy, not the mode)

**Horde**:
The enemy force in Endless. Not a rival player: it has no economy and gains nothing from ground it takes — it exists only as Waves, growing in numbers and combat strength as the run goes on. Its marines can still defect to the player (and absorb strays) like any other team's.
_Avoid_: wave team, foe (foes are the symmetric AIs of Campaign/Skirmish)

**Wave**:
One discrete Horde assault: a group of marines arriving together from a single battlefield edge, announced during the preceding Lull with its direction. Each wave is bigger and stronger than the last. A wave ends when its marines are dead or defected — or, past a time limit, its stragglers are folded into the next wave.

**Lull**:
The guaranteed breathing period between waves — the window to retake pads, mine, and buy upgrades before the next assault is announced.
_Avoid_: intermission, downtime

**Denial capture**:
What happens when the Horde takes a pad: the pad stops working for the player but never works for the Horde — no mining, no reinforcement. Taking ground in Endless only ever starves the defender.

**Best wave**:
A profile's Endless record: the highest wave number that profile has reached.
_Avoid_: high score

**Gauntlet**:
The roguelike mode: a fixed ladder of procedurally generated battles climbed one Run at a time. Winning the Finale wins the run; any loss — or abandoning a battle in progress — ends it.
_Avoid_: run mode, roguelike mode

**Run**:
One attempt at the Gauntlet, from rung 1 to victory or death. Resumable between battles; each profile keeps its record (runs won, deepest rung).

**Rung**:
One battle's slot on the Gauntlet ladder. Each rung's difficulty budget buys the battle's foes, map, and modifiers — higher rungs, richer budgets.
_Avoid_: level, stage, floor

**Perk**:
A drafted, run-long modifier — the Gauntlet build. Distinct from an upgrade (permanent stat bought per battle) and an ability (activated per use, priced). Stat perks stack if drafted again; rule-bending perks are unique per run.
_Avoid_: relic, boon, trait

**Draft**:
The post-victory choice between three offered perks; pick one, then climb to the next rung.

**Finale**:
The Gauntlet's last rung. Winning it wins the run.
_Avoid_: boss (nothing is a single boss unit)

**Grid**:
A battlefield fully tiled with cells instead of dotted with pads — a Skirmish map type and the board of select campaign missions. Territory painting replaces discrete beacon capture; a match still ends by elimination.
_Avoid_: zone control (the inspiration, not the feature name)
