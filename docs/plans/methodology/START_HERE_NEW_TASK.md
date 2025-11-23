# ⚠️ START HERE - NEW TASK PROTOCOL ⚠️

> **🚨 MANDATORY: This document MUST be read at the start of EVERY new chat/task 🚨**

---

## 🎯 When to Use This Document

**Read this document when:**
- ✅ Starting a new chat session
- ✅ Receiving a new task or feature request
- ✅ User says "implement [feature]"
- ✅ User references a plan or phase
- ✅ Beginning any development work
- ✅ User provides a new requirement

**Trigger Phrases (Always read this document when user says):**

**Implementation triggers:**
- "implement..."
- "create..."
- "build..."
- "add..."
- "start..."
- "proceed with..."
- "continue with..."
- "let's do..."
- "work on..."

**Status/Progress triggers (requires comprehensive document search):**
- "where are we with..."
- "what's the status of..."
- "how far along..."
- "what's complete in..."
- "show me progress on..."
- "where are we [timeframe] with..."
- "update me on..."
- "what's done in..."

---

## 📋 The 40-Minute Context Protocol

**Before writing ANY code, spend 40 minutes on context:**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ⏰ TIME INVESTMENT: 40 minutes                            │
│  💰 TIME SAVED: 50-90% of implementation time              │
│  📊 PROVEN ROI: Saves hours to days of work                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Special Protocol: Status/Progress Queries

**When user asks about status, progress, or completion:**

### Examples of Status Queries:
- "Where are we with week 1 of plan X?"
- "What's the status of Phase 2.1?"
- "How far along are we with federated learning?"
- "Show me progress on the implementation plan"
- "What's complete in Phase 1?"

### ⚠️ CRITICAL: Read ALL Related Documents

**DO NOT just read one document. You MUST read ALL related documents:**

```bash
# Example: User asks "Where are we with week 1 of plan X?"

# ❌ WRONG - Reading only one document:
read_file('docs/week_1_plan.md')
# → Incomplete context! Missing completion/progress docs

# ✅ CORRECT - Comprehensive search:

# 1. Find ALL documents mentioning "week 1"
glob_file_search('**/*week*1*.md')
glob_file_search('**/*week_1*.md')

# 2. Also search for related keywords
grep('week 1', path: 'docs/', output_mode: 'files_with_matches')
grep('Week 1', path: 'docs/', output_mode: 'files_with_matches')

# 3. Read ALL found documents:
read_file('docs/week_1_plan.md')           # The plan
read_file('docs/week_1_complete.md')       # Completion doc
read_file('docs/week_1_progress.md')       # Progress doc
read_file('docs/week_1_status_update.md')  # Status update
# ... and any other related docs

# 4. Check completion documents
glob_file_search('**/*COMPLETE*.md')
# Read any that mention "week 1"

# 5. Check progress documents
glob_file_search('**/*PROGRESS*.md')
# Read any that mention "week 1"
```

### Required Document Types to Check:

For ANY status query, search for and read ALL of these document types:

1. **Plan Documents**
   ```bash
   glob_file_search('**/*[topic]_plan*.md')
   glob_file_search('**/*[topic]*plan*.md')
   ```

2. **Completion Documents**
   ```bash
   glob_file_search('**/*[topic]*complete*.md')
   glob_file_search('**/*[topic]*COMPLETE*.md')
   glob_file_search('**/*SECTION*[topic]*.md')
   ```

3. **Progress Documents**
   ```bash
   glob_file_search('**/*[topic]*progress*.md')
   glob_file_search('**/*[topic]*PROGRESS*.md')
   ```

4. **Status Documents**
   ```bash
   glob_file_search('**/*[topic]*status*.md')
   glob_file_search('**/*[topic]*update*.md')
   ```

5. **Summary Documents**
   ```bash
   glob_file_search('**/*[topic]*summary*.md')
   glob_file_search('**/*[topic]*SUMMARY*.md')
   ```

### Status Query Protocol (Mandatory Steps):

```
User asks: "Where are we with [topic]?"
    ↓
Step 1: Find ALL documents (5 min)
├─ Search by filename: glob_file_search('**/*[topic]*.md')
├─ Search by content: grep('[topic]', path: 'docs/')
└─ Find ALL related: plan, complete, progress, status, summary
    ↓
Step 2: Read ALL found documents (10-15 min)
├─ Read plan document(s)
├─ Read completion document(s)
├─ Read progress document(s)
├─ Read status document(s)
└─ Read summary document(s)
    ↓
Step 3: Synthesize Complete Picture (5 min)
├─ What was planned?
├─ What's complete?
├─ What's in progress?
├─ What's remaining?
├─ Any blockers?
└─ Timeline status?
    ↓
Step 4: Present Comprehensive Answer
├─ Status: [Complete/In Progress/Not Started]
├─ Completed items: [List]
├─ In progress items: [List]
├─ Remaining items: [List]
├─ Timeline: [On track/Ahead/Behind]
└─ Next steps: [What's next]
```

### Example: Comprehensive Status Response

**User asks:** "Where are we with Phase 2.1?"

**❌ BAD Response (Single Document):**
```
I read FEATURE_MATRIX_COMPLETION_PLAN.md.
Phase 2.1 shows: Backend ✅, UI ❌ 0%
```
→ Incomplete! Might have been completed since plan was written.

**✅ GOOD Response (All Documents):**
```
📋 Comprehensive Status for Phase 2.1

Documents Reviewed:
- FEATURE_MATRIX_COMPLETION_PLAN.md (Plan)
- FEATURE_MATRIX_SECTION_2_1_COMPLETE.md (Completion)
- PHASE_2_PROGRESS_SUMMARY.md (Progress)

Status: ✅ COMPLETE

What Was Planned:
- 4 widgets: Settings, Status, Metrics, History
- Estimated: 11 days

What's Complete:
✅ All 4 widgets implemented (43K+ lines)
✅ Integrated into app (navigation + links)
✅ Tests written (5 test files)
✅ Documentation complete

Timeline:
- Planned: 11 days
- Actual: 1 hour (found existing work)
- Completed: [date]

Next Steps:
→ Phase 2.1 is complete
→ Can proceed to Phase 2.2 or next priority
```

### Red Flags for Status Queries:

**🚨 STOP if you find yourself:**
- [ ] Reading only one document for status query
- [ ] Not searching for completion documents
- [ ] Not searching for progress documents
- [ ] Answering based on plan alone (plan might be outdated)
- [ ] Missing "COMPLETE" or "PROGRESS" documents
- [ ] Not checking if work was completed after plan was written

**If ANY red flag triggered:** Go back and search comprehensively.

### Search Pattern Template:

```bash
# User asks about: [TOPIC]

# Replace [TOPIC] with actual topic (lowercase and variations)
TOPIC="topic_name"

# 1. Broad filename search
glob_file_search("**/*${TOPIC}*.md")
glob_file_search("**/*$(echo $TOPIC | tr '[:lower:]' '[:upper:]')*.md")

# 2. Content search
grep("$TOPIC", path: "docs/", output_mode: "files_with_matches")

# 3. Specific document types
glob_file_search("**/*${TOPIC}*plan*.md")
glob_file_search("**/*${TOPIC}*complete*.md")
glob_file_search("**/*${TOPIC}*progress*.md")
glob_file_search("**/*${TOPIC}*status*.md")
glob_file_search("**/*${TOPIC}*summary*.md")

# 4. Related searches
grep("Phase X.Y", path: "docs/")  # If topic is a phase
grep("Week X", path: "docs/")     # If topic is a week
grep("Section X", path: "docs/")  # If topic is a section

# 5. Read ALL found documents
# Then synthesize comprehensive answer
```

---

## 🚀 7-Step Mandatory Protocol

### ☑️ Step 1: Read Methodology (2 min)
```
✅ I have read START_HERE_NEW_TASK.md
✅ I will reference SESSION_START_CHECKLIST.md
✅ I will follow DEVELOPMENT_METHODOLOGY.md
```

**Action:**
```bash
read_file('docs/SESSION_START_CHECKLIST.md')
```

### ☑️ Step 2: Understand Task (5 min)
- [ ] Read user request completely
- [ ] Identify primary goal
- [ ] Note specific requirements
- [ ] Determine task type (new/enhancement/bug/integration)

### ☑️ Step 3: Discover ALL Plans (5 min)
**CRITICAL - Find everything before reading anything**

```bash
# Find ALL plans (comprehensive discovery)
glob_file_search('**/*plan*.md')
glob_file_search('**/*PLAN*.md')
glob_file_search('**/*roadmap*.md')
glob_file_search('**/*strategy*.md')
glob_file_search('**/*transition*.md')
glob_file_search('**/*implementation*.md')

# Check modification dates
run_terminal_cmd('ls -lht docs/*plan*.md | head -20')
```

### ☑️ Step 4: Intelligent Filtering (5 min)
**Apply the Recency × Relevance Matrix**

```bash
# Check relevance (does plan mention task?)
grep('task_keyword', path: 'docs/', output_mode: 'files_with_matches')

# Categorize by age
Recent (<7d)     → HIGH PRIORITY
Moderate (7-30d) → MEDIUM PRIORITY
Old (30-90d)     → LOW PRIORITY
Historical (>90d)→ REFERENCE ONLY

# Apply Decision Matrix:
Recent + High Relevance    → READ (5 min each)
Recent + Medium Relevance  → SKIM (2 min)
Old + High Relevance       → SKIM (2 min)
Old + Low Relevance        → SKIP
```

### ☑️ Step 5: Read Plans in Priority Order (10 min)
```bash
# 1. Master plan (always read)
read_file('docs/FEATURE_MATRIX_COMPLETION_PLAN.md')

# 2. High-relevance plans (filtered from Step 4)
read_file('[relevant_plan_1].md')
read_file('[relevant_plan_2].md')

# 3. Check completion docs
glob_file_search('**/*COMPLETE*.md')
```

**Watch for:**
- ⚠️ Conflicts (same feature, different specs)
- ⚠️ Dependencies (what must be done first)
- ⚠️ Timeline issues
- ⚠️ Deprecated plans

### ☑️ Step 6: Search Existing Work (5 min)
```bash
# Search for existing implementations
glob_file_search('**/*feature_name*.dart')
grep('class.*FeatureName', path: 'lib/')
codebase_search('How does [similar feature] work?')

# Check if already exists
list_dir('lib/presentation/widgets/[feature_area]/')
```

### ☑️ Step 7: Create & Communicate Plan (8 min)
```dart
// Create TODO list
todo_write(
  merge: false,
  todos: [
    {"id": "1", "status": "in_progress", "content": "Context gathering"},
    {"id": "2", "status": "pending", "content": "Component A"},
    {"id": "3", "status": "pending", "content": "Integration"},
    {"id": "4", "status": "pending", "content": "Testing"},
    {"id": "5", "status": "pending", "content": "Documentation"},
  ]
)
```

**Then communicate:**
```
📋 Context Gathering Complete

Plans Analyzed:
- Primary: [plan name] (Phase X.Y)
- Supporting: [plan names]

Existing Work:
- Found: [X/Y components complete]
- Missing: [list]

Approach:
1. [Strategy based on context]
2. [Leverage existing work]
3. [Fill gaps]

Timeline:
- Estimated: [X hours]
- Original plan: [Y days]
- Time saved: [Z%]

Risks/Conflicts:
- [None detected / List]

Ready to proceed?
```

---

## 🚨 Red Flags - STOP and Clarify

**If you encounter any of these, STOP and ask for clarification:**

- [ ] Can't find main plan document
- [ ] Task conflicts with existing plan
- [ ] Multiple plans with contradictory specs
- [ ] Unclear where code should be placed
- [ ] Don't understand data models/backend
- [ ] Can't determine dependencies
- [ ] Found existing implementation but specs differ
- [ ] Timeline conflicts detected

**DO NOT proceed until clarified.**

---

## ✅ Checklist Before Starting Implementation

**Only proceed when you can check ALL of these:**

- [ ] I have read START_HERE_NEW_TASK.md ✅
- [ ] I have discovered ALL relevant plans
- [ ] I have filtered plans by recency + relevance
- [ ] I have read the master plan
- [ ] I have read high-priority related plans
- [ ] I have checked for conflicts (none found or resolved)
- [ ] I have searched for existing implementations
- [ ] I understand the data models/backend
- [ ] I know where code should be placed
- [ ] I have created a detailed TODO list
- [ ] I have communicated my plan to the user
- [ ] User has approved the approach

**If ANY checkbox is unchecked, DO NOT START CODING.**

---

## 📊 Success Metrics (From Real Implementation)

**Proof this works:**

| Phase | Context Time | Implementation Time | Original Estimate | Time Saved |
|-------|--------------|---------------------|-------------------|------------|
| Phase 1 Integration | 40 min | 4 hours | 5 days | **99%** |
| Optional Enhancements | 30 min | 1 session | 3-5 days | **85%** |
| Phase 2.1 | 20 min | 1 hour | 11 days | **99.5%** |

**Average: 40 minutes → Save 50-90% implementation time**

---

## 🎓 Why This Protocol Exists

### Problems Without Protocol:
- ❌ Build duplicate code (waste days)
- ❌ Miss existing implementations
- ❌ Wrong architecture/placement
- ❌ Conflicts discovered late (rework)
- ❌ Incomplete understanding (bugs)
- ❌ No integration plan (isolated code)

### Benefits With Protocol:
- ✅ Find and reuse existing code
- ✅ Optimal architecture from start
- ✅ Catch conflicts early
- ✅ Complete context
- ✅ Clear integration path
- ✅ 50-90% time savings

---

## 📖 Reference Documents

**Quick Links:**
- **This Document:** `docs/START_HERE_NEW_TASK.md` ← You are here
- **Quick Reference:** `docs/SESSION_START_CHECKLIST.md`
- **Full Methodology:** `docs/DEVELOPMENT_METHODOLOGY.md`
- **Master Plan:** `docs/FEATURE_MATRIX_COMPLETION_PLAN.md`

---

## 🔄 How to Ensure This is Always Followed

### For AI Assistant:
1. **Always check for this file** when starting new task
2. **Read it first** before any implementation
3. **Follow the 7-step protocol** systematically
4. **Do not skip steps** to save time (it costs more later)

### For User:
Add this to your system instructions or project README:

```markdown
## Development Protocol

**For AI Assistants:**
At the start of EVERY new task, you MUST:
1. Read `docs/START_HERE_NEW_TASK.md`
2. Follow the 40-minute context protocol
3. Complete all 7 steps before coding
4. Get user approval before proceeding

**Trigger phrases:**
When user says "implement", "build", "create", "add", "start", 
"proceed with", or "continue with" - read START_HERE_NEW_TASK.md first.
```

### Recommended System Message:
```
When starting any new development task, always begin by reading 
docs/START_HERE_NEW_TASK.md and following the 7-step protocol. 
Do not skip context gathering. The 40-minute investment saves 
hours to days of implementation time.
```

---

## 🎯 Quick Start (TL;DR)

```
New task received
    ↓
Read START_HERE_NEW_TASK.md (this file)
    ↓
Follow 7-step protocol (40 min)
    ↓
Communicate plan to user
    ↓
Get approval
    ↓
Begin implementation
```

**Do NOT skip to implementation. Context gathering is mandatory.**

---

## ⚡ The Golden Rule

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║  40 minutes of context gathering                         ║
║  saves                                                    ║
║  40 hours of implementation                              ║
║                                                           ║
║  ALWAYS invest the 40 minutes.                           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 📝 Document Status

**File:** `docs/START_HERE_NEW_TASK.md`  
**Purpose:** Entry point for every new task  
**Status:** Active - Mandatory reference  
**Last Updated:** November 21, 2025  
**Version:** 1.0

---

## ✅ Confirmation

**Before proceeding with any task, confirm:**

```
✅ I have read START_HERE_NEW_TASK.md
✅ I have completed the 40-minute context protocol
✅ I have followed all 7 steps
✅ I have communicated my plan
✅ I have user approval

Now I am ready to implement.
```

**If you cannot check all boxes, you are NOT ready to proceed.**

---

**🚨 REMEMBER: Read this document at the start of EVERY new task 🚨**

