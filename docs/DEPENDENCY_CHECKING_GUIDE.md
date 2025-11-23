# Dependency Checking Guide - For All Agents

**Date:** November 22, 2025, 8:40 PM CST  
**Purpose:** How agents check dependencies and communicate completion  
**Status:** 🟢 Active

---

## 🎯 **How Dependency Checking Works**

### **Step 1: Before Starting Any Task**
**ALWAYS check:** `docs/AGENT_STATUS_TRACKER.md`

1. **Read the file** to see current status
2. **Check "Dependency Map"** - see what you depend on
3. **Check "Blocked Tasks"** - see if you're blocked
4. **Check "Completed Work"** - see if dependencies are ready

### **Step 2: If You're Blocked**
1. **Add yourself to "Blocked Tasks"** section
2. **List what you're waiting for**
3. **Check status tracker regularly** (every time you start work)
4. **When dependency is ready**, remove from blocked and proceed

### **Step 3: When You Complete Work Others Depend On**
1. **Update "Completed Work"** section
2. **Update "Dependency Map"** - mark dependency as ready
3. **Remove from "Blocked Tasks"** if it unblocks others
4. **Update your status** in the tracker

---

## 📋 **Example: Agent 2 Checking for Payment Models**

### **Scenario:**
Agent 2 needs Payment Models (Agent 1 Section 2) to build Payment UI.

### **Step 1: Check Status Tracker**
```
Read: docs/AGENT_STATUS_TRACKER.md

Check "Dependency Map":
- Agent 1 → Agent 2: Payment Models
- Status: ⏳ Waiting

Check "Completed Work":
- Agent 1 Completed Sections:
  - Section 1 ✅
  - Section 2 ❌ (not listed = not ready)

Check "Blocked Tasks":
- Agent 2: Payment UI
- Blocked By: Agent 1 Section 2
```

### **Step 2: Decision**
- **If Section 2 NOT in "Completed Work"** → You're blocked, wait
- **If Section 2 IS in "Completed Work"** → Dependency ready, proceed

### **Step 3: If Blocked**
```
Update "Blocked Tasks":
- Agent 2: Payment UI (Section 2)
- Blocked By: Agent 1 Section 2 (Payment Models)
- Status: ⏳ Waiting
- Action: Check Agent 1 status regularly
```

### **Step 4: When Dependency Ready**
```
Agent 1 updates status tracker:
- Moves Section 2 to "Completed Work"
- Updates "Dependency Map" to ✅ READY

Agent 2 sees update:
- Removes from "Blocked Tasks"
- Proceeds with Payment UI
```

---

## 📋 **Example: Agent 1 Signaling Completion**

### **Scenario:**
Agent 1 completes Payment Models (Section 2) that Agent 2 needs.

### **Step 1: Complete the Work**
- Finish Section 2: Payment Models
- Verify all deliverables complete
- Test the models work

### **Step 2: Update Status Tracker**
```
Update "Agent 1 Completed Sections":
- Section 1 - Stripe Integration ✅ COMPLETE
- Section 2 - Payment Models ✅ COMPLETE  ← ADD THIS

Update "Dependency Map":
- Agent 1 → Agent 2: Payment Models ✅ READY  ← UPDATE THIS

Update "Blocked Tasks":
- Remove "Agent 2: Payment UI" from blocked  ← REMOVE THIS
```

### **Step 3: Update Your Status**
```
Agent 1 Status:
- Current Section: Section 3 - Payment Service
- Ready For Others: ✅ Section 2 (Payment Models) ready
```

---

## 🔍 **How to Check if You're Blocked**

### **Quick Check Process:**

1. **Read your task** in `docs/AGENT_TASK_ASSIGNMENTS.md`
2. **Check for dependencies** (marked with ⚠️)
3. **Read `docs/AGENT_STATUS_TRACKER.md`**
4. **Check "Dependency Map"** for your dependencies
5. **Check "Completed Work"** - is dependency listed?
6. **If NOT listed** → You're blocked, wait
7. **If listed** → Dependency ready, proceed

### **Example Dependencies:**

**Agent 2 needs:**
- ⚠️ Payment Models (Agent 1 Section 2) → Check status tracker
- ⚠️ Payment Service (Agent 1 Section 3) → Check status tracker

**Agent 3 needs:**
- ⚠️ All MVP features (Phase 4) → Check phase completion status

---

## 📞 **Communication Protocol**

### **When You Complete Work Others Depend On:**

1. **Immediately update** `docs/AGENT_STATUS_TRACKER.md`
2. **Move to "Completed Work"** section
3. **Update "Dependency Map"** - mark as ready
4. **Remove from "Blocked Tasks"** if it unblocks others

### **When You're Blocked:**

1. **Add to "Blocked Tasks"** section
2. **List what you're waiting for**
3. **Check status tracker regularly** (before each work session)
4. **When dependency ready**, proceed immediately

### **When Checking Dependencies:**

1. **Always check** `docs/AGENT_STATUS_TRACKER.md` first
2. **Before starting any task** that has dependencies
3. **If unclear**, check the dependency map

---

## ✅ **Dependency Checklist**

### **Before Starting Work:**
- [ ] Read `docs/AGENT_STATUS_TRACKER.md`
- [ ] Check "Dependency Map" for your dependencies
- [ ] Check "Completed Work" - are dependencies ready?
- [ ] Check "Blocked Tasks" - are you blocked?
- [ ] If blocked, wait; if not, proceed

### **When Completing Work:**
- [ ] Verify all deliverables complete
- [ ] Update "Completed Work" section
- [ ] Update "Dependency Map" if others depend on it
- [ ] Remove from "Blocked Tasks" if it unblocks others
- [ ] Update your status

### **Regular Checks:**
- [ ] Check status tracker before each work session
- [ ] Check if dependencies are ready
- [ ] Update your progress
- [ ] Signal completion of work others depend on

---

## 🎯 **Key Rules**

1. **ALWAYS check status tracker** before starting work with dependencies
2. **ALWAYS update status tracker** when completing work others depend on
3. **ALWAYS signal completion** immediately (don't wait)
4. **ALWAYS check regularly** if you're blocked
5. **NEVER proceed** if dependency not ready (check status tracker)

---

**Last Updated:** November 22, 2025  
**Status:** Ready for Use

