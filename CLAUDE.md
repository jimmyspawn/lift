# Workout Tracker PWA — Project Context

## What this is

A self-hosted workout tracker PWA for Jimmy's strength + hypertrophy program. Runs on a Ugreen NAS (UGOS, Docker) via docker-compose. Built deliberately as a **single-file HTML app** (`public/index.html`) — no framework, no build step, string-based HTML rendering with event delegation, localStorage for persistence. Keep it that way: the architecture was chosen for easy self-hosting and easy editing by AI agents.

## The user

- Jimmy, Melbourne. 4+ years training experience, ~86kg.
- Trains 3 days/week on a **fixed weekly schedule** (recently changed — see "Current task").
- Goal: size and strength via double progression.
- **Back injury history — hard constraints, do not reintroduce:** no barbell back squats, no conventional deadlifts, no RDLs, no standing barbell OHP. Trap bar deadlift is *conditional on physio clearance* (not yet obtained — default to leg press in that slot).
- Any back pain during a session → stop, substitute a known-safe lift, log it in notes.

## Progression model: double progression

Every exercise has a rep range (e.g. 4 × 6–8):

1. Start at a weight where all sets hit the bottom of the range.
2. Add reps session to session.
3. When all sets hit the top of the range → add weight next session (+2.5kg upper body/DB work, +5kg leg press/hip thrust/trap bar) and reset to the bottom of the range.

The app flags when an exercise is ready for a weight increase. This logic must be preserved through any refactor.

## Program: fixed weekly 3-day split (implemented 2026-07-18)

The old 4-session rotating split (Lower A → Upper A → Lower B → Upper B) has been retired and replaced with the fixed weekly program below. Session order is always Day 1 → Day 2 → Day 3, repeating weekly. "Next session" is whichever of the three comes after the last completed one (legacy A/B history falls back to Day 1).

### Day 1 — Lower

| # | Exercise | Sets × Reps | Rest |
|---|----------|-------------|------|
| 1 | Leg Press | 4 × 6–8 | 3 min |
| 2 | Hip Thrust (barbell) | 4 × 6–8 | 2–3 min |
| 3 | Bulgarian Split Squat (DBs) | 3 × 8–10/leg | 2 min |
| 4 | Lying or Seated Leg Curl | 3 × 10–12 | 90 s |
| 5 | Standing Calf Raise | 4 × 8–12 | 60 s |

### Day 2 — Upper

| # | Exercise | Sets × Reps | Rest |
|---|----------|-------------|------|
| 1 | Barbell Bench Press | 4 × 5–6 | 3 min |
| 2 | Chest-Supported Row | 4 × 6–8 | 2 min |
| 3 | Seated DB Shoulder Press | 3 × 8–10 | 2 min |
| 4 | Lat Pulldown | 3 × 10–12 | 90 s |
| 5 | Cable Lateral Raise | 3 × 12–15 | 60 s |
| 6 | Tricep Rope Pushdown | 3 × 10–12 | 60 s |

### Day 3 — Full Body

| # | Exercise | Sets × Reps | Rest |
|---|----------|-------------|------|
| 1 | Trap Bar Deadlift *(if physio-cleared)* OR Leg Press (2nd variation) | 3 × 6–8 | 3 min |
| 2 | Pull-ups (or Lat Pulldown) | 4 × 6–10 | 2 min |
| 3 | Incline Dumbbell Press | 3 × 8–10 | 90 s |
| 4 | Walking Lunges (DBs) | 3 × 10/leg | 90 s |
| 5 | Leg Extension | 3 × 12–15 | 90 s |
| 6 | EZ-Bar Curl | 3 × 8–10 | 60 s |

Per-leg/per-side exercises log reps per side. Optional: seated calf raises can be appended to Day 3.

### Migration notes (implemented)

- Existing localStorage history keyed to the old A/B sessions is preserved — the history/detail views still render old sessions. New sessions log against the new day definitions.
- Weight pre-population (`lastTime`) searches **all** history regardless of session type, with a `LEGACY_ALIASES` map for renamed lifts (Hip Thrust ← Hip Thrust (heavy), Tricep Rope Pushdown ← Tricep Pushdown, EZ-Bar Curl ← EZ-Bar / DB Curl), so double progression continued seamlessly across the switch.
- Rep ranges changed on a few lifts (e.g. seated DB press was 4 × 6–8, now 3 × 8–10) — the weight carries over and the new range applies.
- An unfinished draft from the old rotation is dropped on load (it can't be logged against the new day definitions).

## Existing features (all delivered, all to be preserved)

- Per-exercise weight input with steppers
- Per-set weight toggle (for injury days / back-off sets) — per-set mode carries into next session's prefill; progression flag suggests "+inc kg" instead of a single number
- Per-set rep logging with live colour feedback against the rep range
- Auto-population of previous session's weights
- Double progression flags ("add weight next time")
- Draft auto-save mid-session
- Session notes
- History view
- JSON export/import for backup

## Roadmap (prioritised, from README)

1. ~~Per-set weight override~~ (done 2026-07-18)
2. Rest timer
3. Service worker for offline support
4. PR charts
5. Edit past sessions
6. Multi-device sync
7. Deload reminders

Deloads happen every 6–8 weeks: same exercises, ~70% working weight, same rep targets — a deload reminder feature should count completed weeks, not calendar time.

## Deployment

- `docker-compose.yml` in repo root; one-command deploy on the NAS.
- Git repo exists locally. GitHub push was blocked by an auth error (password auth removed by GitHub in 2021). Recommended fix: `gh auth login` via GitHub CLI; alternatives are a fine-grained PAT or SSH keys. Status unresolved — check before assuming remote is set up.

## Conventions & preferences

- Single file, no dependencies, no build step. Resist adding frameworks or bundlers.
- Practical, direct communication — concrete numbers and reasoning, minimal fluff.
- Prefer simple, maintainable solutions over clever ones.
- kg only. Melbourne timezone for dates.
