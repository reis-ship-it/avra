# Master Plan - Execution Index (Condensed)

**Created:** January 1, 2026  
**Status:** 🎯 Active Execution Plan  
**Purpose:** Single source of truth for implementation order (condensed index)  
**Canonical status/progress:** `docs/agents/status/status_tracker.md`  
**Detailed appendix:** `docs/MASTER_PLAN_APPENDIX.md`

---

## 📐 **Notation System**

All work is organized using **Phase.Section.Subsection** notation:

- **Phase X**: major milestone (e.g., Phase 8: Onboarding Pipeline Fix)
- **Section Y**: work unit within phase (e.g., Section 8.3)
- **Subsection Z**: specific task within section (e.g., 8.3.2)

Shorthand:
- `X.Y.Z` (e.g., `8.3.2`)
- `X.Y` (e.g., `8.3`)
- `X` (e.g., `8`)

---

## 🚪 **Philosophy + Methodology (Non‑Negotiable)**

- **Doors, not badges**: every phase must answer: What doors? When ready? Good key? Learning?
- **40-minute context protocol**: read plans + search existing implementations before building.
- **Architecture**: ai2ai only (never p2p), offline-first, self-improving.
- **Packaging**: build packagable code with clear APIs (see integration guide).

**Required references:**
- `docs/plans/philosophy_implementation/DOORS.md`
- `OUR_GUTS.md`
- `docs/plans/philosophy_implementation/SPOTS_PHILOSOPHY_AND_ARCHITECTURE.md`
- `docs/plans/methodology/DEVELOPMENT_METHODOLOGY.md`
- `docs/plans/methodology/MASTER_PLAN_INTEGRATION_GUIDE.md`

---

## 🧭 **How to Use This File**

This file answers **“what’s next and where do I go?”** (ordering + pointers).

For “what’s done / in progress / blocked”, use **only**:
- `docs/agents/status/status_tracker.md`

For full phase/section writeups, formulas, and long specs:
- `docs/MASTER_PLAN_APPENDIX.md`

---

## 🔄 **Parallel Execution (Tier-Aware)**

Use tiers to run phases in parallel when dependencies allow.

- **Tier 0**: blocks many others → must complete first
- **Tier 1**: independent → can run in parallel
- **Tier 2**: dependent → can run in parallel once deps satisfied
- **Tier 3**: advanced → last tier

**Coordination rules (high-level):**
- Use service locking/versioning before breaking changes.
- Run integration checkpoints between tiers.

---

## 📅 **Execution Index (Phases)**

This is the phase index and dependency map. Detailed specs live in the appendix and per-feature plan docs.

| Phase | Name | Tier | Primary plan doc | Key dependencies |
|------:|------|------|------------------|------------------|
| 1 | MVP Core Functionality | N/A (historical) | [`MASTER_PLAN_APPENDIX.md#phase-1-mvp-core-functionality-sections-1-4`](./MASTER_PLAN_APPENDIX.md#phase-1-mvp-core-functionality-sections-1-4) | None |
| 2 | Post-MVP Enhancements | N/A (historical) | [`MASTER_PLAN_APPENDIX.md#phase-2-post-mvp-enhancements-sections-5-8`](./MASTER_PLAN_APPENDIX.md#phase-2-post-mvp-enhancements-sections-5-8) | Phase 1 |
| 3 | Advanced Features | N/A (historical) | [`MASTER_PLAN_APPENDIX.md#phase-3-advanced-features-sections-9-12`](./MASTER_PLAN_APPENDIX.md#phase-3-advanced-features-sections-9-12) | Phase 2 |
| 4 | Testing & Integration | N/A (historical) | [`MASTER_PLAN_APPENDIX.md#phase-4-testing--integration-sections-13-14`](./MASTER_PLAN_APPENDIX.md#phase-4-testing--integration-sections-13-14) | Phases 1–3 |
| 4.5 | Profile Enhancements | N/A (historical) | [`MASTER_PLAN_APPENDIX.md#phase-45-profile-enhancements-section-15`](./MASTER_PLAN_APPENDIX.md#phase-45-profile-enhancements-section-15) | Phase 4 |
| 5 | Operations & Compliance | Policy-gated | [`plans/operations_compliance/OPERATIONS_COMPLIANCE_PLAN.md`](./plans/operations_compliance/OPERATIONS_COMPLIANCE_PLAN.md) | Post‑MVP adoption trigger |
| 6 | Local Expert System Redesign | N/A (historical) | [`plans/expertise_system/LOCAL_EXPERT_SYSTEM_IMPLEMENTATION_PLAN.md`](./plans/expertise_system/LOCAL_EXPERT_SYSTEM_IMPLEMENTATION_PLAN.md) | Phase 2 foundations |
| 7 | Feature Matrix Completion | N/A (historical) | [`plans/feature_matrix/FEATURE_MATRIX_COMPLETION_PLAN.md`](./plans/feature_matrix/FEATURE_MATRIX_COMPLETION_PLAN.md) | Phases 1–6 |
| 8 | Onboarding Process Plan (pipeline fix) | Tier 0 | [`plans/onboarding/ONBOARDING_PROCESS_PLAN.md`](./plans/onboarding/ONBOARDING_PROCESS_PLAN.md) | Foundation identity + onboarding flow |
| 9 | Test Suite Update Addendum | Tier 1 | [`plans/test_suite_update/TEST_SUITE_UPDATE_ADDENDUM.md`](./plans/test_suite_update/TEST_SUITE_UPDATE_ADDENDUM.md) | Phase 8 (logical), stable APIs |
| 10 | Social Media Integration | Tier 1 | [`plans/social_media_integration/SOCIAL_MEDIA_INTEGRATION_PLAN.md`](./plans/social_media_integration/SOCIAL_MEDIA_INTEGRATION_PLAN.md) | Phase 8 (agentId) |
| 11 | User‑AI Interaction Update | Tier 1 | [`plans/user_ai_interaction/USER_AI_INTERACTION_UPDATE_PLAN.md`](./plans/user_ai_interaction/USER_AI_INTERACTION_UPDATE_PLAN.md) | Phase 8 |
| 12 | Neural Network Implementation | Tier 1 | [`plans/neural_network/NEURAL_NETWORK_IMPLEMENTATION_PLAN.md`](./plans/neural_network/NEURAL_NETWORK_IMPLEMENTATION_PLAN.md) | None (parallel OK) |
| 13 | Itinerary Calendar Lists | Tier 1 | [`plans/itinerary_calendar_lists/ITINERARY_CALENDAR_LISTS_PLAN.md`](./plans/itinerary_calendar_lists/ITINERARY_CALENDAR_LISTS_PLAN.md) | Phase 8 (baseline lists / generator) |
| 14 | Signal Protocol Implementation | Tier 1 | [`plans/security_implementation/PHASE_14_IMPLEMENTATION_PLAN.md`](./plans/security_implementation/PHASE_14_IMPLEMENTATION_PLAN.md) | Phase 8 (agentId) |
| 15 | Reservation System | Tier 1 | [`plans/reservations/RESERVATION_SYSTEM_IMPLEMENTATION_PLAN.md`](./plans/reservations/RESERVATION_SYSTEM_IMPLEMENTATION_PLAN.md) | agentId + event identity contracts |
| 16 | Archetype Template System | Tier 1 | [`plans/personality_initialization/ARCHETYPE_TEMPLATE_SYSTEM_PLAN.md`](./plans/personality_initialization/ARCHETYPE_TEMPLATE_SYSTEM_PLAN.md) | Phase 8 |
| 17 | Complete Model Deployment | Tier 2 | [`plans/ml_models/COMPLETE_MODEL_DEPLOYMENT_PLAN.md`](./plans/ml_models/COMPLETE_MODEL_DEPLOYMENT_PLAN.md) | Runs in parallel; long-horizon |
| 18 | White‑Label & VPN/Proxy Infrastructure | Tier 2 | [`plans/white_label/WHITE_LABEL_VPN_PROXY_PLAN.md`](./plans/white_label/WHITE_LABEL_VPN_PROXY_PLAN.md) | Phase 14 + Phase 8 identity |
| 19 | Multi‑Entity Quantum Entanglement Matching | Tier 2 | [`plans/multi_entity_quantum_matching/MULTI_ENTITY_QUANTUM_ENTANGLEMENT_MATCHING_IMPLEMENTATION_PLAN.md`](./plans/multi_entity_quantum_matching/MULTI_ENTITY_QUANTUM_ENTANGLEMENT_MATCHING_IMPLEMENTATION_PLAN.md) | Phase 8.4 (Quantum Vibe Engine) |
| 20 | AI2AI Network Monitoring & Admin | Tier 3 | [`plans/ai2ai_network_monitoring/AI2AI_NETWORK_MONITORING_IMPLEMENTATION_PLAN.md`](./plans/ai2ai_network_monitoring/AI2AI_NETWORK_MONITORING_IMPLEMENTATION_PLAN.md) | Phase 18 |
| 21 | E‑Commerce Data Enrichment POC | Tier 1 | [`plans/ecommerce_integration/ECOMMERCE_DATA_ENRICHMENT_POC_PLAN.md`](./plans/ecommerce_integration/ECOMMERCE_DATA_ENRICHMENT_POC_PLAN.md) | Data contracts + network hooks |
| 22 | Outside Data‑Buyer Insights (DP export) | Tier 1 | [`plans/architecture/OUTSIDE_DATA_BUYER_INSIGHTS_DATA_CONTRACT_V1.md`](./plans/architecture/OUTSIDE_DATA_BUYER_INSIGHTS_DATA_CONTRACT_V1.md) | Interaction events + API keys + audit logs |
| 23 | AI2AI Walk‑By BLE Optimization (continuous scan + hot‑path latency + Event Mode broadcast-first) | Tier 1 | [`plans/offline_ai2ai/OFFLINE_AI2AI_IMPLEMENTATION_PLAN.md`](./plans/offline_ai2ai/OFFLINE_AI2AI_IMPLEMENTATION_PLAN.md) | Phase 14 (Signal) + BLE background runtime |
| 24 | Web App ↔ Phone LLM Sync Hub (+ Business/Admin/Enterprise Extensions) | Tier 2 | [`plans/web_phone_sync/WEB_PHONE_LLM_SYNC_PLAN.md`](./plans/web_phone_sync/WEB_PHONE_LLM_SYNC_PLAN.md) | Phase 12 (Neural Network) + Phase 17 (Model Deployment) |
| 25 | Native Desktop Platform (3rd-Party GUI + Enhanced Sync Hub) | Tier 2 | [`plans/native_desktop/NATIVE_DESKTOP_PLATFORM_PLAN.md`](./plans/native_desktop/NATIVE_DESKTOP_PLATFORM_PLAN.md) | Phase 24 (Web Sync) + Phase 18 (White-Label) + Phase 20 (Network Monitoring) |
| 26 | Toast Restaurant Technology Integration | Tier 1 | [`plans/restaurant_integrations/TOAST_INTEGRATION_PLAN.md`](./plans/restaurant_integrations/TOAST_INTEGRATION_PLAN.md) | Phase 15 (Reservations) + Phase 21 (E-Commerce Data) + Phase 4 (Quantum Matching) |

---

## 🔎 Recent execution references (where to read what happened)

These are **reference artifacts** for recent cross-cutting work (not a status dashboard):
- **AI learning journey map (install → long-horizon)**: `docs/agents/guides/AI_LEARNING_USER_JOURNEY_MAP.md`
- **AI learning journey implementation log (planned → real)**: `docs/agents/reports/agent_cursor/phase_8/2026-01-02_ai_learning_journey_plan_execution_complete.md`
- **Architecture Stabilization + Repo Hygiene (Store-ready) — package boundary DAG enforcement:** `docs/agents/reports/agent_cursor/phase_4/2026-01-03_architecture_stabilization_repo_hygiene_store_ready_complete.md`
- **0.5 Ledgers (v0) — Shared append-only journal (Supabase + writers + smoke test)**:
  - Docs: `docs/plans/ledgers/LEDGERS_V0_INDEX.md`
  - DB: `supabase/migrations/058_ledgers_v0.sql` (+ recursion fix via `ledgers_v0_rls_recursion_fix`)
  - Client: `lib/core/services/ledgers/ledger_recorder_service_v0.dart` (debug-only `debugWriteAndVerifyImmediate()`), `tool/ledger_smoke.dart`

## 📚 Appendix

The full, detailed writeups remain here:
- `docs/MASTER_PLAN_APPENDIX.md`

