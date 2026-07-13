# The Endless Horde is a real team with its economy zeroed

The Horde in Endless mode is implemented as an ordinary team in `S.teams` — its marines are
normal units, it captures pads via the standard net-advantage logic, it participates in
absorb/conversion both ways, and its per-wave escalation is expressed as *upgrade levels* so its
combat stats flow through the existing `STAT`/`UPGDEF` math — rather than as a bespoke
wave-enemy system with its own stat table. What makes it a horde is subtraction, not new
machinery: its income is zeroed and its pads never mine or spawn ("denial capture" — Horde-held
ground only starves the player), and a wave director replaces the economy as the sole source of
its units. The alternative — custom wave stats and capture-immune enemies — would have needed a
parallel balance model and special cases in targeting, capture, and death handling; reusing the
team pipeline keeps a wave-15 marine exactly as predictable as an upgraded skirmish AI's.

Consequences worth knowing: `checkEnd`'s elimination check must not read an empty Horde
mid-lull as a player victory, and late waves silently shrink once total units hit the hard cap,
so the wave curve is designed against that ceiling. Related decisions from the same session
(one dedicated map, discrete telegraphed single-edge waves, clear-triggered lulls with a
straggler guard, `RULE_DEFAULT` only, pads-only income, no Horde stim, one-sitting runs with
best-wave-per-profile): canonical language in CONTEXT.md (Endless / Horde / Wave / Lull /
Denial capture / Best wave).
