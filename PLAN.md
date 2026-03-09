# Objective
Refresh this repository to a fresh standalone-only Splunk deployment, validate it from a clean runtime state, and capture commit/push evidence without committing `.env`.

## Assumptions
- The repository should default to one standalone Splunk Enterprise instance only.
- Local startup should use a generated admin password stored in `.env` and excluded from git.
- Splunk Web and log-ingestion ports should be reachable from other hosts on the LAN through normal host port publishing.
- Validation may remove old local containers and named volumes to guarantee a clean startup.

## Steps
- [x] P1 Simplify the compose stack to standalone-only LAN-accessible Splunk.
  Acceptance: `docker-compose.yml` contains only the standalone service, keeps explicit pinned Splunk image, accepts license and general terms, defaults to `Free`, and publishes required web/ingestion ports on the host.
  Validation: `docker compose config`
  Evidence: Changed file: `docker-compose.yml`; removed the bundled forwarder service, kept `docker.io/splunk/splunk:10.2.1-rhel9`, preserved `SPLUNK_GENERAL_TERMS` and `SPLUNK_LICENSE_URI=Free`, and published `8000`, `8088`, `8089`, and `9997` on `0.0.0.0`; `docker compose config` rendered the standalone-only service successfully.
- [x] P2 Regenerate local-only environment and docs for standalone usage.
  Acceptance: `.env` contains a new strong Splunk admin password and required env values, `.gitignore` excludes `.env`, and `README.md` documents standalone-only setup plus LAN access notes.
  Validation: manual diff review against compose settings
  Evidence: Changed files: `.env`, `.gitignore`, `README.md`; generated a new 24-character mixed-complexity password in `.env`, added explicit `.env` ignore protection, and rewrote docs for standalone-only startup plus LAN-accessible ports and clean reset guidance.
- [x] P3 Run a fresh standalone validation.
  Acceptance: old stack state is removed as needed, `so1` starts cleanly, and evidence is captured from compose status, logs, and HTTP port 8000.
  Validation: `docker compose down -v --remove-orphans`; `docker compose up -d so1`; `docker compose ps`; `docker compose logs --tail=50 so1`; `curl -I --max-time 15 http://127.0.0.1:8000`
  Evidence: Reset prior state with `docker compose down -v --remove-orphans`, then started `so1` cleanly; readiness reached with a successful `curl -I` returning `HTTP/1.1 303 See Other` from `Server: Splunkd`; `docker compose ps` showed `so1` on `docker.io/splunk/splunk:10.2.1-rhel9` with published `0.0.0.0` ports and healthy status; startup logs showed `Activate free license`, a clean Ansible `PLAY RECAP`, and streaming handoff.
- [x] P4 Commit and push repo changes without `.env`.
  Acceptance: intended tracked files are committed with a clear message, `.env` is not staged, and the branch is pushed to its configured remote.
  Validation: `git status --short`; `git commit`; `git push`
  Evidence: `git status --short --branch` stayed clean after staging only tracked repo files, leaving `.env` ignored and unstaged; created commit `5dafba7` with message `Update standalone Splunk startup`, then commit `2728d7b` with message `Document standalone validation evidence`; final push evidence recorded after `git push origin main`.

## Decisions
- Keep the setup minimal: one standalone Splunk service and no bundled forwarder service.
- Use explicit `docker.io/` image naming and a pinned Splunk tag.
- Preserve local password storage in `.env` only; do not commit secrets.

## Risks and Rollback
- Resetting with `docker compose down -v --remove-orphans` deletes local Splunk data for this repo.
- Startup time can be several minutes before web readiness on port 8000.
- Push can still fail because of remote auth, branch protection, or connectivity.

STATUS: SUCCESS
NEXT_ACTION: None.
EVIDENCE: Updated files: `docker-compose.yml`, `.env`, `.gitignore`, `README.md`, `PLAN.md`; validation passed for compose config, fresh startup, healthy runtime, logs, and HTTP response on port 8000; commits created on `main`: `5dafba7` (`Update standalone Splunk startup`) and `2728d7b` (`Document standalone validation evidence`); `.env` remained ignored and unstaged throughout.
