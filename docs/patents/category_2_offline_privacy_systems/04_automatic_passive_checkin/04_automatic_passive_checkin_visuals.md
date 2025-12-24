# Automatic Passive Check-In System - Visual Documentation

**Patent Innovation #14**  
**Category:** Offline-First & Privacy-Preserving Systems

---

## Visual Diagrams and Flowcharts

### 1. Dual-Trigger Verification Flow

```
User Approaches Location
    │
    ├─→ Trigger 1: Geofencing
    │       │
    │       ├─→ Check: Within 50m radius?
    │       │
    │       ├─→ YES → Geofence Triggered ✅
    │       └─→ NO → Wait
    │
    ├─→ Trigger 2: Bluetooth/AI2AI
    │       │
    │       ├─→ Check: Bluetooth proximity detected?
    │       │
    │       ├─→ YES → Bluetooth Triggered ✅
    │       └─→ NO → Wait
    │
    └─→ Both Triggers Confirmed?
            │
            ├─→ YES → Record Visit ✅
            │
            └─→ NO → Wait for both triggers
```

---

### 2. Geofencing Detection

```
Location Monitoring (Background)
    │
    ├─→ Continuous Location Updates
    │
    ├─→ Check: Within 50m of any spot?
    │       │
    │       ├─→ YES → Geofence Entered
    │       │       │
    │       │       └─→ Record Entry Time
    │       │
    │       └─→ NO → Continue Monitoring
    │
    └─→ Exit Detection
            │
            └─→ User leaves 50m radius
                    │
                    └─→ Record Exit Time
```

**Geofence Parameters:**
- **Radius:** 50 meters
- **Background Monitoring:** Continuous
- **Entry Detection:** When user enters radius
- **Exit Detection:** When user leaves radius

---

### 3. Bluetooth/AI2AI Proximity Verification

```
Bluetooth/AI2AI Network
    │
    ├─→ Scan for Nearby Devices
    │       │
    │       └─→ AI2AI network devices
    │
    ├─→ Check Signal Strength
    │       │
    │       └─→ Proximity estimation
    │
    ├─→ Verify Location Match
    │       │
    │       └─→ Device at target location?
    │
    └─→ Proximity Confirmed
            │
            └─→ Bluetooth Triggered ✅
```

**Bluetooth Parameters:**
- **Signal Strength:** Used for proximity estimation
- **AI2AI Network:** Uses AI2AI network for detection
- **Offline Capable:** Works without internet
- **Proximity Threshold:** Signal strength threshold

---

### 4. Dwell Time Calculation

```
Entry Time: 10:00 AM
    │
    ├─→ User Enters Geofence
    │       │
    │       └─→ Record: entryTime = 10:00 AM
    │
    ├─→ User Stays in Geofence
    │       │
    │       └─→ Continuous monitoring
    │
    ├─→ Exit Time: 10:15 AM
    │       │
    │       └─→ Record: exitTime = 10:15 AM
    │
    └─→ Calculate Dwell Time
            │
            dwellTime = exitTime - entryTime
            dwellTime = 10:15 AM - 10:00 AM = 15 minutes
            │
            └─→ Valid Visit? (≥ 5 minutes) → YES ✅
```

**Dwell Time Validation:**
- **Minimum:** 5 minutes required
- **Calculation:** `dwellTime = exitTime - entryTime`
- **Quality:** Longer dwell time = higher quality

---

### 5. Quality Score Calculation

```
Quality Score Components:
    │
    ├─→ Dwell Time Component
    │       │
    │       dwellComponent = (dwellTime / 30).clamp(0.0, 1.0)
    │       │
    │       Example: 15 minutes → 15/30 = 0.5
    │
    ├─→ Review Bonus
    │       │
    │       reviewBonus = reviewGiven ? 0.1 : 0.0
    │
    ├─→ Repeat Bonus
    │       │
    │       repeatBonus = isRepeatVisit ? 0.1 : 0.0
    │
    └─→ Detail Bonus
            │
            detailBonus = hasDetailedReview ? 0.1 : 0.0

Total Quality Score:
    quality = dwellComponent + reviewBonus + repeatBonus + detailBonus
    quality = 0.5 + 0.1 + 0.1 + 0.1 = 0.8
```

**Quality Formula:**
```
quality = (dwell_time/30) + review_bonus + repeat_bonus + detail_bonus
```

---

### 6. Complete Check-In Flow

```
START
  │
  ├─→ Background Location Monitoring
  │       │
  │       └─→ Continuous updates
  │
  ├─→ Geofence Triggered?
  │       │
  │       ├─→ YES → Record Entry Time
  │       │
  │       └─→ NO → Continue Monitoring
  │
  ├─→ Bluetooth/AI2AI Proximity Detected?
  │       │
  │       ├─→ YES → Record Proximity
  │       │
  │       └─→ NO → Wait
  │
  ├─→ Both Triggers Confirmed?
  │       │
  │       ├─→ YES → Start Visit Tracking
  │       │
  │       └─→ NO → Wait for both
  │
  ├─→ User Exits Geofence?
  │       │
  │       ├─→ YES → Record Exit Time
  │       │
  │       └─→ NO → Continue Tracking
  │
  ├─→ Calculate Dwell Time
  │       │
  │       dwellTime = exitTime - entryTime
  │
  ├─→ Valid Visit? (≥ 5 minutes)
  │       │
  │       ├─→ YES → Record Visit
  │       │
  │       └─→ NO → Discard
  │
  ├─→ Calculate Quality Score
  │       │
  │       quality = (dwell_time/30) + bonuses
  │
  └─→ Visit Recorded ✅
          │
          └─→ END
```

---

### 7. Dual-Trigger Verification Logic

```
Geofence Status          Bluetooth Status          Result
─────────────────────────────────────────────────────────
✅ Triggered              ✅ Triggered              ✅ Visit Recorded
✅ Triggered              ❌ Not Triggered          ⏳ Wait
❌ Not Triggered          ✅ Triggered              ⏳ Wait
❌ Not Triggered          ❌ Not Triggered          ⏳ Wait
```

**Verification Rule:**
- **Both must confirm** before recording visit
- **Reduces false positives** through dual verification
- **Ensures accuracy** of visit detection

---

### 8. Quality Score Examples

```
Example 1: Quick Stop
    │
    ├─→ Dwell Time: 3 minutes
    ├─→ Review: No
    ├─→ Repeat: No
    ├─→ Detail: No
    │
    └─→ Quality: 0.1 (invalid, < 5 minutes)

Example 2: Standard Visit
    │
    ├─→ Dwell Time: 15 minutes
    ├─→ Review: Yes
    ├─→ Repeat: No
    ├─→ Detail: No
    │
    └─→ Quality: 0.6 (15/30 + 0.1)

Example 3: High-Quality Visit
    │
    ├─→ Dwell Time: 30 minutes
    ├─→ Review: Yes
    ├─→ Repeat: Yes
    ├─→ Detail: Yes
    │
    └─→ Quality: 1.0 (30/30 + 0.1 + 0.1 + 0.1)
```

---

### 9. Offline Capability

```
Online System (Traditional)
    │
    ├─→ Geofencing: Requires internet
    ├─→ Verification: Cloud-based
    └─→ Recording: Cloud storage

Offline System (This Patent)
    │
    ├─→ Geofencing: Local GPS (no internet)
    ├─→ Verification: Bluetooth/AI2AI (offline)
    └─→ Recording: Local storage (sync when online)
```

**Offline Advantages:**
- **Works without internet** through Bluetooth/AI2AI
- **Local storage** for visits
- **Sync when online** (optional)

---

### 10. Complete System Architecture

```
┌─────────────────────────────────────────────────────────┐
│         BACKGROUND LOCATION MONITORING                  │
│  • Continuous GPS updates                                │
│  • 50m radius geofencing                                │
│  • Entry/exit detection                                 │
└─────────────────────────────────────────────────────────┘
                        │
                        ├─→ Geofence Triggered
                        │
                        ↓
┌─────────────────────────────────────────────────────────┐
│         BLUETOOTH/AI2AI PROXIMITY VERIFICATION        │
│  • Scan for nearby devices                              │
│  • Signal strength detection                             │
│  • Offline-capable                                      │
└─────────────────────────────────────────────────────────┘
                        │
                        ├─→ Bluetooth Triggered
                        │
                        ↓
┌─────────────────────────────────────────────────────────┐
│         DUAL-TRIGGER VERIFICATION                       │
│  • Both triggers must confirm                           │
│  • Reduces false positives                              │
└─────────────────────────────────────────────────────────┘
                        │
                        ├─→ Both Confirmed
                        │
                        ↓
┌─────────────────────────────────────────────────────────┐
│         DWELL TIME CALCULATION                          │
│  • Track entry to exit                                  │
│  • Minimum 5 minutes                                    │
└─────────────────────────────────────────────────────────┘
                        │
                        ├─→ Valid Visit
                        │
                        ↓
┌─────────────────────────────────────────────────────────┐
│         QUALITY SCORE CALCULATION                       │
│  • Dwell time component                                 │
│  • Review/repeat/detail bonuses                         │
└─────────────────────────────────────────────────────────┘
                        │
                        └─→ Visit Recorded
```

---

## Mathematical Notation Reference

### Quality Score Formula
- `quality = (dwell_time/30) + review_bonus + repeat_bonus + detail_bonus`
- `dwellComponent = (dwellTime.inMinutes / 30).clamp(0.0, 1.0)`
- `reviewBonus = reviewGiven ? 0.1 : 0.0`
- `repeatBonus = isRepeatVisit ? 0.1 : 0.0`
- `detailBonus = hasDetailedReview ? 0.1 : 0.0`

### Dwell Time Validation
- `dwellTime = exitTime - entryTime`
- `isValidVisit = dwellTime.inMinutes >= 5`

### Geofencing Parameters
- **Radius:** 50 meters
- **Background Monitoring:** Continuous

---

## Flowchart: Complete Automatic Check-In Process

```
START
  │
  ├─→ Background Location Monitoring
  │
  ├─→ Geofence Triggered? (50m radius)
  │       │
  │       ├─→ YES → Record Entry Time
  │       └─→ NO → Continue Monitoring
  │
  ├─→ Bluetooth/AI2AI Proximity Detected?
  │       │
  │       ├─→ YES → Record Proximity
  │       └─→ NO → Wait
  │
  ├─→ Both Triggers Confirmed?
  │       │
  │       ├─→ YES → Start Visit Tracking
  │       └─→ NO → Wait for both
  │
  ├─→ User Exits Geofence?
  │       │
  │       ├─→ YES → Record Exit Time
  │       └─→ NO → Continue Tracking
  │
  ├─→ Calculate Dwell Time
  │
  ├─→ Valid Visit? (≥ 5 minutes)
  │       │
  │       ├─→ YES → Record Visit
  │       └─→ NO → Discard
  │
  ├─→ Calculate Quality Score
  │
  └─→ Visit Recorded ✅
          │
          └─→ END
```

---

**Last Updated:** December 16, 2025

