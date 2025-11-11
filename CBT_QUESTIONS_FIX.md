# CBT Questions Display Fix

## Problem Identified

The questions were not displaying because of three main issues:

### 1. **Nested Array Structure**
The API returns questions in a nested array format:
```json
{
  "questions": [
    [  // ← Nested array!
      { "question_id": 300, ... },
      { "question_id": 301, ... }
    ]
  ]
}
```

But the provider was expecting a flat array: `[{...}, {...}]`

### 2. **Field Name Mismatch**
The API uses different field names than the model expected:

| API Field | Model Expected |
|-----------|---------------|
| `question_id` | `id` |
| `question_text` | `content` |
| `question_type` | `type` |
| `question_grade` | `parent` |
| `options` (array) | `answer` (JSON string) |

### 3. **Options Format**
The API returns structured options:
```json
"options": [
  { "order": 0, "text": "Amoeba" },
  { "order": 1, "text": "Ascaris" }
]
```

But the model expected a JSON string in the `answer` field.

## Solution Implemented

### 1. Updated `QuestionModel` (exam_model.dart)
- Added support for **both old and new API formats**
- Added `options` and `correctAnswer` fields
- Modified `fromJson()` to detect and handle the new CBT API format
- Updated `getOptions()` to work with the new structured options
- Added `getCorrectAnswerIndex()` method

### 2. Updated `ExamProvider` (exam_provider.dart)
- Added logic to **flatten nested arrays**
- The provider now handles both `[[{...}]]` and `[{...}]` formats
- Better error logging for debugging

## Result

✅ Questions now display correctly
✅ Backward compatible with old API format
✅ Handles nested array structure
✅ Properly maps all API fields to model fields
✅ Options display correctly

## Testing

Run the app and navigate to any CBT exam. The questions should now display with:
- Question text
- Multiple choice options
- Proper navigation between questions
- Progress tracking
