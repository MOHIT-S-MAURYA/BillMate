#!/bin/bash

# Theme Migration Helper Script
# This script helps identify files that need theme migration

echo "🎨 BillMate Theme Migration Helper"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to count occurrences
count_occurrences() {
    local pattern=$1
    local count=$(grep -r "$pattern" lib --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
    echo $count
}

# Function to find files with pattern
find_files() {
    local pattern=$1
    grep -r "$pattern" lib --include="*.dart" -l 2>/dev/null
}

echo "${BLUE}📊 Analyzing codebase for hardcoded colors...${NC}"
echo ""

# Count hardcoded white
white_count=$(count_occurrences "Colors\.white[^_]")
echo "${YELLOW}Colors.white:${NC} $white_count occurrences"

# Count hardcoded black
black_count=$(count_occurrences "Colors\.black[^_]")
echo "${YELLOW}Colors.black:${NC} $black_count occurrences"

# Count hardcoded grey
grey_count=$(count_occurrences "Colors\.grey")
echo "${YELLOW}Colors.grey:${NC} $grey_count occurrences"

# Count deprecated AppColors usage
appcolors_count=$(count_occurrences "AppColors\.(cardBackground|borderColor|dividerColor|textPrimary|textSecondary)")
echo "${YELLOW}Deprecated AppColors:${NC} $appcolors_count occurrences"

echo ""
echo "${BLUE}📁 Files requiring migration:${NC}"
echo ""

# Find files with hardcoded colors (excluding PDF and test files)
files_with_colors=$(grep -r "Colors\.\(white\|black\|grey\)" lib --include="*.dart" -l | \
    grep -v "pdf_service.dart" | \
    grep -v "test/" | \
    grep -v "app_theme.dart" | \
    grep -v "app_colors.dart" | \
    sort | uniq)

if [ -z "$files_with_colors" ]; then
    echo "${GREEN}✅ No files need migration!${NC}"
else
    priority_files=(
        "main_navigation.dart"
        "loading_widget.dart"
        "invoice_list_page.dart"
        "customer_list_page.dart"
        "add_customer_dialog.dart"
        "enhanced_payment_dialog.dart"
        "smart_customer_search_field.dart"
        "dashboard_page.dart"
        "billing_page.dart"
    )

    echo "${RED}Priority 1 - High Visibility:${NC}"
    for file in "${priority_files[@]}"; do
        matching=$(echo "$files_with_colors" | grep "$file" || true)
        if [ ! -z "$matching" ]; then
            echo "  • $matching"
            # Show line numbers
            grep -n "Colors\.\(white\|black\|grey\)" "$matching" | head -5 | sed 's/^/    Line /'
        fi
    done
    echo ""

    echo "${YELLOW}Other Files:${NC}"
    for file in $files_with_colors; do
        is_priority=false
        for pf in "${priority_files[@]}"; do
            if [[ "$file" == *"$pf"* ]]; then
                is_priority=true
                break
            fi
        done
        if [ "$is_priority" = false ]; then
            echo "  • $file"
        fi
    done
fi

echo ""
echo "${BLUE}🔍 Search Commands:${NC}"
echo ""
echo "Find all Colors.white:"
echo "  ${GREEN}grep -rn 'Colors\.white' lib --include='*.dart'${NC}"
echo ""
echo "Find all Colors.black:"
echo "  ${GREEN}grep -rn 'Colors\.black' lib --include='*.dart'${NC}"
echo ""
echo "Find deprecated AppColors:"
echo "  ${GREEN}grep -rn 'AppColors\.\(cardBackground\|borderColor\|textPrimary\)' lib --include='*.dart'${NC}"
echo ""

echo "${BLUE}📝 Quick Migration Commands:${NC}"
echo ""
echo "1. Open a file for editing:"
echo "   ${GREEN}code lib/path/to/file.dart${NC}"
echo ""
echo "2. Run analyzer to check for errors:"
echo "   ${GREEN}flutter analyze${NC}"
echo ""
echo "3. Test the app:"
echo "   ${GREEN}flutter run${NC}"
echo ""

echo "${BLUE}📚 Documentation:${NC}"
echo "  • THEME_MIGRATION_GUIDE.md - Detailed migration patterns"
echo "  • THEME_IMPLEMENTATION_SUMMARY.md - Current status and checklist"
echo ""

echo "${GREEN}✅ Analysis complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Start with Priority 1 files listed above"
echo "2. Refer to THEME_MIGRATION_GUIDE.md for patterns"
echo "3. Test in both light and dark modes after each change"
echo "4. Use 'flutter analyze' to catch errors"
