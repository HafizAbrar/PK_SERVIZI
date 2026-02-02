#!/bin/bash

# Replace hardcoded colors with theme references across all Dart files

# Primary color replacements
find lib -name "*.dart" -type f -exec sed -i 's/const Color(0xFF1B5E20)/AppTheme.primaryColor/g' {} \;
find lib -name "*.dart" -type f -exec sed -i 's/Color(0xFF1B5E20)/AppTheme.primaryColor/g' {} \;

# Add theme import to files that use AppTheme
find lib -name "*.dart" -type f -exec grep -l "AppTheme\." {} \; | while read file; do
    if ! grep -q "import.*app_theme.dart" "$file"; then
        # Calculate relative path to theme file
        depth=$(echo "$file" | tr -cd '/' | wc -c)
        depth=$((depth - 1))  # Subtract 1 for lib/ directory
        
        if [ $depth -eq 1 ]; then
            import_path="import 'core/theme/app_theme.dart';"
        elif [ $depth -eq 2 ]; then
            import_path="import '../core/theme/app_theme.dart';"
        elif [ $depth -eq 3 ]; then
            import_path="import '../../core/theme/app_theme.dart';"
        elif [ $depth -eq 4 ]; then
            import_path="import '../../../core/theme/app_theme.dart';"
        elif [ $depth -eq 5 ]; then
            import_path="import '../../../../core/theme/app_theme.dart';"
        else
            import_path="import '../../../../../core/theme/app_theme.dart';"
        fi
        
        # Add import after the last import statement
        sed -i "/^import /a\\$import_path" "$file"
    fi
done

echo "Theme migration completed!"