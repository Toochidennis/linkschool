# CBT History - Quick Reference Guide

## 📁 New Files Created

1. **`lib/modules/model/explore/cbt_history_model.dart`**
   - Model for storing test results

2. **`lib/modules/services/cbt_history_service.dart`**
   - Service for managing test history in SharedPreferences

## 🔄 Modified Files

1. **`lib/modules/explore/e_library/cbt_result_screen.dart`**
   - Now saves test results automatically
   - Refreshes dashboard stats on back navigation

2. **`lib/modules/explore/e_library/test_screen.dart`**
   - Passes examId to result screen

3. **`lib/modules/providers/explore/cbt_provider.dart`**
   - Added history service integration
   - Added statistics fields and methods
   - Loads stats when loading boards

4. **`lib/modules/explore/cbt/cbt_dashboard.dart`**
   - Shows real test count, success rate, and average
   - Displays actual test history from saved data

## 🎯 How It Works

### Automatic Save Flow
```
User Completes Test
    ↓
TestScreen → Submit
    ↓
Navigate to CbtResultScreen
    ↓
initState() called
    ↓
_saveTestResult() executes automatically
    ↓
Data saved to SharedPreferences
    ↓
User taps back
    ↓
refreshStats() called
    ↓
Dashboard updates
```

### What Gets Saved
- Subject name
- Year
- Exam ID
- Exam type (JAMB, WAEC, etc.)
- Score (correct answers)
- Total questions
- Timestamp
- Percentage (calculated)

### What Gets Displayed

**Performance Metrics:**
- **Tests**: Total number of tests taken (e.g., "15")
- **Success**: Percentage of tests passed with ≥50% (e.g., "73%")
- **Average**: Average score across all tests (e.g., "68%")

**Test History:**
- Shows 3 most recent tests
- Subject, year, and score percentage
- Circular progress indicator
- "Tap to retake" text (UI only, feature not yet implemented)

## 💡 Usage

### For Users
1. Take any CBT test normally
2. Complete and submit the test
3. View results on the result screen
4. Navigate back to dashboard
5. See updated statistics automatically

### For Developers

**To get statistics programmatically:**
```dart
final provider = Provider.of<CBTProvider>(context, listen: false);

// Access statistics
int totalTests = provider.totalTests;
double successRate = provider.successRate;
double averageScore = provider.averageScore;
List<CbtHistoryModel> recentHistory = provider.recentHistory;
```

**To manually refresh statistics:**
```dart
await provider.refreshStats();
```

**To access the history service directly:**
```dart
final historyService = CbtHistoryService();

// Get all history
List<CbtHistoryModel> allHistory = await historyService.getTestHistory();

// Get history for specific subject
List<CbtHistoryModel> mathHistory = 
    await historyService.getHistoryBySubject('Mathematics');

// Get statistics
int total = await historyService.getTotalTests();
double success = await historyService.getSuccessRate();
double average = await historyService.getAverageScore();

// Clear history (use with caution)
await historyService.clearHistory();
```

## 🔍 Testing Checklist

- [ ] Take a test and verify it saves
- [ ] Check dashboard shows correct test count
- [ ] Verify success rate calculation (tests with ≥50%)
- [ ] Verify average score calculation
- [ ] Check test history displays recent tests
- [ ] Take multiple tests and verify stats update
- [ ] Restart app and verify data persists
- [ ] Test with different subjects and years
- [ ] Verify empty state when no tests taken

## 🐛 Troubleshooting

**Dashboard shows 0 for everything:**
- Expected for first-time users
- Take a test to populate data

**Statistics not updating:**
- Check console for errors in `_saveTestResult()`
- Verify SharedPreferences is working
- Try `await provider.refreshStats()` manually

**Test history empty:**
- Verify tests are being saved (check console logs)
- Check `_isSaved` flag in result screen
- Ensure `examId` is being passed correctly

**Data lost after app restart:**
- Check if SharedPreferences is initialized
- Verify JSON serialization is working
- Check for errors in `getTestHistory()`

## 📝 Notes

- Data is stored locally only (no server sync)
- Clearing app data will erase history
- Pass threshold is 50% (configurable in model)
- Recent history limit is 3 on dashboard (5 in service)
- Statistics update automatically when returning to dashboard
- All saves include timestamp for chronological sorting

## 🚀 Future Enhancements

See `CBT_HISTORY_IMPLEMENTATION.md` for detailed enhancement ideas.
