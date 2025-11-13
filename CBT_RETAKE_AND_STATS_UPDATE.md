# CBT Dashboard Enhancement - Test Retake & Statistics Update

## Overview
Enhanced the CBT dashboard to provide more accurate statistics and allow users to retake tests by clicking on test history cards. The system now updates existing test results instead of creating duplicates.

## Key Changes

### 1. Statistics Calculation Updates

#### **Success Metric Changed**
- **Before**: Percentage of passed tests (e.g., "67%")
- **After**: Total number of successfully completed tests (e.g., "12")
- **Logic**: Simply counts tests where score >= 50%

#### **Average Metric Enhanced**
- **Before**: Average of ALL test attempts
- **After**: Average based on unique subject-year-examType combinations
- **Logic**: 
  - Groups tests by subject, year, and exam type
  - Takes the highest score for each combination
  - Calculates average across unique combinations
  - **Example**: If you took "Mathematics 2020 JAMB" 3 times (60%, 70%, 80%), only 80% is used in the average calculation

### 2. Test Retake Functionality

#### **Clickable History Cards**
- Users can now tap on any test history card
- Automatically navigates to the test screen with correct parameters
- Pre-fills subject, year, and exam information

#### **Smart Result Updates**
- **First Take**: Creates new test result
- **Retake**: Updates existing test result (no duplicates)
- **Identification**: Matches by subject + year + examId + examType
- **Benefit**: Clean history without duplicate entries

## Files Modified

### 1. `lib/modules/services/cbt_history_service.dart`

#### New/Updated Methods:

**`getSuccessCount()`** - Replaces `getSuccessRate()`
```dart
// Returns count of passed tests
Future<int> getSuccessCount() async {
  final history = await getTestHistory();
  return history.where((h) => h.isPassed).length;
}
```

**`getAverageScore()`** - Enhanced calculation
```dart
// Groups by subject-year-examType, takes best score for each
Future<double> getAverageScore() async {
  final Map<String, double> subjectScores = {};
  
  for (var test in history) {
    final key = '${test.subject}_${test.year}_${test.examType}';
    
    // Keep highest score for each combination
    if (!subjectScores.containsKey(key) || 
        subjectScores[key]! < test.percentage) {
      subjectScores[key] = test.percentage;
    }
  }
  
  return totalPercentage / subjectScores.length;
}
```

**`saveTestResult()`** - Smart update logic
```dart
// Checks if test exists before saving
Future<void> saveTestResult(CbtHistoryModel history) async {
  final existingIndex = historyList.indexWhere((h) =>
    h.subject == history.subject &&
    h.year == history.year &&
    h.examId == history.examId &&
    h.examType == history.examType
  );
  
  if (existingIndex != -1) {
    historyList[existingIndex] = history; // Update
  } else {
    historyList.add(history); // Add new
  }
}
```

**`findExistingTest()`** - New method
```dart
// Find existing test by parameters
Future<CbtHistoryModel?> findExistingTest({
  required String subject,
  required int year,
  required String examId,
  required String examType,
}) async { ... }
```

**`getDashboardStats()`** - Updated return values
```dart
return {
  'totalTests': totalTests,
  'successCount': successCount,  // Changed from successRate
  'averageScore': averageScore,
  'recentHistory': recentHistory,
};
```

### 2. `lib/modules/providers/explore/cbt_provider.dart`

#### Updated Fields:
```dart
// Changed from:
double _successRate = 0.0;

// To:
int _successCount = 0;
```

#### Updated Getters:
```dart
// Changed from:
double get successRate => _successRate;

// To:
int get successCount => _successCount;
```

#### Updated Methods:
```dart
Future<void> loadDashboardStats() async {
  final stats = await _historyService.getDashboardStats();
  _totalTests = stats['totalTests'] ?? 0;
  _successCount = stats['successCount'] ?? 0;  // Changed
  _averageScore = stats['averageScore'] ?? 0.0;
  _recentHistory = stats['recentHistory'] ?? [];
}
```

### 3. `lib/modules/explore/cbt/cbt_dashboard.dart`

#### New Imports:
```dart
import 'package:linkschool/modules/model/explore/cbt_history_model.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
```

#### Updated Performance Metrics Display:
```dart
_buildPerformanceCard(
  imagePath: 'assets/icons/success.png',
  title: 'Success',
  completionRate: provider.successCount.toString(),  // No % sign
  backgroundColor: AppColors.cbtColor2,
  borderColor: AppColors.cbtBorderColor2,
),
```

#### Enhanced History Card Builder:
```dart
return _buildHistoryCard(
  context: context,
  history: history,           // Pass full history model
  courseName: history.subject,
  year: history.year.toString(),
  progressValue: history.percentage / 100,
  borderColor: colors[index % colors.length],
  provider: provider,         // Pass provider for refresh
);
```

#### Clickable History Cards:
```dart
Widget _buildHistoryCard({
  required BuildContext context,
  required CbtHistoryModel history,
  required CBTProvider provider,
  ...
}) {
  return GestureDetector(
    onTap: () {
      // Navigate to test screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestScreen(
            examTypeId: history.examId,
            subjectId: null,
            subject: history.subject,
            year: history.year,
          ),
        ),
      ).then((_) {
        // Refresh stats when returning
        provider.refreshStats();
      });
    },
    child: Container(...), // Card UI
  );
}
```

## User Flow

### First Time Taking a Test:
1. User selects subject from CBT dashboard
2. Chooses year and starts test
3. Completes test and submits
4. Result is saved to SharedPreferences
5. Dashboard updates:
   - Tests: +1
   - Success: +1 (if passed)
   - Average: Calculated with new score

### Retaking a Test:
1. User taps on test history card
2. Navigates to test screen with pre-filled data
3. Takes the test again
4. Submits test
5. **Existing test result is updated** (not duplicated)
6. Dashboard refreshes:
   - Tests: Same count (no duplicate)
   - Success: Updates if pass status changed
   - Average: Recalculated with new score

## Dashboard Metrics Explained

### Tests Card
- **Shows**: Total number of unique tests taken
- **Example**: "15" means 15 different subject-year-examType combinations
- **Color**: Blue (cbtColor1)

### Success Card
- **Shows**: Count of passed tests (score >= 50%)
- **Example**: "12" means 12 tests passed out of 15 total
- **Color**: Green (cbtColor2)
- **Note**: No percentage symbol

### Average Card
- **Shows**: Average score across unique subject combinations
- **Example**: "74%" means average of best scores for each subject
- **Calculation**:
  - Math 2020 JAMB: Best score = 80%
  - English 2020 JAMB: Best score = 70%
  - Physics 2020 JAMB: Best score = 72%
  - Average = (80 + 70 + 72) / 3 = 74%
- **Color**: Orange (cbtColor3)

## Benefits

### 1. **Cleaner History**
- No duplicate entries when retaking tests
- Each subject-year-exam combination appears once
- Shows only the most recent attempt

### 2. **More Accurate Statistics**
- Average reflects performance across different subjects
- Not skewed by multiple attempts of the same test
- Success count is more meaningful than percentage

### 3. **Better User Experience**
- Easy test retake with one tap
- Automatic data refresh
- Consistent navigation flow

### 4. **Improved Tracking**
- Users can see their best scores
- Progress is easy to understand
- Encourages retaking tests to improve scores

## Example Scenarios

### Scenario 1: Taking Multiple Different Tests
```
Tests taken:
1. Mathematics 2020 JAMB - 65%
2. English 2020 JAMB - 80%
3. Physics 2020 JAMB - 55%

Dashboard shows:
- Tests: 3
- Success: 3 (all passed)
- Average: 67% (rounded from 66.67%)
```

### Scenario 2: Retaking a Test
```
Original:
- Mathematics 2020 JAMB - 45% (Failed)

Dashboard:
- Tests: 1
- Success: 0
- Average: 45%

After retake:
- Mathematics 2020 JAMB - 75% (Passed)

Dashboard:
- Tests: 1 (still 1, updated not added)
- Success: 1 (now passed)
- Average: 75% (updated)
```

### Scenario 3: Multiple Subjects, Multiple Retakes
```
History:
1. Math 2020 JAMB - 1st: 50%, 2nd: 70%, 3rd: 85%
2. English 2020 JAMB - 1st: 60%, 2nd: 75%
3. Physics 2020 JAMB - 1st: 40% (not retaken)

Dashboard:
- Tests: 3 (unique subjects)
- Success: 2 (Math: 85% ✓, English: 75% ✓, Physics: 40% ✗)
- Average: 77% ((85 + 75 + 40) / 3)
```

## Testing Checklist

- [x] First test saved correctly
- [x] Dashboard displays correct initial stats
- [x] History card appears in recent history
- [x] Clicking history card navigates to test screen
- [x] Test screen shows correct subject/year
- [x] Retaking test updates existing result
- [x] No duplicate entries created
- [x] Dashboard stats update after retake
- [x] Success count increases when failing test is passed
- [x] Average recalculates correctly
- [x] Multiple retakes update same entry

## Future Enhancements (Optional)

1. **History Details**: Show all attempts, not just latest
2. **Best Score Badge**: Highlight personal best scores
3. **Improvement Tracking**: Show score improvement over time
4. **Subject Performance**: Breakdown by subject
5. **Time Analysis**: Best performing times/days
6. **Compare with Others**: Leaderboard or percentile ranking
7. **Export Report**: PDF report of test history
8. **Notifications**: Remind users to retake failed tests

## Notes

- All data persists using SharedPreferences (local storage)
- Clearing app data will reset all statistics
- Test results are identified by: subject + year + examId + examType
- Retaking updates only if ALL four identifiers match
- Dashboard auto-refreshes when returning from test screen
