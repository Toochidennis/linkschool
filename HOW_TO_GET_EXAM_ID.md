# How to Get exam_id for Each Year

## Understanding the Data Structure

### YearModel Structure
```dart
class YearModel {
  final String id;      // This is the exam_id (e.g., "720")
  final String year;    // This is the year (e.g., "1983")
}
```

### Example Data from API
```json
{
  "course_id": 1,
  "course_name": "ENGLISH LANGUAGE",
  "years": [
    {
      "exam_id": 720,  // ← This becomes YearModel.id
      "year": "1983"   // ← This becomes YearModel.year
    },
    {
      "exam_id": 726,
      "year": "1984"
    }
  ]
}
```

## Available Provider Methods

### 1. **getYearModelsForSubject(String subjectName)** - Returns Full Year Objects

This returns a list of `YearModel` objects, each containing both the year and exam_id.

```dart
// Get all year models for a subject
final provider = Provider.of<CBTProvider>(context, listen: false);
List<YearModel> yearModels = provider.getYearModelsForSubject("ENGLISH LANGUAGE");

// Each yearModel has:
for (var yearModel in yearModels) {
  print("Year: ${yearModel.year}");       // "1983"
  print("Exam ID: ${yearModel.id}");      // "720"
}
```

**Use Case:** When you need to display years AND get their exam_ids (e.g., in YearPickerDialog)

---

### 2. **getExamIdForYear(String subjectName, String year)** - Get Specific exam_id

This returns the exam_id for a specific subject and year combination.

```dart
final provider = Provider.of<CBTProvider>(context, listen: false);

// Get exam_id for English Language 1983
String? examId = provider.getExamIdForYear("ENGLISH LANGUAGE", "1983");
// Returns: "720"

// Get exam_id for Biology 1980
String? bioExamId = provider.getExamIdForYear("BIOLOGY", "1980");
// Returns: "300"
```

**Use Case:** When you already know the subject and year, and just need the exam_id

---

### 3. **getYearsForSubject(String subjectName)** - Get Just the Years (Legacy)

This returns only the year strings (no exam_ids).

```dart
final provider = Provider.of<CBTProvider>(context, listen: false);
List<String> years = provider.getYearsForSubject("ENGLISH LANGUAGE");
// Returns: ["1983", "1984", "1985", ...]
```

**Use Case:** When you only need to display years (not recommended for new code)

---

## Practical Examples

### Example 1: Display Years with Their Exam IDs

```dart
Consumer<CBTProvider>(
  builder: (context, provider, child) {
    final yearModels = provider.getYearModelsForSubject("BIOLOGY");
    
    return ListView.builder(
      itemCount: yearModels.length,
      itemBuilder: (context, index) {
        final yearModel = yearModels[index];
        
        return ListTile(
          title: Text('Year: ${yearModel.year}'),
          subtitle: Text('Exam ID: ${yearModel.id}'),
          onTap: () {
            // Navigate with the specific exam_id
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestScreen(
                  examTypeId: yearModel.id,  // Use the exam_id!
                  subject: "BIOLOGY",
                  year: int.parse(yearModel.year),
                ),
              ),
            );
          },
        );
      },
    );
  },
)
```

---

### Example 2: Get Exam ID When Year is Selected

```dart
void onYearSelected(String selectedYear) {
  final provider = Provider.of<CBTProvider>(context, listen: false);
  final examId = provider.getExamIdForYear("MATHEMATICS", selectedYear);
  
  if (examId != null) {
    print("Loading exam with ID: $examId");
    
    // Start the exam
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          examTypeId: examId,  // Use the specific exam_id
          subject: "MATHEMATICS",
          year: int.parse(selectedYear),
        ),
      ),
    );
  } else {
    print("No exam found for this year");
  }
}
```

---

### Example 3: Populate a Dropdown with Years

```dart
Consumer<CBTProvider>(
  builder: (context, provider, child) {
    final yearModels = provider.getYearModelsForSubject("PHYSICS");
    
    return DropdownButton<YearModel>(
      items: yearModels.map((yearModel) {
        return DropdownMenuItem<YearModel>(
          value: yearModel,
          child: Text(yearModel.year),
        );
      }).toList(),
      onChanged: (YearModel? selected) {
        if (selected != null) {
          print("Selected Year: ${selected.year}");
          print("Exam ID: ${selected.id}");
          
          // Use the exam_id to fetch questions
          fetchQuestionsForExam(selected.id);
        }
      },
    );
  },
)
```

---

### Example 4: Year Picker Dialog (Current Implementation)

```dart
void _showYearPicker(BuildContext context, String subject) {
  final provider = Provider.of<CBTProvider>(context, listen: false);
  final yearModels = provider.getYearModelsForSubject(subject);

  if (yearModels.isNotEmpty) {
    YearPickerDialog.show(
      context,
      title: 'Choose Year',
      yearModels: yearModels,  // Pass the full YearModel list
      subject: subject,
      // ... other parameters
      
      // In YearPickerDialog.show(), on selection:
      // onSubmit: (index) {
      //   final selectedYear = yearModels[index];
      //   final examId = selectedYear.id;  // ← This is the exam_id!
      //   final year = selectedYear.year;
      // }
    );
  }
}
```

---

## Quick Reference Table

| Method | Returns | Best For |
|--------|---------|----------|
| `getYearModelsForSubject(subject)` | `List<YearModel>` | Getting both year AND exam_id |
| `getExamIdForYear(subject, year)` | `String?` | Getting exam_id when you know the year |
| `getYearsForSubject(subject)` | `List<String>` | Only displaying years (legacy) |

---

## Important Notes

1. **YearModel.id** contains the `exam_id` (e.g., "720")
2. **YearModel.year** contains the year string (e.g., "1983")
3. Always use `getYearModelsForSubject()` for new implementations
4. The `exam_id` is what you pass to `TestScreen` to load the correct questions
5. Each subject/year combination has a unique `exam_id`

---

## Common Mistakes to Avoid

❌ **Wrong:** Using `exam_type_id` (board ID) instead of `exam_id`
```dart
// This loads the wrong exam!
TestScreen(examTypeId: "5") // This is the JAMB board ID
```

✅ **Correct:** Using the specific `exam_id` for that year
```dart
// This loads the correct exam for English 1983
TestScreen(examTypeId: "720") // This is the exam_id
```

---

## Debug Example

```dart
final provider = Provider.of<CBTProvider>(context, listen: false);

// Get all year models for Biology
final yearModels = provider.getYearModelsForSubject("BIOLOGY");

print("=== BIOLOGY Years and Exam IDs ===");
for (var yearModel in yearModels) {
  print("Year: ${yearModel.year} → Exam ID: ${yearModel.id}");
}

// Expected output:
// Year: 1978 → Exam ID: 298
// Year: 1979 → Exam ID: 299
// Year: 1980 → Exam ID: 300
// Year: 1981 → Exam ID: 301
// ... etc
```

This guide should help you understand how to access the exam_id for each year in your CBT app!
