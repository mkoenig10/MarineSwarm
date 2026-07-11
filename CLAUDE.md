# Marine Swarm — Zone Command · Handoff

Single-file HTML5 swarm-RTS. Everything (HTML/CSS/JS) lives in one file:
`marine-swarm.html`. No build step, no dependencies — open it in a browser
or serve it statically.

## Concept
Liquid-Swarm-style movement (whole army flows to your finger/cursor) +
StarCraft marine units + SC2 arcade "Zone Control" style beacon capture
and per-team upgrades (damage/rof/speed/range/armor/reinforce/supply).

## Modes
- **Campaign** — 9 scripted missions (`MISSIONS` array), sequential unlock
  (`unlocked` var, not persisted across reloads — see To-Do).
- **Skirmish** — 1–5 AI foes, 4 difficulties, 4 map types (open/corridors/
  scatter/grid), fully driven by `RULES`/`RULEDEF` custom battle rules.
  **Grid** is an SC2 "Zone Control"-style territory mode: the battlefield
  is fully tiled with uniform cells that are pad objects in `S.zones`
  (`Z.cell` flag) with income weight `Z.w` and spawn-interval mult `Z.sm`
  scaled so the whole grid ≈ `CFG.gridPadEq` pads. Free capture (no
  adjacency rule), one home cell per team, elim win condition, no big
  cells/walls. `S.grid` holds `{gw,gh,cw,ch}`; `statsPass` uses O(1)
  cell indexing instead of the per-zone distance loop. Language + why:
  CONTEXT.md (Pad/Cell/Grid) and `docs/adr/0001-grid-reuses-pad-pipeline.md`.
- **Versus** — local 2-player same-screen (P1 = left screen half / WASD,
  P2 = right half / arrow keys), optional 2 neutral bots.
- Menu background is a live "demo" skirmish sim (`S.demo`), muted/no HUD.

## Architecture (all inside the one `<script>` block)
- **CFG** — base tunable constants (unit radius, base dmg/rof/spd/rng/hp,
  spawn interval, income, capture rate, hard unit cap, etc).
- **UPGDEF** — the 7 purchasable upgrades, each with cost curve
  (`base * grow^level`), max level, and now a `d:` description string
  (used by the hold-tooltip).
- **STAT** — per-team effective stat functions; combine `CFG` + upgrade
  levels + `S.rules` multipliers. Always read stats through `STAT.x(team)`,
  never `CFG` directly, or custom Battle Rules will be silently ignored.
- **RULES / RULEDEF / RULE_DEFAULT** — the "Battle Rules" custom-match
  system (Skirmish + Versus only; Campaign always uses `RULE_DEFAULT`).
  Steppers built in `buildRules()`, rendered in `#scrRules`.
- **PALETTE / TNAME** — team colors + names (6 max colors currently used).
- **DIFF** — AI difficulty presets (reaction time, income mult, starting
  upgrade freebies).
- **PERS** — AI "personality" upgrade-buy priority orders (rush/eco/bal).
- **AudioSys** — procedural WebAudio (no audio files). Gunfire is
  rate-limited by the `shots` counter: `AudioSys.shot()` no-ops once
  `shots>=3`, and `shots` is reset to 0 at the top of `update(dt)` —
  i.e. max 3 gunshot sounds per fixed-step tick.
- **Sprite atlas** (`atlas()`/`drawMarine()`) — procedurally drawn per-color
  marine sprite sheet (16 angles × 3 anim frames), canvas-cached per color
  index in `ATLAS`.
- **GRID** — simple spatial hash for neighbor queries (separation, target
  acquisition, absorb-conversion checks). Rebuilt every frame in `statsPass()`.
- **Mission/def builders** — `buildMissionDef(i)`, `buildSkirmishDef(...)`,
  `buildVersusDef(...)` all return a plain `def` object consumed by
  `newGame(def)`. Corridors maps (mission 4 + skirmish "corridors") use
  5 staggered wall segments (not 2 solid bars) so AI steering flows through
  gaps naturally — no real pathfinding, just seek+separation+wall AABB push-out.
- **Core loop** — fixed-step (`STEP=1/60`) accumulator in `frame()`, calls
  `update(dt)` → `statsPass → aiThink → updateUnits → updateZones → updateFx
  → updateHints → checkEnd`, then `render()` every rAF regardless of pause.
- **Zones/beacons** — each zone tracks `owner`, capture `prog` (0–1),
  contested logic uses (top count − second count) as "net" advantage.
  Big/core zones (`Z.big`) mine 2x and spawn faster.
- **Absorb/conversion** — isolated, heavily-outnumbered units may defect to
  the killer's team on death (`processDeaths()`), capped by supply + hard cap.
- **Input** — pointer events drive a per-team "command point" (`T.cp`);
  units steer toward it (`updateUnits`). Versus splits pointer by screen
  half. WASD / arrow keys also nudge `T.cp` (`moveKeyCp`).
- **UI object** — all screen transitions/menu logic. Screens are plain
  hidden/shown divs (`SCREENS` array), no router.
- **Upgrade trays** — built in `buildTrays()`, refreshed every ~0.12s in
  `refreshHUD()`. Hold-to-inspect added via `wireUb()` (pointerdown starts
  a 420ms timer → `showUpgTip()`; release before timeout = buy, after = just
  closes tooltip). Tooltip shows NOW → NEXT value + cost, doesn't mutate state.
- **Field Stats** (pause menu) — `UI.stats()` toggles `#statsBox`, dumps
  live upgrade levels/values + kills/losses/mined/time per human team.
- **Debug overlay** — `` ` `` key or Pause menu toggle; shows FPS/unit/fx
  counts and per-team supply/minerals/kills. `window.__ms` exposes internals
  (`S`, `CFG`, `STAT`, `UPGDEF`, `MISSIONS`, `RULES`, `RULE_DEFAULT`,
  `newGame`, `update`, `buyUpg`, builders, `spawnUnit`) — used for headless
  testing (see below) and live console tweaking.

## Testing approach used this session
No test framework — headless smoke tests written to `/tmp/*.js`, run via
plain `node`. Pattern: stub `window`/`document`/`canvas` with a generic
`Proxy` (`anyProxy()`) so all canvas 2D calls no-op safely, extract the
`<script>` contents with a regex, `vm.runInThisContext`, then drive the
game via `window.__ms` exports (`newGame`, `update(dt)` in a loop, assert
on `S.teams`/`S.units`/`S.zones`). Watch out for `const S` colliding with
a test-local `S` if both run in the same vm context — alias the test's
reference (e.g. `GS`) instead of redeclaring `S`.

Recommended before shipping any change: re-run `node --check` on the
extracted script, then a short sim (build a def, `newGame`, loop
`update(1/60)` for a simulated battle, assert no exceptions, sane unit
counts, combat/income actually happened, no units embedded in walls).

## Known gaps / good next steps
1. ~~No persistence~~ **Done.** `saveState()`/`loadState()` persist a
   JSON blob (`ms_save_v1` in `localStorage`): `unlocked`, `RULES`,
   sound toggle, and skirmish/versus setup (`SK`/`VS`). Loaded at boot
   with per-field validation (invalid/corrupt data is ignored, all
   access is try/catch-wrapped so headless tests without `localStorage`
   still run). Saves fire on mission win, sound toggle, rule stepper /
   reset, and setup segment clicks. Both functions are exported on
   `window.__ms`.
2. ~~AudioSys.shots reset~~ **Fixed.** The counter was never reset, so
   gunfire audio went permanently silent after the first 3 shots of a
   session. Now reset to 0 at the top of `update(dt)` (max 3 gunshot
   sounds per 1/60s tick). `AudioSys` is also exported on `window.__ms`
   for headless tests.
3. ~~Versus vs 2 bots~~ **Balanced.** Bots now use a dedicated
   `DIFF.bot` preset (react 2.2, inc 0.75) and start with `st*0.6`
   units; the versus map's corner pads moved from y .22/.78 to .3/.7
   (they sat much closer to the bot spawns than the human sides).
   Measured via headless FFA sims with normal-AI proxies driving the
   human teams: bot win rate went 92% → ~35% over 72 games (humans
   favored ~2:1, bots still a threat); no-bots duel stayed symmetric.
   Sim harness pattern: give human teams `T.ai={t:..}; T.diff='normal'`
   after `newGame` and loop `update` until `S.over`.
4. **Campaign difficulty curve** not re-tuned since Battle Rules were
   added — missions always use `RULE_DEFAULT`, which is correct/intended,
   just flag if asked to make campaign configurable too.
5. **Mobile perf**: `CFG.hardCap` / `RULES.cap` guard total unit count;
   if adding more visual effects, re-check FPS via the debug overlay on
   a throttled device.
6. **No pathfinding** — only steering + wall AABB collision. Fine for
   current maps (walls are thin rectangles with generous gaps); if future
   maps get maze-like, will need actual A*/flow-field.
7. ~~Battle Rules tooltips~~ **Done.** Every `RULEDEF` entry now has a
   `d:` description. `buildRules()` wires the steppers like `wireUb`:
   quick tap = step value, hold 420ms = `showRuleTip()` (shows
   description + NOW vs STANDARD value, no state change); pressing the
   rule name peeks the tooltip too. Tip renders in `#ruleTip` (own
   fixed-position element — `#upgTip` lives inside `#hud`, hidden on
   menu screens), hidden on screen exit/rebuild.

## File map
- `/mnt/user-data/outputs/marine-swarm.html` — the game, ship this file.
- This `CLAUDE.md` — handoff doc only, not referenced by the game itself.

## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature>/` in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
