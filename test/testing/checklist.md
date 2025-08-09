# SPOTS Manual Testing Checklist

## 1. Onboarding Flow
- [ ] Launch app as a new user
- [ ] Complete Homebase selection (map-based)
- [ ] Complete Favorite Places selection
- [ ] Complete Preference Survey (categories per area)
- [ ] Add friends & Respect a list
- [ ] Verify baseline lists (Chill, Fun, Classic) are auto-created
- [ ] Skip each onboarding step and verify app behavior
- [ ] Edit onboarding selections before completion
- [ ] Complete onboarding and land on main app

## 2. Spot Creation
- [ ] Create a spot from the main entry point
- [ ] Create a spot from the Lists tab
- [ ] Add spot details (name, location, category, description)
- [ ] Use current location for spot
- [ ] Search for a location when creating a spot
- [ ] View created spot in Spots tab

## 3. List Management
- [ ] Create a new list
- [ ] Edit a list (title, description)
- [ ] Delete a list
- [ ] Add a spot to a list
- [ ] Remove a spot from a list
- [ ] Verify baseline lists are present after onboarding
- [ ] Attempt to delete a baseline list (should not be possible)

## 4. Map Features
- [ ] Map loads on Map tab
- [ ] User location is shown (with permission prompt)
- [ ] Spot markers display on map
- [ ] Tap marker to view spot details
- [ ] Map theme selector works
- [ ] Map navigation (zoom, pan) is smooth

## 5. Offline Mode
- [ ] Disable network and launch app
- [ ] View spots and lists offline
- [ ] Create/edit spots and lists offline
- [ ] Offline indicator displays
- [ ] Re-enable network and verify sync

## 6. Privacy & Permissions
- [ ] Location permission prompt appears on first use
- [ ] Deny location permission and verify app behavior
- [ ] No sensitive data leaves device (verify logs, network activity)

## 7. Navigation & UI
- [ ] All tabs, pages, and modals work
- [ ] Navigation is smooth and matches design
- [ ] No UI overflow or layout bugs
- [ ] App works in both light and dark mode

## 8. Device Testing
- [ ] Test on iOS simulator
- [ ] Test on real iOS device (if possible)

## 9. Bug/Issue Documentation
- [ ] Document any bugs, UI issues, or platform-specific problems found during testing

---

*Check off each item as you complete it. Add notes or screenshots for any issues found.* 