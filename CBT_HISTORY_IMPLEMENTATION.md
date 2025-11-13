# CBT Test History & Statistics Implementation

## Overview
This implementation adds functionality to save and display CBT test history using SharedPreferences. The dashboard now shows real-time statistics including total tests taken, success rate, average score, and recent test history.

## Files Created

### 1. `lib/modules/model/explore/cbt_history_model.dart`
**Purpose:** Model class to represent a single test result.

**Fields:**
- `subject`: Name of the subject tested
- `year`: Year of the exam
- `examId`: Unique exam identifier
- `examType`: Type of exam (JAMB, WAEC, NECO, etc.)
- `score`: Number of correct answers
- `totalQuestions`: Total number of questions
- `timestamp`: When the test was taken
- `percentage`: Calculated percentage score
- `isPassed`: Boolean indicating if score >= 50%

**Features:**
- JSON serialization/deserialization for SharedPreferences storage
- Automatic percentage calculation
- Pass/fail determination

### 2. `lib/modules/services/cbt_history_service.dart`
**Purpose:** Service class to handle all test history operations.

**Key Methods:**
- `saveTestResult(CbtHistoryModel)`: Save a new test result
- `getTestHistory()`: Retrieve all test history
- `getTotalTests()`: Get count of all tests taken
- `getSuccessRate()`: Calculate percentage of passed tests
- `getAverageScore()`: Calculate average score across all tests
- `getRecentHistory({limit})`: Get most recent tests
- `getHistoryBySubject(subject)`: Filter history by subject
- `getHistoryByExamType(examType)`: Filter history by exam type
- `getDashboardStats()`: Get all statistics for dashboard in one call
- `clearHistory()`: Clear all saved history (optional)

## Files Modified

### 3. `lib/modules/explore/e_library/cbt_result_screen.dart`
**Changes:**
- Converted from StatelessWidget to StatefulWidget
- Added `examId` parameter
- Added `CbtHistoryService` instance
- Added `_saveTestResult()` method that runs on `initState()`
- Saves test results to SharedPreferences automatically when screen loads
- Refreshes dashboard statistics when user navigates back
- Import Provider to access CBTProvider

**Flow:**
1. User completes test and navigates to result screen
2. Screen automatically saves result to SharedPreferences
3. When user taps back button, statistics are refreshed
4. Dashboard now shows updated statistics

### 4. `lib/modules/explore/e_library/test_screen.dart`
**Changes:**
- Updated navigation to `CbtResultScreen` to pass `examId` parameter
- Now passes `widget.examTypeId` as the examId

### 5. `lib/modules/providers/explore/cbt_provider.dart`
**Changes:**
- Added `CbtHistoryService` instance
- Added new fields for dashboard statistics:
  - `_totalTests`
  - `_successRate`
  - `_averageScore`
  - `_recentHistory`
- Added getters for all statistics
- Modified `loadBoards()` to also load dashboard statistics
- Added `loadDashboardStats()` method to fetch statistics from service
- Added `refreshStats()` method to reload statistics on demand

**New Getters:**
- `totalTests`: Total number of tests taken
- `successRate`: Percentage of passed tests (score >= 50%)
- `averageScore`: Average score across all tests
- `recentHistory`: List of recent test results

### 6. `lib/modules/explore/cbt/cbt_dashboard.dart`
**Changes:**

#### Performance Metrics Section:
- Wrapped `_buildPerformanceMetrics()` in Consumer widget
- **Tests Card**: Now shows `provider.totalTests` (actual count)
- **Success Card**: Now shows `provider.successRate` (percentage of passed tests)
- **Average Card**: Now shows `provider.averageScore` (average score percentage)

#### Test History Section:
- Wrapped `_buildTestHistory()` in Consumer widget
- Shows empty state when no history available
- Displays actual test history from `provider.recentHistory`
- Shows subject, year, and percentage for each test
- Uses circular progress indicator to visualize score
- Limited to 3 most recent tests in horizontal scroll

## How It Works

### When User Takes a Test:

1. **Test Screen** (`test_screen.dart`):
   - User answers questions
   - User clicks "Submit"
   - Navigates to `CbtResultScreen` with test data

2. **Result Screen** (`cbt_result_screen.dart`):
   - Screen loads → `initState()` called
   - `_saveTestResult()` automatically executes
   - Creates `CbtHistoryModel` with:
     - Subject, year, examId, examType
     - Score and total questions
     - Timestamp
   - Saves to SharedPreferences via `CbtHistoryService`

3. **Returning to Dashboard**:
   - User taps back button
   - `refreshStats()` called on CBTProvider
   - Statistics reload from SharedPreferences
   - Dashboard updates with new data

### Dashboard Display:

1. **Performance Metrics**:
   - **Tests**: Shows total count (e.g., "12")
   - **Success**: Shows percentage of tests passed (e.g., "67%")
   - **Average**: Shows average score across all tests (e.g., "74%")

2. **Test History**:
   - Shows 3 most recent tests
   - Each card displays:
     - Subject name
     - Year
     - Percentage score
     - Circular progress indicator
     - "Tap to retake" hint
   - Empty state if no history

## Data Persistence

### Storage Format:
- Uses SharedPreferences with key: `'cbt_test_history'`
- Stores as JSON string containing array of test results
- Each test result includes all fields from `CbtHistoryModel`

### Example Stored Data:
```json
[
  {
    "subject": "Mathematics",
    "year": 2015,
    "examId": "6",
    "examType": "JAMB",
    "score": 45,
    "totalQuestions": 60,
    "timestamp": "2025-11-12T10:30:00.000Z",
    "percentage": 75.0
  },
  {
    "subject": "English Language",
    "year": 2016,
    "examId": "6",
    "examType": "JAMB",
    "score": 42,
    "totalQuestions": 60,
    "timestamp": "2025-11-12T14:20:00.000Z",
    "percentage": 70.0
  }
]
```

## Statistics Calculations

### Total Tests:
- Simply counts the number of saved test results

### Success Rate:
- Counts tests where percentage >= 50%
- Formula: `(passed_tests / total_tests) * 100`
- Returns 0% if no tests taken

### Average Score:
- Sums all percentage scores
- Formula: `total_percentage / total_tests`
- Returns 0% if no tests taken

### Recent History:
- Sorts all tests by timestamp (newest first)
- Returns specified number of most recent tests (default: 5)
- Dashboard displays top 3

## Benefits

1. **Persistent Data**: Test history survives app restarts
2. **Real Statistics**: Actual performance metrics instead of placeholder data
3. **User Progress Tracking**: Users can see their improvement over time
4. **Automatic Updates**: No manual refresh needed
5. **Flexible Filtering**: Can filter by subject or exam type
6. **Scalable**: Can easily add more statistics or features

## Future Enhancements (Optional)

1. **Detailed History View**: Add a "See All" screen for complete history
2. **Subject-Specific Stats**: Show performance per subject
3. **Time-Based Analytics**: Weekly/monthly performance graphs
4. **Retake Functionality**: Tap history card to retake that specific test
5. **Export Data**: Allow users to export their test history
6. **Comparison**: Compare current performance with past attempts
7. **Achievements**: Badges for milestones (10 tests, 90% average, etc.)
8. **Weak Areas**: Identify subjects needing improvement

## Testing

To test the implementation:

1. Take a test through the app
2. Complete and submit the test
3. View results on result screen
4. Navigate back to dashboard
5. Verify:
   - Tests count incremented
   - Success rate updated (if score >= 50%)
   - Average score reflects your performance
   - Test appears in history section
6. Take multiple tests to see statistics evolve

## Notes

- First-time users will see 0 tests, 0% success, 0% average (expected)
- History is stored locally on device
- Clearing app data will reset history
- No server synchronization (purely local storage)
- Statistics refresh automatically when returning to dashboard
