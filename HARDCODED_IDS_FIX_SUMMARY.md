# 🔧 Hardcoded IDs Fix Summary

## ✅ Files Already Fixed:

### 1. `single_attachment_preview_screen.dart`
- **Line 761**: Changed `"course_id": 25` → `"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id`
- **Line 798**: Changed `levelId: "71"` → `levelId: widget.levelId ?? widget.childContent?.classes[0].id.toString() ?? ""`
- **Line 799**: Changed `courseId: "25"` → `courseId: widget.courseId ?? widget.id?.toString() ?? ""`
- **Line 800**: Changed `courseName: "Computer science"` → `courseName: widget.courseName ?? widget.title ?? "No course name"`

### 2. `single_assignment_detail_screen.dart`
- **Line 95-108**: Updated `_navigateToAttachmentPreview()` to pass:
  - `courseId: widget.childContent?.syllabus?.courseId?.toString()`
  - `levelId: widget.childContent?.classes[0].levelId?.toString()`
  - `courseName: widget.childContent?.syllabus?.courseName`

---

## ⚠️ Files That Still Need Fixing:

### 3. `single_quiz_score_page.dart` (Line 848)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 4. `single_material_detail_screen.dart` (Line 466)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 5. `attachment_preview_screen.dart` (Line 760)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 6. `single_assignment_score_view.dart` (Line 793)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 7. `single_assignment_detail_screen.dart` (Line 393)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 8. `quiz_score_view_page.dart` (Line 848)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 9. `forum_screen.dart` (Lines 499-500)
```dart
// BEFORE:
"level_id": 71,
"course_id": 25,

// AFTER (recommended):
"level_id": widget.levelId ?? getuserdata()['profile']['level_id'],
"course_id": widget.courseId ?? widget.id,
```

### 10. `material_detail_screen.dart` (Line 449)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 11. `assignment_detail_screen.dart` (Line 392)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

### 12. `assignment_score_view_page.dart` (Line 876)
```dart
// BEFORE:
"course_id": 25,

// AFTER (recommended):
"course_id": widget.courseId != null ? int.parse(widget.courseId!) : widget.id,
```

---

## 📋 How to Pass Correct IDs

When navigating to these screens, ensure you pass the proper IDs from the data source:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => YourScreen(
      childContent: content,
      courseId: content.syllabus?.courseId?.toString(),
      levelId: content.classes[0].levelId?.toString(),
      courseName: content.syllabus?.courseName,
      classId: content.classes[0].id?.toString(),
      // ... other parameters
    ),
  ),
);
```

---

## 🎯 Data Flow

```
1. Dashboard/Home Screen
   ↓
2. Course Selection (syllabus data contains courseId, courseName)
   ↓
3. Content Screen (childContent.syllabus.courseId)
   ↓
4. Assignment/Quiz/Material Detail Screen
   ↓
5. Comment/Submission API (use widget.courseId instead of hardcoded 25)
```

---

## 🔍 Where to Find the Correct IDs

- **courseId**: `widget.childContent?.syllabus?.courseId` or from parent widget
- **levelId**: `widget.childContent?.classes[0].levelId` or `getuserdata()['profile']['level_id']`
- **classId**: `widget.childContent?.classes[0].id` or `getuserdata()['profile']['class_id']`
- **courseName**: `widget.childContent?.syllabus?.courseName`

---

## ✅ Verification Checklist

After fixing all files, verify:

- [ ] All hardcoded `25` course IDs are replaced
- [ ] All hardcoded `71` level IDs are replaced
- [ ] All hardcoded `"Computer science"` course names are replaced
- [ ] Navigation calls pass correct IDs to child screens
- [ ] Test comments submission with different courses
- [ ] Test assignment submission with different courses
- [ ] Verify data is saved correctly in backend

---

## 🚀 Next Steps

1. Fix remaining files listed above
2. Add null checks for safety
3. Test with multiple courses
4. Verify backend receives correct IDs
5. Check Hive storage for correct data
