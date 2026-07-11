# Grid map type reuses the pad pipeline, with free capture

The GRID skirmish map type (SC2 "Zone Control"-style painted territory) is implemented as ~40
uniform cells that ARE pad objects in `S.zones` — each cell mines and reinforces like a pad with
its rates scaled down by the cell/pad count ratio — rather than as a separate tile/territory
system. This keeps the entire capture, income, spawn, elimination, and AI zone-scoring pipeline
working unchanged (elimination on a grid naturally plays as total domination), at the cost of
cells carrying some pad-shaped baggage (per-cell spawn timers, circular capture checks under
square visuals).

Cells also use **free capture** — any cell your marines stand on flips, no adjacency-to-owned-
territory requirement, deliberately deviating from the SC2 Zone Control convention. Adjacency
rules would fight the liquid-swarm control scheme (the army flows wherever the finger points;
standing on a cell that refuses to flip feels broken) and would need enclave/cut-off resolution
logic and AI awareness. If front lines prove too mushy, the agreed fallback is a *soft* adjacency
bonus (adjacent cells flip faster), not a hard rule.

Related decisions from the same session: GRID is a fourth skirmish map type (not an orthogonal
"battlefield system" toggle, not in Versus/Campaign); one home cell per team, rest neutral;
uniform cells (no big cells, no walls). Canonical language: Pad / Cell / Grid — see CONTEXT.md.
