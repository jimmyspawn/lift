# LIFT

A self-hosted workout tracker for a 4-session Upper/Lower rotation with double-progression logic. Built mobile-first because logging sets in a spreadsheet on a phone is miserable.

Single static HTML file. No build step, no framework, no backend. Data lives in `localStorage` on the device.

## Repo layout

```
lift/
├── README.md
├── docker-compose.yml
├── .gitignore
└── public/
    └── index.html      ← the entire app (HTML + CSS + JS in one file)
```

## Deployment (Ugreen NAS, Docker)

```bash
# On the NAS — the path matters because the compose uses an absolute mount:
cd /volume1/docker
sudo git clone <your-repo-url> lift
sudo chown -R 1000:1000 lift
cd lift
docker compose up -d
```

If managing via Portainer, deploy as a **Web editor** stack and paste the compose. Don't use **Repository** mode — Portainer clones to its own data volume, which the docker daemon can't resolve as a bind mount source.

App is now at `http://<nas-ip>:8090`. To update, `git pull` and the next page reload picks up the change (the volume is read-only mounted, no container restart needed).

If port 8090 is taken, edit `docker-compose.yml` and change the left side of the port mapping.

### Accessing it from the gym

Two options, in order of effort:

1. **Browser cache.** Open the URL on home WiFi once, "Add to Home Screen" on your phone. The browser caches the HTML + Google Fonts. App works offline; data lives in phone's localStorage. Export JSON occasionally as a backup. **This is the recommended setup.**
2. **Tailscale.** Install on NAS and phone (free). Phone gets private connectivity to the NAS from anywhere. Useful if you want other NAS services accessible too.

## Local development

It's a single HTML file. Just open `public/index.html` in a browser.

For a quick local server (so Add-to-Home-Screen works realistically):

```bash
cd public && python3 -m http.server 8080
```

## Data & backup

- All workout history lives in `localStorage` under the key `lift.history.v1`.
- An in-progress session is saved under `lift.draft.v1` so a screen lock won't lose data.
- The app's Export button downloads a JSON of your full history. Import accepts that same format and **replaces** existing history.
- **Data is per-device.** Switch phones → export first, import on the new one.

## Architecture notes

For anyone (or any agent) editing this:

- **One file, no build.** Don't introduce a bundler, framework, or `node_modules`. The constraint is the feature.
- **State shape.** Single `state` object holds: `view`, `history` (array of completed sessions), `draft` (active session being logged), `detailId`, `expandedExerciseIdx`. View is one of `home | picker | session | history | detail`.
- **Rendering.** Each view is a function returning an HTML string. `render()` writes to `#app`'s innerHTML. Inputs use event delegation (`document.addEventListener` once at top level, dispatching on `data-action` and `data-input` attributes). Don't add per-element listeners — they'll leak across re-renders.
- **Program data** lives in the `PROGRAM` constant near the top of the script. Each exercise has `name, sets, repMin, repMax, rest, inc` and optional `suffix` ("/ leg", "/ side"). Adding a new exercise: append to the relevant session array. Adding a new session type: extend `ROTATION` and add a `PROGRAM` entry. Both are picked up automatically by all views.
- **Double progression rule.** `hitTopOfRange()` checks every set has `reps >= repMax`. When true, the in-session flag shows next session's weight as `current + inc`. There's no automatic weight bump — Jimmy types it in manually next session (intentional; sometimes you want to repeat a weight).
- **Storage.** Every state mutation that should persist calls `saveDraft()` or `saveHistory()`. Don't add a debounce — localStorage writes for ~50KB are fast enough.

## Roadmap (likely next tasks)

Roughly in priority order:

- **Per-set weight override.** Currently one weight per exercise. Useful for back-off sets / drop sets.
- **Rest timer.** Tap "set done" → countdown matching the exercise's rest period. Vibrate on completion.
- **Service worker for true offline.** Right now offline relies on browser cache, which iOS evicts after ~14 days of disuse. A service worker (in a separate `sw.js` since it must be its own file) would make this rock-solid.
- **PR / progression view.** Per-exercise chart of weight × reps over time. Recharts or a tiny SVG renderer; don't pull in Chart.js.
- **Edit past sessions.** Currently history is read-only except for delete. Sometimes you forget to log a set and want to fix it.
- **Two profiles (Jimmy + partner).** Shared deploy, separate history per person. Profile picker on home; scope the localStorage keys (`lift.history.v*`, `lift.draft.v*`) per profile. No backend — stays client-only.
- **Multi-device sync.** Would require a backend. Out of scope unless I switch hosting model — `Caddy + a tiny Go/Node API + SQLite on the NAS` is the obvious shape.
- **Deload reminders.** App knows session count; flag every 6–8 weeks.

## License

Personal use. Not published as a product.
