# PLAN: Add a sourceable environment setup script

## Status
- Overall: complete
- Current phase: complete — script added and reviewed

## Objective
Add a root `setup-env.sh` that activates the shared SWQA virtual environment when sourced.

## Non-goals
Do not install packages or alter other setup workflows.

## Decisions and acceptance criteria
- Use the repository-standard filename `setup-env.sh` and the user-specified activation path.
- Explain source usage and give a clear error if the activation file is unavailable.
- Review the script and search for dependent references; do not run tests unless requested.

## Guardrails
Leave pre-existing working-tree changes untouched.

## Files
- `setup-env.sh`
- `plan-todo/done/PLAN-setup-env-script.md`

## Phases
### Phase 1: Implement and hand off
- [x] Add and review `setup-env.sh`.
- [x] Search for downstream references and review the scoped change.
- Validation: manually reviewed the script and confirmed its references; no tests run.
- [x] Archive this plan in `plan-todo/done/`.
- [x] Update context and end session.
