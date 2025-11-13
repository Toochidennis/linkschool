# CBT Dashboard - Implementation Guide

## What Changed in `cbt_dashboard.dart`

### Before (Old Code) ❌

```dart
return GestureDetector(
  onTap: () {
    if (years.isNotEmpty) {
      final yearsList = years
          .map((y) => int.tryParse(y))
          .whereType<int>()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      YearPickerDialog.show(
        context,
      //  examTypeId: provider.selectedBoard?.id ?? '',
        title: 'Choose Year for $subject',
        startYear: yearsList.first,        // ❌ Old parameter
        numberOfYears: yearsList.length,   // ❌ Old parameter
        subject: subject,
        subjectIcon: provider.getSubjectIcon(subject),
        cardColor: provider.getSubjectColor(subject),
        subjectList: provider.getOtherSubjects(subject),
      );
    }
  },
);
```

### After (New Code) ✅

```dart
return GestureDetector(
  onTap: () {
    // Get YearModel objects (includes both year and exam_id)
    final yearModels = provider.getYearModelsForSubject(subject);
    
    if (yearModels.isNotEmpty) {
      // Find the subject model to get the correct subject ID
      final subjectModel = provider.currentBoardSubjects.firstWhere(
        (s) => s.name == subject,
        orElse: () => provider.currentBoardSubjects.first,
      );

      YearPickerDialog.show(
        context,
        examTypeId: provider.selectedBoard?.id ?? '',
        title: 'Choose Year for $subject',
        yearModels: yearModels,  // ✅ Pass YearModel list (includes exam_id!)
        subject: subject,
        subjectIcon: provider.getSubjectIcon(subject),
        cardColor: provider.getSubjectColor(subject),
        subjectList: provider.getOtherSubjects(subject),
        subjectId: subjectModel.id,  // ✅ Pass subject ID
      );
    }
  },
);
```

---

## Key Changes Explained

### 1. **Get YearModels Instead of Year Strings**

**Before:**
```dart
final years = provider.getYearsForSubject(subject);  // Returns List<String>
```

**After:**
```dart
final yearModels = provider.getYearModelsForSubject(subject);  // Returns List<YearModel>
```

**Why?** 
- `YearModel` contains both the `year` AND the `exam_id`
- We need the `exam_id` to load the correct questions

---

### 2. **Removed Manual Sorting**

**Before:**
```dart
final yearsList = years
    .map((y) => int.tryParse(y))
    .whereType<int>()
    .toList()
  ..sort((a, b) => b.compareTo(a));
```

**After:**
```dart
// Sorting is now handled inside YearPickerDialog.show()
```

**Why?**
- The `YearPickerDialog` now handles sorting automatically
- Cleaner code, less duplication

---

### 3. **Pass YearModels to Dialog**

**Before:**
```dart
YearPickerDialog.show(
  context,
  startYear: yearsList.first,        // ❌ Only the first year
  numberOfYears: yearsList.length,   // ❌ Just the count
  // ...
);
```

**After:**
```dart
YearPickerDialog.show(
  context,
  yearModels: yearModels,  // ✅ Full list with exam_ids
  // ...
);
```

**Why?**
- Each `YearModel` has the specific `exam_id` for that year
- When user selects a year, we can get its unique `exam_id`

---

### 4. **Added Subject ID**

**Before:**
```dart
YearPickerDialog.show(
  // ... no subjectId parameter
);
```

**After:**
```dart
final subjectModel = provider.currentBoardSubjects.firstWhere(
  (s) => s.name == subject,
  orElse: () => provider.currentBoardSubjects.first,
);

YearPickerDialog.show(
  // ...
  subjectId: subjectModel.id,  // ✅ Pass the subject ID
);
```

**Why?**
- We need to pass the subject ID along with other data
- Ensures consistency across the app

---

## How It Works Now

### Data Flow

```
1. User clicks on "BIOLOGY" subject
   ↓
2. CBT Dashboard calls:
   yearModels = provider.getYearModelsForSubject("BIOLOGY")
   ↓
3. Returns List<YearModel>:
   [
     YearModel(id: "298", year: "1978"),  ← exam_id for Biology 1978
     YearModel(id: "299", year: "1979"),  ← exam_id for Biology 1979
     YearModel(id: "300", year: "1980"),  ← exam_id for Biology 1980
     ...
   ]
   ↓
4. Pass to YearPickerDialog:
   YearPickerDialog.show(
     yearModels: yearModels,  ← Full list with exam_ids
     ...
   )
   ↓
5. User selects "1980"
   ↓
6. YearPickerDialog extracts:
   - year: "1980"
   - exam_id: "300"  ← Specific exam_id for Biology 1980!
   ↓
7. Navigate to CbtDetailScreen with:
   - examId: "300"  ← The correct exam_id
   ↓
8. Start exam loads questions for Biology 1980 only ✅
```

---

## Testing the Changes

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Navigate to CBT
1. Open the app
2. Go to Explore → E-Library → CBT

### Step 3: Select a Subject
1. Choose a board (e.g., JAMB)
2. Click on any subject (e.g., BIOLOGY)

### Step 4: Check Console Logs
You should see:
```
Selected year: 1980, ExamId: 300, Subject: BIOLOGY, SubjectId: 10
```

### Step 5: Verify Questions Load
- Click "Start Exam"
- Questions should load for that specific year
- Check that the year in the exam matches what you selected

---

## Common Issues & Solutions

### Issue 1: "No named parameter 'startYear'"
**Cause:** Old code still using `startYear` parameter

**Solution:** Make sure you've updated the code to use `yearModels` instead

---

### Issue 2: Build cache showing old errors
**Cause:** Flutter is using cached build files

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

---

### Issue 3: Questions not loading
**Cause:** exam_id not being passed correctly

**Solution:** 
- Check console logs for the exam_id being used
- Verify it matches the expected exam_id from the API data

---

## Summary of Benefits

✅ **Correct Data Loading**
- Each year now has its own unique exam_id
- Questions load for the specific year selected

✅ **Cleaner Code**
- No manual sorting needed
- Uses provider methods properly

✅ **Type Safety**
- Works with `YearModel` objects
- Less error-prone than string manipulation

✅ **Better Performance**
- Single method call to get all data
- No redundant parsing

✅ **Maintainable**
- Clear data flow
- Easy to debug

---

## Next Steps

1. ✅ Run `flutter clean` to clear build cache
2. ✅ Run `flutter pub get` to ensure dependencies are updated
3. ✅ Run `flutter run` to test the changes
4. ✅ Test selecting different subjects and years
5. ✅ Verify console logs show correct exam_ids
6. ✅ Confirm questions load correctly

Your CBT Dashboard is now properly using `YearModel` objects with exam_ids! 🎉
