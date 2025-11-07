# Dark Mode Implementation Guide

## Overview
This guide explains how to implement dark mode colors throughout the LinkSchool app using the updated `AppColors` class.

## AppColors Structure

### Static Constants (Don't change with theme)
These are used for specific colors that should stay the same regardless of theme:
- `AppColors.primaryLight` - Always light blue
- `AppColors.backgroundLight` - Always white
- `AppColors.text3Light` - Always black
- etc.

### Dynamic Methods (Change with theme) ✅ USE THESE
These methods check the current theme and return appropriate colors:
- `AppColors.primary(context)` - Blue in light mode, darker blue in dark mode
- `AppColors.background(context)` - White in light mode, dark in dark mode
- `AppColors.text(context)` - Black in light mode, white in dark mode
- etc.

## How to Update Your Code

### ❌ OLD WAY (Static - Won't adapt):
```dart
Text(
  'Hello',
  style: TextStyle(color: AppColors.text3Light), // Always black
)

Container(
  color: AppColors.backgroundLight, // Always white
)
```

### ✅ NEW WAY (Dynamic - Adapts to theme):
```dart
Text(
  'Hello',
  style: TextStyle(color: AppColors.text3(context)), // Black in light, white in dark
)

Container(
  color: AppColors.background(context), // White in light, dark in dark mode
)
```

## Available Dynamic Color Methods

| Method | Light Mode | Dark Mode |
|--------|-----------|-----------|
| `AppColors.primary(context)` | Blue (#2D63FF) | Dark Blue (#040D15) |
| `AppColors.secondary(context)` | Orange (#FC9338) | Cyan (#03DAC6) |
| `AppColors.background(context)` | White (#FFFFFF) | Dark (#040D15) |
| `AppColors.text(context)` | Black (#1A1A1A) | White (#FFFFFF) |
| `AppColors.text2(context)` | Blue (#2D63FF) | Light Blue (#6496FF) |
| `AppColors.text3(context)` | Black (#000000) | White (#FFFFFF) |
| `AppColors.text4(context)` | Dark Gray (#1A1A1A) | Light Gray (#E6E6E6) |
| `AppColors.text5(context)` | Gray (#8C8C8C) | Light Gray (#B4B4B4) |
| `AppColors.card(context)` | White (#FFFFFF) | Dark Card (#141923) |
| `AppColors.textField(context)` | White (#FFFFFF) | Dark (#1E1E1E) |
| `AppColors.textFieldBorder(context)` | Light Gray (#D0D0D0) | Dark Gray (#505050) |
| `AppColors.progressBar(context)` | Blue (#7795FF) | Light Blue (#5078FF) |

## Step-by-Step Migration for Explore Screens

### Step 1: Find Static Color Usage
Search for patterns like:
- `AppColors.text3Light`
- `AppColors.backgroundLight`
- `AppColors.text2Light`

### Step 2: Replace with Dynamic Methods
```dart
// Before
color: AppColors.text3Light

// After
color: AppColors.text3(context)
```

### Step 3: Test Both Modes
1. Run the app
2. Go to Settings (Explore → 4th tab)
3. Toggle Dark Mode
4. Navigate through all explore screens
5. Check that colors adapt properly

## Common Patterns in Explore Module

### Text Styles
```dart
// Before
Text(
  'Title',
  style: AppTextStyles.normal600(
    fontSize: 16,
    color: AppColors.text2Light,  // ❌ Static
  ),
)

// After
Text(
  'Title',
  style: AppTextStyles.normal600(
    fontSize: 16,
    color: AppColors.text2(context),  // ✅ Dynamic
  ),
)
```

### Container Backgrounds
```dart
// Before
Container(
  decoration: BoxDecoration(
    color: AppColors.backgroundLight,  // ❌ Static
    borderRadius: BorderRadius.circular(12),
  ),
)

// After
Container(
  decoration: BoxDecoration(
    color: AppColors.background(context),  // ✅ Dynamic
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### Card Widgets
```dart
// Before
Card(
  color: Colors.white,  // ❌ Static
  child: ...
)

// After
Card(
  color: AppColors.card(context),  // ✅ Dynamic
  child: ...
)
```

## Files to Update (Priority Order)

### High Priority (User-facing explore screens):
1. ✅ `lib/modules/explore/explore_profile/explore_profileScreen.dart` - **DONE**
2. `lib/modules/explore/home/explore_home.dart` - Home screen
3. `lib/modules/explore/home/news/all_news_screen.dart` - News listing
4. `lib/modules/explore/home/news/news_details.dart` - News details
5. `lib/modules/explore/e_library/E_library_dashbord.dart` - E-library home
6. `lib/modules/explore/ebooks/ebooks_dashboard.dart` - E-books
7. `lib/modules/explore/videos/videos_dashboard.dart` - Videos
8. `lib/modules/explore/cbt/cbt_dashboard.dart` - CBT
9. `lib/modules/explore/games/games_home.dart` - Games
10. `lib/modules/explore/admission/explore_admission.dart` - Admission

### Medium Priority (Detail screens):
11. `lib/modules/explore/e_library/e_lib_subject_detail.dart`
12. `lib/modules/explore/e_library/e_games/game_details.dart`
13. `lib/modules/explore/e_library/e_library_ebooks/book_page.dart`
14. `lib/modules/explore/cbt/cbt.details.dart`

### Low Priority (Supporting widgets):
15. `lib/modules/explore/home/explore_item.dart`
16. `lib/modules/explore/home/custom_button_item.dart`
17. `lib/modules/explore/ebooks/custom_search_bar.dart`

## Special Cases

### Buttons that should stay same color
Some buttons have specific branding colors that shouldn't change:
```dart
// Keep static for branding
backgroundColor: AppColors.exploreButton1Light,  // Blue button - stays blue
borderColor: AppColors.exploreButton1BorderLight,
```

### Icons with specific colors
```dart
// If icon should adapt to theme
Icon(
  Icons.home,
  color: AppColors.text2(context),  // ✅ Adapts
)

// If icon should stay specific color (e.g., branding)
Icon(
  Icons.school,
  color: AppColors.primaryLight,  // ❌ Always blue
)
```

### Gradients and Complex Decorations
```dart
// Before
decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [Colors.white, Colors.grey[100]!],  // ❌ Static
  ),
)

// After
decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [
      AppColors.background(context),
      AppColors.text6(context),  // ✅ Dynamic
    ],
  ),
)
```

## Testing Checklist

After updating each screen, test:

- [ ] Screen renders correctly in **light mode**
- [ ] Screen renders correctly in **dark mode**
- [ ] Text is readable in both modes
- [ ] Buttons are visible in both modes
- [ ] Images/icons contrast well in both modes
- [ ] No white-on-white or black-on-black text
- [ ] Smooth transition when toggling dark mode
- [ ] Custom widgets respect theme
- [ ] Dialog boxes adapt to theme
- [ ] Bottom sheets adapt to theme

## Quick Find & Replace Patterns

Use VS Code's find & replace (Ctrl+Shift+H) with regex:

### Find: `AppColors\.(text3Light|text2Light|text4Light|backgroundLight)`
### Replace: Check each case manually and use context-aware version

### Common Replacements:
- `AppColors.text3Light` → `AppColors.text3(context)`
- `AppColors.text2Light` → `AppColors.text2(context)`
- `AppColors.backgroundLight` → `AppColors.background(context)`
- `AppColors.text4Light` → `AppColors.text4(context)`

## Tips

1. **Always pass BuildContext**: The dynamic methods need `context` to check theme
2. **Don't break working code**: If a screen looks good, leave static colors for now
3. **Test incrementally**: Update one screen at a time and test
4. **Use const where possible**: For colors that truly never change
5. **Consider accessibility**: Ensure good contrast in both modes

## Color Contrast Guidelines

Ensure text is readable:
- **Light mode**: Dark text on light backgrounds
- **Dark mode**: Light text on dark backgrounds
- **Minimum contrast ratio**: 4.5:1 for normal text, 3:1 for large text

## Questions?

If unsure whether to use static or dynamic:
- **Ask**: "Should this color change when user switches to dark mode?"
- **Yes** → Use dynamic method `AppColors.text(context)`
- **No** → Keep static `AppColors.textLight`

## Example: Complete Screen Migration

```dart
// BEFORE
class NewsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,  // ❌
      child: Column(
        children: [
          Text(
            'News Title',
            style: AppTextStyles.normal600(
              fontSize: 16,
              color: AppColors.text3Light,  // ❌
            ),
          ),
          Text(
            'Subtitle',
            style: TextStyle(
              color: AppColors.text5Light,  // ❌
            ),
          ),
        ],
      ),
    );
  }
}

// AFTER
class NewsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background(context),  // ✅
      child: Column(
        children: [
          Text(
            'News Title',
            style: AppTextStyles.normal600(
              fontSize: 16,
              color: AppColors.text3(context),  // ✅
            ),
          ),
          Text(
            'Subtitle',
            style: TextStyle(
              color: AppColors.text5(context),  // ✅
            ),
          ),
        ],
      ),
    );
  }
}
```

---

**Remember**: The goal is to make colors adapt to the theme automatically. Start with the most visible screens (home, news, e-library) and work your way through the app.
