# Visual Guide: SubjectModel & YearModel Structure

## Data Flow Diagram

```
API Response
    ↓
┌─────────────────────────────────────────────┐
│ {                                           │
│   "course_id": 1,                          │
│   "course_name": "ENGLISH LANGUAGE",        │
│   "years": [                                │
│     {                                       │
│       "exam_id": 720,  ← This becomes id    │
│       "year": "1983"   ← This becomes year  │
│     },                                      │
│     {                                       │
│       "exam_id": 726,                       │
│       "year": "1984"                        │
│     }                                       │
│   ]                                         │
│ }                                           │
└─────────────────────────────────────────────┘
    ↓ Parsed by SubjectModel.fromJson()
┌─────────────────────────────────────────────┐
│ SubjectModel                                │
│ ├─ id: "1" (course_id)                     │
│ ├─ name: "ENGLISH LANGUAGE"                │
│ ├─ subjectIcon: "english"                  │
│ ├─ cardColor: AppColors.cbtCardColor1      │
│ └─ years: List<YearModel>                  │
│       ├─ YearModel                          │
│       │   ├─ id: "720" (exam_id) ◄─────────│─── Use this!
│       │   └─ year: "1983"                   │
│       ├─ YearModel                          │
│       │   ├─ id: "726" (exam_id)           │
│       │   └─ year: "1984"                   │
│       └─ ...                                │
└─────────────────────────────────────────────┘
```

## How to Access exam_id

### Method 1: Using getYearModelsForSubject()

```dart
┌──────────────────────────────────────┐
│ CBTProvider                          │
│                                      │
│ getYearModelsForSubject("BIOLOGY")  │
└──────────────────┬───────────────────┘
                   ↓
    ┌──────────────────────────────┐
    │ Returns: List<YearModel>     │
    │                              │
    │ [                            │
    │   YearModel(               │
    │     id: "298",  ◄────────── exam_id
    │     year: "1978"            │
    │   ),                         │
    │   YearModel(               │
    │     id: "299",  ◄────────── exam_id
    │     year: "1979"            │
    │   ),                         │
    │   ...                        │
    │ ]                            │
    └──────────────────────────────┘
```

### Method 2: Using getExamIdForYear()

```dart
┌──────────────────────────────────────────┐
│ CBTProvider                              │
│                                          │
│ getExamIdForYear("BIOLOGY", "1980")    │
└──────────────────┬───────────────────────┘
                   ↓
         Searches through years
                   ↓
    ┌──────────────────────────┐
    │ Returns: String?         │
    │                          │
    │ "300"  ◄────────────────│─── exam_id for Biology 1980
    └──────────────────────────┘
```

## Example Usage Flow

```
User Action: Select "BIOLOGY" → Select "1980"
       ↓
┌──────────────────────────────────┐
│ 1. Get YearModels                │
│    yearModels = provider         │
│      .getYearModelsForSubject    │
│      ("BIOLOGY")                 │
└──────────────┬───────────────────┘
               ↓
┌──────────────────────────────────┐
│ 2. User Selects Year Index       │
│    selectedYear = yearModels[2]  │
│    (assuming 1980 is at index 2) │
└──────────────┬───────────────────┘
               ↓
┌──────────────────────────────────┐
│ 3. Access exam_id                │
│    examId = selectedYear.id      │
│    Result: "300"                 │
└──────────────┬───────────────────┘
               ↓
┌──────────────────────────────────┐
│ 4. Navigate to Test              │
│    TestScreen(                   │
│      examTypeId: "300",   ◄───── Use exam_id here!
│      subject: "BIOLOGY",         │
│      year: 1980                  │
│    )                             │
└──────────────────────────────────┘
```

## YearModel Object Structure

```
YearModel
├─ id: String       ← exam_id from API (e.g., "720")
└─ year: String     ← year from API (e.g., "1983")

Example:
┌─────────────────────────┐
│ YearModel               │
│ ├─ id: "720"           │  ← This is what you need!
│ └─ year: "1983"        │
└─────────────────────────┘
```

## Comparison: exam_type_id vs exam_id

```
❌ WRONG: Using exam_type_id
┌────────────────────────────────┐
│ Board: JAMB                    │
│ exam_type_id: 5   ◄────────────│─── This ID represents the whole JAMB board
│                                │
│ Contains ALL subjects          │
│ and ALL years for JAMB         │
└────────────────────────────────┘

✅ CORRECT: Using exam_id
┌────────────────────────────────┐
│ Subject: ENGLISH LANGUAGE      │
│ Year: 1983                     │
│ exam_id: 720  ◄────────────────│─── This ID is for JAMB English 1983 ONLY
└────────────────────────────────┘

┌────────────────────────────────┐
│ Subject: ENGLISH LANGUAGE      │
│ Year: 1984                     │
│ exam_id: 726  ◄────────────────│─── Different year = different exam_id
└────────────────────────────────┘

┌────────────────────────────────┐
│ Subject: BIOLOGY               │
│ Year: 1980                     │
│ exam_id: 300  ◄────────────────│─── Different subject = different exam_id
└────────────────────────────────┘
```

## Quick Access Pattern

```dart
// Pattern 1: Get all years with their exam_ids
final yearModels = provider.getYearModelsForSubject("PHYSICS");
for (var ym in yearModels) {
  print("${ym.year} → exam_id: ${ym.id}");
}

// Pattern 2: Get exam_id for a specific year
final examId = provider.getExamIdForYear("PHYSICS", "1985");
if (examId != null) {
  // Use examId to fetch questions
}

// Pattern 3: Access from YearModel directly
final yearModel = yearModels.first;
final String examId = yearModel.id;     // exam_id
final String year = yearModel.year;     // year
```

## Real-World Example

```
User Journey:
1. Opens CBT Dashboard
2. Selects "JAMB" board
3. Clicks on "BIOLOGY" subject
4. Sees year picker: [2020, 2019, 2018, ...]
5. Selects "2018"

Behind the scenes:
┌─────────────────────────────────────┐
│ YearModel for Biology 2018:        │
│ ├─ id: "718"      ← exam_id        │
│ └─ year: "2018"   ← display        │
└─────────────────────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ Navigate to TestScreen:             │
│ TestScreen(                         │
│   examTypeId: "718",  ← CORRECT!   │
│   subject: "BIOLOGY",               │
│   year: 2018                        │
│ )                                   │
└─────────────────────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ API Call:                           │
│ GET /api/v3/public/cbt/exams/718   │
│     /questions                      │
│                                     │
│ Returns: Questions for Biology 2018│
└─────────────────────────────────────┘
```

This visual guide should make it crystal clear how to access and use the exam_id!
