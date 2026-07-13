# Marine Swarm — Zone Command · Handoff

Single-file HTML5 swarm-RTS. Everything (HTML/CSS/JS) lives in one file:
`marine-swarm.html`. No build step, no dependencies — open it in a browser
or serve it statically.

## Concept
Liquid-Swarm-style movement (whole army flows to your finger/cursor) +
StarCraft marine units + SC2 arcade "Zone Control" style beacon capture
and per-team upgrades (damage/rof/speed/range/armor/reinforce/supply).

## Modes
- **Campaign** — 11 scripted missions (`MISSIONS` array), sequential unlock
  (`unlocked`, persisted — see item 1 below). Two are grid missions
  (`m.grid` flag, built by `buildGridMissionDef`): M06 "SECTOR PAINT"
  (grid intro, 1 normal foe) and M10 "RECLAMATION" (2 hard foes who
  pre-own `m.foesOwn` of the board width from the right, split
  top/bottom — the region is computed at build time because cell indices
  depend on screen aspect). Campaign cards/briefs show a "▦ GRID" tag.
  Note for sims: AI-vs-AI grid battles seesaw — RECLAMATION can run
  several hundred sim-seconds before elimination; that's expected.
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
- **Endless** — survival mode (see `docs/adr/0002-horde-reuses-team-pipeline.md`
  and CONTEXT.md: Endless/Horde/Wave/Lull/Denial capture/Best wave). One
  dedicated map (`buildEndlessDef`: big home pad center + 6-pad ring), always
  `RULE_DEFAULT`, zero config. The **Horde** is team index 1 (`T.horde`,
  `S.horde`), a normal team with no home pad/units at start; a **wave
  director** (`S.ev` `{wave,state,t,dir,maxT}`, driven by `waveDirector` in
  `update`, tunables in `EV_CFG`) spawns discrete waves from one telegraphed
  edge (`spawnWave`, size = `waveSize(n)`, +1 combat upgrade level per wave
  via `hordeUpg` cycling `EV_CFG.hordeUps`). Denial capture: Horde-owned
  pads never mine or deploy (guards in `updateZones`); Horde exempt from
  elimination in `checkEnd`; no Horde stim. Lull is clear-triggered with a
  `waveMax` straggler guard. Lose = player elimination; score = wave
  reached, persisted per profile as `endlessBest` (menu button label via
  `syncEndlessBtn`). Waves silently shrink at `rules.cap` — by design.
- **Gauntlet** — roguelike run mode (see `docs/adr/0003-gauntlet-reuses-
  skirmish-pipeline.md` and CONTEXT.md: Gauntlet/Run/Rung/Perk/Draft/Finale).
  A **Run** = `GAUNT_LEN` (8) battles: rungs 1–7 are ordinary skirmish defs
  picked from the `GAUNT_RUNGS` budget table (foes/diff/map choices), rung 8
  (**Finale**) reuses the RECLAMATION-style grid `foesOwn` setup. Fully
  deterministic from one seed: `SRND` (scoped override inside `rnd()`) is set
  by `buildGauntletDef` during def building only; draft offers come from
  `gauntOffers` (seed+rung+owned uniques). After each win, a **Draft**
  (`scrDraft`): pick 1 of 3 **Perks** (`PERKDEF`, 9 stackable stat perks +
  5 unique rule-benders) applied to the player team only via `T.pk`
  modifiers (`mkPk`/`applyPerks`) — every team gets a neutral `pk`, and
  `STAT`, income, kill bounty, capture rate, absorb, and stim cost all read
  it. Always `RULE_DEFAULT`, zero config, solo only. Permadeath: any loss
  ends the run, **abandoning a battle = losing it** (pause-quit forfeits;
  Restart/Retry buttons hidden; a run saved with `ph:'in'` is declared lost
  on next Gauntlet start — the only resume point is `ph:'draft'`). Working
  state `GAUNT{run,wins,best}`, persisted per profile (`gaunt`/`gauntWins`/
  `gauntBest`, validated + unique-perk-deduped in `validProfile`); menu
  button label via `syncGauntBtn`. **Run debrief** (playtest telemetry for
  tuning, nothing reads it): `gauntLogRung` pushes one entry per rung fought
  onto `GAUNT.run.log` (map, clear time, losses, army low-point via
  `S.runLow`, 10s grace); shown on the end screen (`gauntDebriefHtml` via
  `gauntLast`) and live in Field Stats. Log persists with the run and is
  sanitized in `validProfile`. Tuning fence agreed with the owner
  (2026-07-13): adjust `GAUNT_RUNGS` contents, `PERKDEF` numbers, finale
  knobs; do NOT touch run length, draft structure, or anything that leaks
  outside Gauntlet (`CFG`/`STAT`/`DIFF`). Target curve: rungs 1–2 near-
  guaranteed, typical runs die at 3–5, finale clearly hardest, full clear
  ~25–35 min, no rung past ~7 min. Note for sims: the AI-vs-AI grid-finale
  seesaw applies here too, and a hard-AI proxy only wins ~65% of rung 1 —
  that's baseline AI-vs-AI variance (measured identical on plain skirmish),
  not a Gauntlet bug; humans do much better.
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
- **Sprite atlas** (`atlas(ci,kit)`/`drawMarine(g,C,f,kit)`) — procedurally
  drawn per-color marine sprite sheet (16 angles × 3 anim frames),
  canvas-cached in `ATLAS` keyed by color index (stock) or color+kit key.
- **Kits / Armory** (see CONTEXT.md: Armory/Kit/Stock look/Secondary color
  and `docs/adr/0004-kits-are-cosmetic-only.md`) — cosmetic marine
  customization. A **Kit** `{h,p,b,w,c}` indexes the slot tables `KIT_H`/
  `KIT_P`/`KIT_B` (helmet/pauldrons/pack, 4 each), `KIT_W` (10 weapons —
  all single-shot gun fantasies by design, each with its own barrel-tip
  muzzle offset in `MUZW` and gunshot recipe in `snd` read by
  `AudioSys.shot(w)`), and `KIT_C` (8 secondary tones, a palette
  deliberately distinct from the 6 team colors so kits can't impersonate
  an enemy team). Purely cosmetic: only `drawMarine`, `MUZW` and
  `AudioSys.shot` read it — never `STAT`/`CFG`. Teams carry `T.kit`
  (null = stock look); def builders give it to the profile player's team
  only via `profKit()` (foes, Horde, Versus P2, menu demo stay stock).
  Persisted per profile (`kit`, validated in `validProfile`), all options
  free from the start. The **Armory** (`scrArmory`, main-menu button +
  linked from profile edit) edits the active profile's kit in place and
  previews it in a live viewer (`armoryFrame`: rotating, walk-cycling,
  test-firing with true muzzle offset + `AudioSys.shotSnd(w)`, which
  bypasses the per-tick shot budget).
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
- **Stimpack** — the game's first *ability* (see CONTEXT.md): a one-time
  `CFG.stimCost` unlock per team (`T.stimOwn`), then an army-wide activation
  (`doStim`): every living marine pays `CFG.stimHp` HP (clamped to 1, never
  lethal) for `CFG.stimDur`s of +rof/+spd (`CFG.stimRof/stimSpd`, applied
  inside `STAT.rof/spd` via `T.stimT>0`). No cooldown — the only gates are
  the HP price and no re-stim while active (`T.stimT` ticks down in
  `update`). `stimAct(ti)` = tap/hotkey semantics (buy if locked, else
  fire). AI: `'stim'` sits in each `PERS` order; `buyPass` **saves up**
  (breaks out of lower priorities) once it reaches an unaffordable stim;
  easy AI and versus `bot` teams never buy it. AI fires via `aiThink`
  when ≥5 hostiles are near its centroid and army HP >50%.
- **Hotkeys** — solo: `1–7` buy upgrades, `8`/`Space` = stim. Versus:
  P1 `1–4` + `Space`, P2 `7–0` (`VS_UPGS` order) + `Enter`; `5 6` are a
  deliberate dead buffer. Labels rendered on tray buttons (`.hk` corner
  tag via `mkUb`). Hotkeys ignore key auto-repeat and pause/over states.
- **Profiles** — local per-device identities (see CONTEXT.md: Profile /
  Profile color / Emblem — deliberately *not* accounts; OAuth was
  considered and rejected to preserve the no-server single-file design).
  `PROFILES{list,active}`, `prof()`, `mkProfile`. Per-profile: `unlocked`,
  `RULES`, `SK`, `VS` (these stay the *working globals*; `applyProfile()` /
  `stashProfile()` copy in/out on switch & save). Device-global: sound.
  Save format `ms_save_v2` `{profiles,active,sound}` with one-time v1
  migration (v1 removed + v2 written immediately). Boot auto-selects
  `active`; menu chip (`#profChip`, `syncProfChip`) opens `scrProfiles`
  (create/switch/rename/delete, cap `MAXPROF=8`, two-tap delete) and
  `scrProfEdit` (name input + 6 color swatches + 12 emblems).
  **Profile color = team color in all modes** (demo excluded): def
  builders route every team color through `colAlloc()` which remaps
  collisions to the first unused palette color. **Emblems**
  (`drawEmblem`/`embCanvas`, `NEMB=12` procedural insignias) show on the
  chip, profile rows, end screen (non-versus), P1's versus side tray,
  and in-world on P1's command beacon + home pad (`Z.homeOf`, drawn
  while the home zone is still owned).
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
- `ios/` — bare WKWebView Xcode project for on-device iPhone playtesting
  (personal-device signing only, not distribution). Bundles
  `../marine-swarm.html` **by reference** at build time — the HTML stays
  the single source of truth and needs no changes for iOS. Landscape-
  locked, edge-to-edge, system edge gestures deferred; phone localStorage
  saves are treated as disposable. Setup + first-playtest checklist:
  `ios/README.md`. No dependencies (Capacitor et al. deliberately
  rejected — the game needs zero native APIs).
- This `CLAUDE.md` — handoff doc only, not referenced by the game itself.

## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature>/` in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
