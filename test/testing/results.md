# SPOTS Manual Testing Results

| Test Area         | Steps Taken | Expected Result | Actual Result | Pass/Fail | Notes/Screenshots |
|-------------------|-------------|-----------------|--------------|-----------|-------------------|
| Onboarding        | Launched app, completed all steps | User lands on main app, baseline lists created | As expected | Pass |  |
| Spot Creation     | Created spot from Lists tab | Spot appears in Spots tab | As expected | Pass |  |
| Offline Mode      | Disabled network, created spot | Spot saved locally, syncs when online | As expected | Pass |  |
| Homebase Selection | Fixed center marker, thoroughfare extraction | Shows specific street names (6th Ave) instead of boroughs | ✅ PASS | Fixed center marker works, thoroughfare extraction successful | homebase_selection_debug_logs.txt |

*Add more rows as you test. Attach screenshots or detailed notes for any failures or issues.* 