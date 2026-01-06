# Dependency Ledger (Quarantine)

This ledger tracks **two-way dependencies** for anything moved into `review_before_deletion/`.

## Format (per entry)

- **Item**: path moved into quarantine
- **Reason**: why it was quarantined
- **Inbound references**: what depends on it (imports, build configs, docs links)
- **Outbound references**: what it depends on
- **Decision**: keep / move / delete (and date)

---

## Entries

### Import migration backup quarantine

- **Item**: `review_before_deletion/import_migration_backup/` (moved from `/.import_migration_backup/`)
- **Reason**: root repo cleanup; keep backups available, but out of the product surface
- **Inbound references**:
  - `scripts/update_package_imports.py` (backup output path)
  - `docs/plans/methodology/IMPORT_MIGRATION_SCRIPT_GUIDE.md` (documentation)
  - `docs/reports/refactoring_cleanup/PHASE_3_3_2_WAVE_1_COMPLETE.md` (historical note)
- **Outbound references**:
  - Contains backups produced by `scripts/update_package_imports.py`
- **Decision**: keep (quarantine) until we confirm we no longer need historical backups

### Root artifact quarantine: test.db

- **Item**: `review_before_deletion/_root/test.db` (moved from `/test.db`)
- **Reason**: generated local database artifact; remove root clutter, keep forensics
- **Inbound references**:
  - None known (tests use the string `'test.db'` as a database name, not this repo-root file)
- **Outbound references**:
  - None
- **Decision**: keep (quarantine)

### Root artifact quarantine: Runner/

- **Item**: `review_before_deletion/_root/Runner/` (moved from `/Runner/`)
- **Reason**: root-level Runner artifact; canonical iOS Runner lives under `ios/Runner/`
- **Inbound references**:
  - None known (iOS build uses `ios/Runner/Info.plist`)
- **Outbound references**:
  - Contains `Info.plist`
- **Decision**: keep (quarantine)

## Dependency ledger (two-way)

This file tracks dependencies for every item moved into `review_before_deletion/`.

### Schema (human)

For each moved item, record:
- **From**: original path
- **To**: quarantine path
- **Reason**: why it was moved (duplicate, generated artifact, obsolete, etc.)
- **Inbound references** (who depends on it)
- **Outbound references** (what it depends on)
- **Risk notes** (what could break if deleted)
- **Revert** (how to restore)

Entries will be appended as we move items.

---

### Item: /build
- **To**: `review_before_deletion/_root/build`
- **Moved at**: 2026-01-02T19:45:33-06:00
- **Reason**: Generated Flutter/Gradle build output. Already listed in `.gitignore` (`build/`) but present in the workspace.
- **Inbound references (who depends on it)**:
  - `.gitignore` ignores `build/` (signals it should not be tracked).
  - Some scripts/docs mention `build/` generically (not required for runtime; build is regenerated).
- **Outbound references (what it depends on)**:
  - N/A (generated output).
- **Risk notes**:
  - Low. Flutter/Gradle will recreate `build/` when needed.
- **Revert**:
  - Move it back: `mv review_before_deletion/_root/build build`

### Item: /logs
- **To**: `review_before_deletion/_root/logs`
- **Moved at**: 2026-01-02T19:45:33-06:00
- **Reason**: Local test output dumps (not required for building or runtime).
- **Inbound references (who depends on it)**:
  - None expected for runtime; if any scripts reference it, they should tolerate it missing.
- **Outbound references (what it depends on)**:
  - N/A (outputs).
- **Risk notes**:
  - Low. Only affects access to old logs.
- **Revert**:
  - Move it back: `mv review_before_deletion/_root/logs logs`

### Item: /Pods
- **To**: `review_before_deletion/_root/Pods`
- **Moved at**: 2026-01-02T19:45:33-06:00
- **Reason**: Root-level `Pods/` folder exists but is empty; iOS pods are normally under `ios/Pods/` (already ignored). Keeping this at repo root looks unprofessional.
- **Inbound references (who depends on it)**:
  - None known; `scripts/classify_files.sh` references `Pods/` as a classification category (not a build dependency).
- **Outbound references (what it depends on)**:
  - N/A.
- **Risk notes**:
  - Low. Does not affect CocoaPods under `ios/`.
- **Revert**:
  - Move it back: `mv review_before_deletion/_root/Pods Pods`

### Item: docs/ai2ai/07_privacy_security/SECURITY_ARCHITECTURE.md
- **To**: `review_before_deletion/docs/ai2ai/07_privacy_security/SECURITY_ARCHITECTURE.md`
- **Moved at**: 2026-01-02T19:45:33-06:00
- **Reason**: Duplicate security architecture doc (canonical lives in `docs/security/SECURITY_ARCHITECTURE.md`). We kept a stub pointer at the original path to avoid broken references.
- **Inbound references (who depends on it)**:
  - No direct path references were found in a quick repo scan; stub pointer preserves safety anyway.
- **Outbound references (what it depends on)**:
  - N/A.
- **Risk notes**:
  - Low. Documentation-only.
- **Revert**:
  - Restore content if needed by copying back from quarantine.

### Item: /tmp
- **To**: `review_before_deletion/_root/tmp`
- **Moved at**: 2026-01-02T19:45:33-06:00
- **Reason**: Workspace scratch outputs (analysis logs, generated geo SQL, one-off probes). Keeping this at repo root (tracked) looks like clutter.\n+  We will recreate an empty `tmp/` folder (or let scripts create it) so tooling doesn’t break.
- **Inbound references (who depends on it)**:
  - Several scripts reference `tmp/` paths (geo generation, integration tooling, refactor scripts).\n+    We will ensure scripts `mkdir -p` required subfolders (at minimum: geo scripts now create output dirs).
- **Outbound references (what it depends on)**:
  - N/A (outputs).
- **Risk notes**:
  - Low to moderate. Scripts expecting specific files may need to regenerate inputs; quarantined copies preserve offline recovery.
- **Revert**:
  - Move it back: `mv review_before_deletion/_root/tmp tmp`

### Item: /temp
- **To**: `review_before_deletion/_root/temp`
- **Moved at**: 2026-01-02T19:45:33-06:00
- **Reason**: Workspace scratch area; currently contains `maven_extract/libsignal-android.jar` which is a download artifact.\n+  Scripted extraction can recreate it, but keeping the quarantined copy avoids a forced re-download.
- **Inbound references (who depends on it)**:
  - `scripts/extract_signal_android_libs*.sh` uses `temp/maven_extract` as a download/extract workspace and then deletes it.
- **Outbound references (what it depends on)**:
  - N/A.
- **Risk notes**:
  - Low for app runtime. Moderate for fully-offline workflows that relied on the already-downloaded jar.
- **Revert**:
  - Move it back: `mv review_before_deletion/_root/temp temp`

### Item: /VIBE_CODING
- **To**: `docs/_archive/vibe_coding/VIBE_CODING`
- **Moved at**: 2026-01-02T20:51:27-06:00
- **Reason**: Reduce top-level repo clutter; VIBE_CODING is historical AI2AI documentation that is already migrated into `docs/ai2ai/`. Keeping it at repo root looks unprofessional.
- **Inbound references (who depends on it)**:
  - Multiple docs mention `docs/_archive/vibe_coding/VIBE_CODING/...` paths (we will update those references to `docs/ai2ai/...` when possible, otherwise to the archive path).
  - `supabase/functions/README_LLM.md` references VIBE_CODING content (needs link update).
- **Outbound references (what it depends on)**:
  - Self-contained documentation set.
- **Risk notes**:
  - Low for app runtime; moderate for doc-link integrity until references are updated.
- **Revert**:
  - Move it back: `mv docs/_archive/vibe_coding/VIBE_CODING VIBE_CODING`

