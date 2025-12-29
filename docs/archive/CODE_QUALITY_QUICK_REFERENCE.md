# Flutter Code Quality - Quick Reference

## Top 10 Issues to Fix

### 1. Delete Unused Models (5 files)
```
lib/data/models/
  ❌ user_account.dart
  ❌ sync_task.dart
  ❌ progress_model.dart
  ❌ wrong_answer.dart
  ❌ sync_status.dart
```
**Action:** Delete files OR add to models.dart barrel export

### 2. Unused Providers (90+ definitions)
**Files:** All in `lib/data/providers/`
**Action:** Search for each provider name in codebase:
```bash
grep -r "premiumBadgeEnabledProvider" lib/  # Example
```
Delete if 0 results (except in definition file)

### 3. Oversized Screen Files
| File | Size | Action |
|------|------|--------|
| `problem_screen.dart` | 1403L | Split into 4 files |
| `home_screen_figma.dart` | 1249L | Split into 3 files |
| `league_screen.dart` | 1063L | Extract components |
| `errors_screen.dart` | 1002L | Extract error detail view |
| `profile_detail_screen_v3_new.dart` | 998L | Split by section |

### 4. Duplicate Buttons (4 files → 1)
```dart
// Create BaseAnimatedButton with factory constructors
// lib/shared/widgets/buttons/base_button.dart (NEW)
class BaseAnimatedButton {
  factory BaseAnimatedButton.primary({...}) => PrimaryButton(...);
  factory BaseAnimatedButton.duolingo({...}) => DuolingoButton(...);
  factory BaseAnimatedButton.option({...}) => OptionButton(...);
}

// Then update imports everywhere
// DELETE: duolingo_button.dart, animated_button.dart (duplicate logic)
```

### 5. Duplicate Cards (3 files → 1)
```dart
// Merge into lib/shared/widgets/cards/stat_card.dart
class StatCard {
  final IconData? icon;              // NEW: optional
  final String? emoji;               // NEW: optional
  final String label;
  final String value;
  
  // Remove ProfileStatCard completely
}

// DELETE: features/profile/widgets/profile_stat_card.dart
```

### 6. Unused Widgets (Delete 3)
```
lib/shared/widgets/feedback/animated_snackbar.dart
  - AnimatedSnackbar (unused)
  - AnimatedToast (unused)

lib/shared/utils/error_handler.dart
  - SafeAsyncExecutor (unused)
```

### 7. Unused Imports
Run analysis:
```bash
cd /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab
flutter analyze --no-fatal-infos 2>&1 | grep "is never used"
```

Common patterns to remove:
- `import 'package:timeago/timeago.dart' as timeago;` (used in 2 files only)
- Unused animation controllers with `// ignore: unused_field`

### 8. Folder Structure Issues

**Profile folder:**
```
features/profile/
├── profile_detail_screen_v3_new.dart  (✅ USED - keep)
├── figma/
│   └── profile_detail_screen_v3_new.dart  (DELETE if duplicate)
└── widgets/
    ├── profile_stat_card.dart  (DELETE - merge into stat_card)
    └── ... (keep others)
```

**Lessons folder:**
```
features/lessons/
├── figma/
│   └── lessons_screen_figma.dart  (✅ USED - rename to remove "figma")
```

### 9. Provider Organization
Current: 36 providers in flat structure  
Recommended: Organize into subdirectories
```
data/providers/
├── auth/
│   ├── auth_provider.dart
│   └── firebase_providers.dart
├── content/
│   ├── lesson_provider.dart
│   ├── problem_provider.dart
│   └── achievement_provider.dart
├── social/
│   ├── friend_provider.dart
│   ├── chat_provider.dart
│   └── leaderboard_provider.dart
├── gamification/
│   ├── league_provider.dart
│   └── daily_challenge_provider.dart
└── premium/
    └── premium_providers.dart
```

### 10. Add Missing Model Methods
All models in `lib/data/models/` should have:
```dart
class User {
  // Existing fields...
  
  User copyWith({...});
  
  @override
  bool operator ==(Object other) => ...;
  
  @override
  int get hashCode => ...;
  
  Map<String, dynamic> toJson() => ...;
  
  factory User.fromJson(Map<String, dynamic> json) => ...;
}
```

**Recommendation:** Use `freezed` package for auto-generation

---

## File Paths Summary

### Files to Delete
```
lib/data/models/user_account.dart
lib/data/models/sync_task.dart
lib/data/models/progress_model.dart
lib/data/models/wrong_answer.dart
lib/data/models/sync_status.dart
lib/shared/widgets/feedback/animated_snackbar.dart
lib/shared/utils/error_handler.dart
lib/features/profile/widgets/profile_stat_card.dart
```

### Files to Consolidate
```
Button consolidation:
  lib/shared/widgets/buttons/animated_button.dart
  lib/shared/widgets/buttons/duolingo_button.dart
  lib/shared/widgets/buttons/primary_button.dart
  lib/features/problem/widgets/problem_option_button.dart
  → Create BaseAnimatedButton

Card consolidation:
  lib/shared/widgets/cards/stat_card.dart (KEEP)
  lib/features/profile/widgets/profile_stat_card.dart (DELETE)
  lib/shared/widgets/cards/daily_goal_card.dart (KEEP - different purpose)
```

### Files to Refactor (Split)
```
CRITICAL (>1000L):
  lib/features/problem/problem_screen.dart (1403L)
  lib/features/home/home_screen_figma.dart (1249L)

HIGH (800-1000L):
  lib/features/league/league_screen.dart (1063L)
  lib/features/errors/errors_screen.dart (1002L)
  lib/features/profile/figma/profile_detail_screen_v3_new.dart (998L)
  lib/features/wrong_answer/wrong_answer_screen.dart (997L)
  lib/features/lessons/figma/lessons_screen_figma.dart (883L)
```

### Files to Reorganize
```
ALL in: lib/data/providers/
  → 36 files to split into 6 subdirectories
```

---

## Priority Order

**Week 1:** Delete unused files + consolidate buttons/cards
1. Delete 5 unused models (30 min)
2. Delete 3 unused widget classes (20 min)
3. Consolidate button widgets (4 hours)
4. Consolidate card widgets (2 hours)
5. Update imports everywhere (1 hour)

**Week 2:** Refactor large files
1. Split problem_screen.dart (2 days)
2. Split home_screen_figma.dart (1 day)
3. Extract components from other large files (2 days)

**Week 3:** Clean up providers
1. Remove 90+ unused providers (2 days)
2. Reorganize into folders (1 day)
3. Add missing provider exports (1 day)

**Week 4+:** Polish & establish standards
1. Run flutter analyzer regularly
2. Update models with missing methods
3. Standardize naming conventions
4. Add pre-commit hooks

---

## Commands to Run

### Find unused imports
```bash
cd /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab
flutter analyze --no-fatal-infos 2>&1 | grep "is never used"
```

### Check for unused classes
```bash
# Example - check if a class is used anywhere
grep -r "ProfileStatCard" lib/  # Should only find definition
```

### Find unused providers
```bash
# Example - check if provider is used
grep -r "unlimitedHeartsEnabledProvider" lib/  # Should find definition only
```

### Run all analysis
```bash
flutter pub get
flutter analyze
dart fix --dry-run  # Preview fixes
dart fix           # Apply fixes
```

---

## Testing After Changes

After making changes, test:
```bash
# Rebuild
flutter clean
flutter pub get
flutter pub upgrade

# Analyze for errors
flutter analyze

# Run tests
flutter test

# Build APK
flutter build apk

# Check for compilation errors
flutter run
```

---

## Documentation

Complete analysis in: `FLUTTER_CODE_ANALYSIS_REPORT.md`

Keep this file updated as you make changes.
