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

**Grid**:
A battlefield fully tiled with cells instead of dotted with pads — a Skirmish map type and the board of select campaign missions. Territory painting replaces discrete beacon capture; a match still ends by elimination.
_Avoid_: zone control (the inspiration, not the feature name)
