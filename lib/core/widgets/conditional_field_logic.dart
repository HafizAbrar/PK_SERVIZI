class ConditionalFieldLogic {
  static bool shouldHideField(dynamic field, Map<String, dynamic> formValues, List<dynamic>? allFields) {
    // Check explicit conditions first
    if (field.conditionalOn != null) {
      return !evaluateCondition(field.conditionalOn, formValues);
    }

    if (field.dependsOn != null) {
      return !evaluateCondition(field.dependsOn, formValues);
    }

    // Fallback: infer from field name patterns
    return _inferHiddenFromFieldName(field, formValues, allFields);
  }

  static bool _inferHiddenFromFieldName(dynamic field, Map<String, dynamic> formValues, List<dynamic>? allFields) {
    if (allFields == null) return false;
    
    final fieldNameLower = field.name.toLowerCase();
    final fieldLabelLower = field.label.toLowerCase();
    
    // Check if field contains documentation/receipt keywords
    final hasDocKeyword = fieldNameLower.contains('document') || 
                         fieldNameLower.contains('receipt') ||
                         fieldLabelLower.contains('document') ||
                         fieldLabelLower.contains('receipt');
    
    if (!hasDocKeyword) return false;
    
    // Find any related radio button by checking if names/labels share keywords
    for (var radioField in allFields) {
      if (radioField.type == 'radio') {
        final selectedValue = formValues[radioField.name];
        final radioNameLower = radioField.name.toLowerCase();
        final radioLabelLower = radioField.label.toLowerCase();
        
        // Extract keywords from both field and radio
        final fieldKeywords = _extractKeywords(fieldNameLower + ' ' + fieldLabelLower);
        final radioKeywords = _extractKeywords(radioNameLower + ' ' + radioLabelLower);
        
        // Check if they share any keywords (excluding common words)
        final hasCommonKeyword = fieldKeywords.any((kw) => radioKeywords.contains(kw));
        
        if (hasCommonKeyword && (selectedValue == 'No' || selectedValue == 'no')) {
          return true;
        }
      }
    }
    return false;
  }

  static List<String> _extractKeywords(String text) {
    return text
        .split(RegExp(r'[\s_-]+'))
        .where((word) => word.length > 2 && !['the', 'and', 'for', 'you', 'are', 'have', 'do', 'or'].contains(word))
        .toList();
  }

  static bool evaluateCondition(Map<String, dynamic> condition, Map<String, dynamic> formValues) {
    final fieldName = condition['field'] as String?;
    final operator = condition['operator'] as String?;
    final value = condition['value'];

    if (fieldName == null || operator == null) {
      return true;
    }

    final fieldValue = formValues[fieldName];

    switch (operator) {
      case 'equals':
        return fieldValue == value;
      case 'notEquals':
        return fieldValue != value;
      case 'in':
        if (value is List) {
          return value.contains(fieldValue);
        }
        return false;
      case 'notIn':
        if (value is List) {
          return !value.contains(fieldValue);
        }
        return false;
      default:
        return true;
    }
  }

  static bool shouldHideFileButtons(dynamic field, Map<String, dynamic> formValues) {
    if (field.name.toLowerCase().contains('receipt') && field.name.toLowerCase().contains('permit')) {
      final expiryDateStr = formValues['expiryDate']?.toString() ?? '';
      if (expiryDateStr.isEmpty) return false;

      try {
        final expiryDate = DateTime.parse(expiryDateStr);
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);
        final expiryDateOnly = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
        
        return todayOnly.isBefore(expiryDateOnly) || todayOnly.isAtSameMomentAs(expiryDateOnly);
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
