# Print Options Feature

## Overview

Added comprehensive print options dialog that allows users to customize what information appears on printed invoices.

## Features

### 1. **Invoice Display Options**

- **Show Tax Columns**: Toggle to show/hide tax rate and tax amount columns in the invoice table

### 2. **Issuer Details Options**

Users can now choose which business information to display in the invoice header:

- **Business Address**: Show/hide the business address
- **Phone Number**: Show/hide the phone number
- **Email Address**: Show/hide the email address
- **GSTIN**: Show/hide the GST identification number

## User Experience

### Print Options Dialog

When printing an invoice (from either Create Invoice or Invoice Detail pages), users see a clean dialog with:

```
┌─────────────────────────────────────┐
│ Print Options                       │
├─────────────────────────────────────┤
│ Invoice Display Options             │
│ ☑ Show Tax Columns                  │
│   Display tax rate and amount...    │
│                                     │
│ ─────────────────────────────────   │
│                                     │
│ Issuer Details to Show              │
│ ☑ Business Address                  │
│   Show business address in header   │
│ ☑ Phone Number                      │
│   Show phone number in header       │
│ ☑ Email Address                     │
│   Show email address in header      │
│ ☑ GSTIN                             │
│   Show GST identification number    │
│                                     │
│         [Cancel]  [Print Invoice]   │
└─────────────────────────────────────┘
```

### Dialog Features

- **Clear Sections**: Separated into "Invoice Display Options" and "Issuer Details"
- **Checkboxes**: Easy toggle with visual feedback
- **Descriptions**: Each option has a subtitle explaining what it does
- **Default Values**: All options enabled by default
- **Smart Defaults**: Tax option respects the "Show Tax on Bill" setting from invoice creation

## Technical Implementation

### Files Modified

#### 1. `pdf_service.dart`

Added new optional parameters to `generateAndPrintInvoice`:

```dart
static Future<void> generateAndPrintInvoice(
  Invoice invoice, {
  String? customerName,
  String? customerEmail,
  bool showTax = true,
  bool showAddress = true,      // NEW
  bool showPhone = true,         // NEW
  bool showEmail = true,         // NEW
  bool showGstin = true,         // NEW
}) async
```

The header builder now conditionally includes issuer details:

```dart
_buildModernHeader(
  issuerName,
  showAddress ? businessAddress : null,
  showPhone ? businessPhone : null,
  showEmail ? businessEmail : null,
  showGstin ? businessGstin : null,
)
```

#### 2. `invoice_detail_page.dart`

- Updated `_printInvoice()` method to show print options dialog
- Added `_PrintOptionsDialog` widget with state management
- Passes selected options to PDF service

#### 3. `create_invoice_page.dart`

- Updated `_previewAndPrint()` method to be async
- Shows print options dialog before generating PDF
- Added `_PrintOptionsDialog` widget (with `defaultShowTax` parameter)
- Passes selected options to PDF service

### Print Options Dialog Widget

```dart
class _PrintOptionsDialog extends StatefulWidget {
  final bool defaultShowTax; // Optional, used in create_invoice_page

  @override
  State<_PrintOptionsDialog> createState() => _PrintOptionsDialogState();
}

class _PrintOptionsDialogState extends State<_PrintOptionsDialog> {
  late bool showTax;
  bool showAddress = true;
  bool showPhone = true;
  bool showEmail = true;
  bool showGstin = true;

  // Returns Map<String, bool> with selected options
}
```

## Use Cases

### Example 1: Minimal Invoice

User wants a clean invoice without contact details:

- ☐ Business Address
- ☐ Phone Number
- ☐ Email Address
- ☑ GSTIN (required for compliance)

Result: Invoice shows only business name and GSTIN

### Example 2: No Tax Invoice

User wants to hide all tax information:

- ☐ Show Tax Columns
- ☑ All issuer details

Result: Invoice has no tax columns, clean summary section

### Example 3: Full Details

User wants everything (default):

- ☑ All options enabled

Result: Professional invoice with complete information

## Benefits

1. **Privacy Control**: Choose what information to share
2. **Clean Invoices**: Remove unnecessary details for simpler invoices
3. **Flexibility**: Different invoices can have different information
4. **Professional**: Customize per client/situation
5. **User-Friendly**: Simple checkbox interface
6. **Consistent**: Same dialog in both create and view pages

## Data Flow

```
User clicks Print
    ↓
Show Print Options Dialog
    ↓
User selects options
    ↓
Dialog returns Map<String, bool>
    ↓
Pass options to PdfService.generateAndPrintInvoice()
    ↓
PDF Service conditionally includes/excludes sections
    ↓
Generate PDF with selected options
    ↓
Print/Share PDF
```

## Future Enhancements

Possible future additions:

- Save user preferences for print options
- Different presets (e.g., "Minimal", "Standard", "Full")
- Per-customer default print options
- Include/exclude invoice notes
- Show/hide payment terms
- Custom header/footer text
- Logo upload and display toggle

## Testing Checklist

- [ ] Print from Create Invoice page shows dialog
- [ ] Print from Invoice Detail page shows dialog
- [ ] Cancel button dismisses dialog without printing
- [ ] All checkboxes toggle correctly
- [ ] Tax option defaults to invoice's showTaxOnBill setting
- [ ] PDF correctly hides/shows address when toggled
- [ ] PDF correctly hides/shows phone when toggled
- [ ] PDF correctly hides/shows email when toggled
- [ ] PDF correctly hides/shows GSTIN when toggled
- [ ] PDF correctly hides/shows tax columns when toggled
- [ ] Header layout remains clean when details are hidden
- [ ] All options disabled creates minimal invoice
- [ ] All options enabled creates full invoice
