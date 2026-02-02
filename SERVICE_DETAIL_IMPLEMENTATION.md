# Service Detail Screen Implementation

## Overview
The service detail screen has been updated to display the API response data according to your requirements:

### Features Implemented:
1. **Service Information Display**: Shows name, code, description, category, and price
2. **Required Documents Section**: Lists all required documents with their details (name, category, required status)
3. **Form Schema Sections**: Displays form section titles in tile view format
4. **FAQs Section**: Includes frequently asked questions at the end

## API Response Mapping

The screen now properly maps the API response from:
```
GET https://api.pkservizi.com/api/v1/services/457ea6ba-3074-400d-9940-e88bb1db283f
```

### Data Models Created:
- `Service`: Main service model
- `RequiredDocument`: For document requirements
- `FormSchema`: For form structure
- `FormSection`: For form sections
- `FormField`: For individual form fields
- `ServiceTypeInfo`: For service type information

## Screen Sections:

### 1. Service Details Card
- **Name**: Model 730 Standard
- **Code**: 730_STANDARD
- **Description**: Standard tax declaration for employees and retirees
- **Category**: TAX
- **Price**: €60.00

### 2. Required Documents
Each document shows:
- Document name (e.g., "Valid ID", "Certificazione Unica (CU)")
- Category (e.g., "IDENTITY", "INCOME", "EXPENSES")
- Required status (Required/Optional badge)

### 3. Required Information (Form Sections)
Displays form schema sections as tiles:
- "Dati Anagrafici" (4 fields required)
- "Redditi (CU, INPS, altri)" (3 fields required)
- "Spese Sanitarie" (2 fields required)
- "Famiglia" (2 fields required)

### 4. FAQs Section
Expandable FAQ items covering:
- Processing time
- Required documents
- Request tracking
- Customer support

## Navigation
The screen is accessible via:
- Route: `/services/:id`
- Example: `/services/457ea6ba-3074-400d-9940-e88bb1db283f`

## Usage
```dart
// Navigate to service detail
context.push('/services/457ea6ba-3074-400d-9940-e88bb1db283f');

// Or using named route
AppNavigation.goNamed('service-detail', 
  pathParameters: {'id': '457ea6ba-3074-400d-9940-e88bb1db283f'}
);
```

## Action Button
The bottom action button shows:
- "Start Service Request - €60.00"
- Navigates to service request creation with the service ID

## Error Handling
- Loading state with progress indicator
- Error state with retry functionality
- Graceful handling of missing data

The implementation is minimal and focused, displaying exactly the information requested while maintaining a clean, user-friendly interface.