# review_before_deletion/

This folder is a **quarantine area** for cleanup work.

## Policy

- **Do not hard-delete** anything that might be needed later.
- If something is “possibly deletable” or “needs review”, **move it here** and record the move in:
  - `move_log.jsonl` (append-only, machine-readable)
  - `dependency_ledger.md` and `dependency_ledger.json` (two-way dependency notes)

## How to use

For every moved file/folder, record:

- **Inbound references (who depends on it)**: imports, scripts, CI workflows, docs links, build configs.
- **Outbound references (what it depends on)**: imports/exports, linked docs, called scripts, declared deps.

## Review flow (before deleting anything permanently)

1. Review the moved items + the dependency ledger.
2. Decide:
   - Keep (move to canonical home, e.g. `docs/_archive/...`)
   - Delete (only after review)
3. Update the ledger with the decision and date.

## review before deletion

This folder is a quarantine area for repository cleanup.

### Rules
- We **do not delete** questionable files/folders immediately.
- Anything that seems removable, duplicative, “AI slop”, or obsolete gets **moved here first**.
- Every move must be logged (two-way dependencies) so we can restore items safely.

### What to look for when reviewing
- **Is it needed for build/runtime?**
- **Is it needed for tests/CI?**
- **Is it referenced by documentation, scripts, or tooling?**
- **Is it valuable historical context that should be archived instead?**

### Logs
- `move_log.jsonl`: append-only list of moved items.
- `dependency_ledger.md` / `dependency_ledger.json`: inbound/outbound dependency notes per moved item.

