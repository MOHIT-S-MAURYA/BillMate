# BillMate Theme Migration Guide

This guide helps migrate from hardcoded colors to theme-aware components following Material Design 3 principles.

## Overview

**What Changed:**

- ✅ New color system with proper light/dark mode support
- ✅ Material Design 3 compliance
- ✅ Consistent ColorScheme usage throughout
- ✅ Automatic theme switching based on system preferences

**Theme Structure:**

- **Light Theme**: Primary #1565C0 (Blue 800), Background #F5F5F5, Surface #FFFFFF
- **Dark Theme**: Primary #90CAF9 (Blue 200), Background #121212, Surface #1E1E1E

## Migration Patterns

### ❌ BEFORE → ✅ AFTER

#### 1. Background Colors

**❌ BEFORE - Hardcoded white:**

```dart
Container(
  color: Colors.white,
  child: Text('Content'),
)
```

**✅ AFTER - Theme-aware:**

```dart
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text('Content'),
)
```

#### 2. Text Colors

**❌ BEFORE - Hardcoded black:**

```dart
Text(
  'Hello',
  style: TextStyle(color: Colors.black),
)
```

**✅ AFTER - Theme-aware:**

```dart
Text(
  'Hello',
  style: TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)
```

Or better yet, use theme text styles:

```dart
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

#### 3. Card Backgrounds

**❌ BEFORE - Hardcoded colors:**

```dart
Card(
  color: Colors.white,
  child: ListTile(
    title: Text('Item', style: TextStyle(color: Colors.black)),
  ),
)
```

**✅ AFTER - Uses theme automatically:**

```dart
Card(
  // No color needed, uses theme
  child: ListTile(
    title: Text('Item'), // No style needed, uses theme
  ),
)
```

#### 4. AppBar

**❌ BEFORE - Hardcoded colors:**

```dart
AppBar(
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  title: Text('Title'),
)
```

**✅ AFTER - Theme-aware:**

```dart
AppBar(
  // Uses theme colors automatically
  title: Text('Title'),
)
```

#### 5. Elevated Buttons

**❌ BEFORE - Hardcoded colors:**

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  onPressed: () {},
  child: Text('Submit'),
)
```

**✅ AFTER - Uses theme:**

```dart
ElevatedButton(
  // No style needed, uses theme
  onPressed: () {},
  child: Text('Submit'),
)
```

#### 6. TextFormField

**❌ BEFORE - Hardcoded colors:**

```dart
TextFormField(
  decoration: InputDecoration(
    fillColor: Colors.white,
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
  ),
)
```

**✅ AFTER - Uses theme:**

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    // All styling comes from theme
  ),
)
```

#### 7. Scaffold Background

**❌ BEFORE - Hardcoded color:**

```dart
Scaffold(
  backgroundColor: Colors.white,
  body: Content(),
)
```

**✅ AFTER - Uses theme:**

```dart
Scaffold(
  // No backgroundColor needed, uses theme
  body: Content(),
)
```

#### 8. Dividers

**❌ BEFORE - Hardcoded color:**

```dart
Divider(color: Colors.grey, thickness: 1)
```

**✅ AFTER - Uses theme:**

```dart
Divider() // Uses theme colors and thickness
```

#### 9. Icon Colors

**❌ BEFORE - Hardcoded colors:**

```dart
Icon(Icons.home, color: Colors.blue)
```

**✅ AFTER - Theme-aware:**

```dart
Icon(
  Icons.home,
  color: Theme.of(context).colorScheme.primary,
)
```

Or use IconTheme:

```dart
IconTheme(
  data: IconThemeData(
    color: Theme.of(context).colorScheme.primary,
  ),
  child: Icon(Icons.home),
)
```

#### 10. Conditional Theme Colors

**❌ BEFORE - Manual brightness check:**

```dart
Container(
  color: MediaQuery.of(context).platformBrightness == Brightness.dark
      ? Colors.black
      : Colors.white,
)
```

**✅ AFTER - Use ColorScheme:**

```dart
Container(
  color: Theme.of(context).colorScheme.surface,
)
```

## ColorScheme Properties Reference

### Light Mode Colors

| Property             | Light Theme Value        | Usage                                    |
| -------------------- | ------------------------ | ---------------------------------------- |
| `primary`            | #1565C0 (Blue 800)       | Main brand color, buttons, active states |
| `onPrimary`          | #FFFFFF                  | Text/icons on primary color              |
| `primaryContainer`   | #BBDEFB (Blue 100)       | Subtle primary backgrounds               |
| `onPrimaryContainer` | #0D47A1 (Blue 900)       | Text on primaryContainer                 |
| `secondary`          | #0288D1 (Light Blue 700) | Secondary actions                        |
| `onSecondary`        | #FFFFFF                  | Text/icons on secondary                  |
| `error`              | #D32F2F (Red 700)        | Error states                             |
| `onError`            | #FFFFFF                  | Text/icons on error                      |
| `surface`            | #FFFFFF                  | Cards, dialogs, sheets                   |
| `onSurface`          | #212121 (Grey 900)       | Text/icons on surface                    |
| `outline`            | #BDBDBD (Grey 400)       | Borders, dividers                        |

### Dark Mode Colors

| Property             | Dark Theme Value         | Usage                      |
| -------------------- | ------------------------ | -------------------------- |
| `primary`            | #90CAF9 (Blue 200)       | Main brand color           |
| `onPrimary`          | #0D47A1 (Blue 900)       | Text/icons on primary      |
| `primaryContainer`   | #0D47A1                  | Subtle primary backgrounds |
| `onPrimaryContainer` | #BBDEFB                  | Text on primaryContainer   |
| `secondary`          | #4FC3F7 (Light Blue 300) | Secondary actions          |
| `onSecondary`        | #01579B                  | Text/icons on secondary    |
| `error`              | #EF9A9A (Red 200)        | Error states               |
| `onError`            | #B71C1C (Red 900)        | Text/icons on error        |
| `surface`            | #1E1E1E                  | Cards, dialogs, sheets     |
| `onSurface`          | #E0E0E0 (Grey 300)       | Text/icons on surface      |
| `outline`            | #424242 (Grey 800)       | Borders, dividers          |

## Common Use Cases

### 1. Creating Custom Containers

```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Theme.of(context).colorScheme.outline,
    ),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      'Content',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  ),
)
```

### 2. Status Colors (Success, Warning, Info)

```dart
// Import AppColors for status colors
import 'package:billmate/shared/constants/app_colors.dart';

// Success
Container(
  color: AppColors.success, // Light theme: #4CAF50
  child: Text(
    'Success!',
    style: TextStyle(color: Colors.white),
  ),
)

// In dark theme, AppColors.success adapts automatically
final isDark = Theme.of(context).brightness == Brightness.dark;
Container(
  color: isDark ? AppColors.successDark : AppColors.success,
  child: Text('Success!'),
)
```

### 3. Gradient Backgrounds

```dart
import 'package:billmate/shared/constants/app_colors.dart';

Container(
  decoration: BoxDecoration(
    gradient: Theme.of(context).brightness == Brightness.dark
        ? AppGradients.primaryDark
        : AppGradients.primary,
  ),
)
```

### 4. Elevated Surfaces (Cards, Dialogs)

```dart
// For cards and elevated components, always use surface color
Card(
  // Automatically uses theme surface color
  elevation: 2,
  child: Content(),
)

// For custom elevated containers
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Content(),
)
```

## Typography Guidelines

Use theme text styles instead of creating custom ones:

```dart
// Display styles (large headlines)
Text('Display', style: Theme.of(context).textTheme.displayLarge)
Text('Display', style: Theme.of(context).textTheme.displayMedium)
Text('Display', style: Theme.of(context).textTheme.displaySmall)

// Headline styles (section titles)
Text('Headline', style: Theme.of(context).textTheme.headlineLarge)
Text('Headline', style: Theme.of(context).textTheme.headlineMedium)
Text('Headline', style: Theme.of(context).textTheme.headlineSmall)

// Title styles (card titles, list items)
Text('Title', style: Theme.of(context).textTheme.titleLarge)
Text('Title', style: Theme.of(context).textTheme.titleMedium)
Text('Title', style: Theme.of(context).textTheme.titleSmall)

// Body styles (main content)
Text('Body', style: Theme.of(context).textTheme.bodyLarge)
Text('Body', style: Theme.of(context).textTheme.bodyMedium)
Text('Body', style: Theme.of(context).textTheme.bodySmall)

// Label styles (buttons, captions)
Text('Label', style: Theme.of(context).textTheme.labelLarge)
Text('Label', style: Theme.of(context).textTheme.labelMedium)
Text('Label', style: Theme.of(context).textTheme.labelSmall)
```

## Files to Update

### Priority 1 - Core UI Components

- [ ] `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- [ ] `lib/features/billing/presentation/pages/*.dart`
- [ ] `lib/features/inventory/presentation/pages/*.dart`
- [ ] `lib/shared/widgets/**/*.dart`

### Priority 2 - Dialogs and Forms

- [ ] All dialog files in `lib/**/dialogs/*.dart`
- [ ] All form files in `lib/**/widgets/*_form.dart`

### Priority 3 - List Items and Cards

- [ ] All list item widgets
- [ ] All card widgets
- [ ] All custom container widgets

## Search and Replace Strategy

1. **Find hardcoded Colors.white for backgrounds:**

   ```
   Search: color:\s*Colors\.white
   Review and replace with: color: Theme.of(context).colorScheme.surface
   ```

2. **Find hardcoded Colors.black for text:**

   ```
   Search: color:\s*Colors\.black
   Review and replace with: color: Theme.of(context).colorScheme.onSurface
   ```

3. **Find hardcoded Colors.grey for borders:**

   ```
   Search: color:\s*Colors\.grey
   Review and replace with: color: Theme.of(context).colorScheme.outline
   ```

4. **Find old AppColors usage:**
   ```
   Search: AppColors\.(primary|secondary|textPrimary|surface|background)(?!Dark)
   Review usage and update to Theme.of(context).colorScheme
   ```

## Testing Checklist

After migrating each file:

- [ ] Build the app successfully
- [ ] Test in light mode - verify no white/black hardcoded colors
- [ ] Test in dark mode - verify proper contrast and readability
- [ ] Check dialogs and bottom sheets
- [ ] Check form fields and inputs
- [ ] Check buttons and interactive elements
- [ ] Verify text is readable in both modes
- [ ] Check borders and dividers are visible

## Deprecation Warnings

The following AppColors properties are deprecated:

```dart
// ❌ Deprecated - will be removed
AppColors.cardBackground
AppColors.borderColor
AppColors.dividerColor
AppColors.textPrimary
AppColors.textSecondary
AppColors.getBorderColor(context)
AppColors.getPrimaryColor(context)
// ... and other context-aware getters

// ✅ Use instead
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.outline
Theme.of(context).colorScheme.onSurface
```

## Tips and Best Practices

1. **Always use Theme.of(context)** - Never hardcode colors
2. **Use ColorScheme properties** - They adapt automatically to light/dark
3. **Prefer theme text styles** - Better consistency and accessibility
4. **Test both themes** - Always verify both light and dark modes
5. **Use semantic colors** - `surface` for backgrounds, `onSurface` for text
6. **Avoid manual brightness checks** - ColorScheme handles this
7. **Use proper elevation** - Cards, dialogs, sheets have proper shadows
8. **Consistent spacing** - Use theme spacing values

## Need Help?

Common issues and solutions:

**Issue**: Text not visible in dark mode
**Solution**: Use `Theme.of(context).colorScheme.onSurface` instead of `Colors.black`

**Issue**: White backgrounds in dark mode
**Solution**: Use `Theme.of(context).colorScheme.surface` instead of `Colors.white`

**Issue**: Borders not visible
**Solution**: Use `Theme.of(context).colorScheme.outline` instead of `Colors.grey`

**Issue**: Need custom color for specific state
**Solution**: Use AppColors status colors or create adaptive color:

```dart
final customColor = Theme.of(context).brightness == Brightness.dark
    ? Color(0xFF...)  // Dark mode color
    : Color(0xFF...); // Light mode color
```
