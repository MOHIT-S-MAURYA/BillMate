# BillMate - GST-Compliant Billing Software

BillMate is a comprehensive, offline-first billing software designed specifically for Indian shops and businesses. Built with Flutter, it provides GST-compliant invoicing, inventory management, customer management, and detailed reporting features.

## 🌟 Features

### ✅ Core Features
- **Offline-First Operation** - Works without internet connectivity
- **GST Compliance** - Full support for Indian GST calculations (CGST, SGST, IGST)
- **Invoice Generation** - Professional PDF invoices with customizable templates
- **Inventory Management** - Track stock levels, HSN codes, and pricing
- **Customer Management** - Store customer details with GSTIN validation
- **Reports & Analytics** - Comprehensive business reports and exports

### 🔧 Technical Features
- **Cross-Platform** - Works on Android, iOS, Windows, macOS, and Linux
- **SQLite Database** - Reliable offline data storage
- **Clean Architecture** - SOLID principles and maintainable code structure
- **State Management** - BLoC pattern for predictable state management
- **Dependency Injection** - Modular and testable architecture
- **Code Generation** - Freezed models and JSON serialization

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                   # Core application infrastructure
│   ├── constants/         # App-wide constants
│   ├── database/          # SQLite database setup
│   ├── di/               # Dependency injection setup
│   ├── errors/           # Error handling and failures
│   └── utils/            # Utility functions (GST calculator, etc.)
├── features/             # Feature-based modules
│   ├── auth/            # Authentication (future)
│   ├── billing/         # Invoice and billing management
│   ├── inventory/       # Product and inventory management
│   ├── reports/         # Reports and analytics
│   └── settings/        # App settings and configuration
└── shared/              # Shared UI components and utilities
    ├── constants/       # Shared constants (colors, strings)
    ├── utils/          # Shared utility functions
    └── widgets/        # Reusable UI components
```

Each feature follows the same structure:
- **data/** - Data sources, models, and repository implementations
- **domain/** - Business logic, entities, and repository interfaces
- **presentation/** - UI layer with BLoC, pages, and widgets

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd billmate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Development Setup

1. **Install recommended VS Code extensions:**
   - Flutter
   - Dart
   - Awesome Flutter Snippets

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Generate code after model changes**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## 🎯 Key Technologies

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **SQLite** - Offline database storage
- **BLoC** - State management pattern
- **get_it** - Dependency injection
- **Freezed** - Immutable data classes
- **json_annotation** - JSON serialization
- **PDF** - Invoice PDF generation
- **Decimal** - Precise financial calculations

## 📱 Business Requirements

### GST Compliance
- Support for all GST rates (0%, 5%, 12%, 18%, 28%)
- Automatic CGST/SGST calculation for intra-state transactions
- IGST calculation for inter-state transactions
- HSN code management
- State code validation

### Invoice Features
- Professional PDF invoice generation
- Customizable invoice templates
- Sequential invoice numbering
- Multiple payment status tracking
- Customer and business information
- Itemized billing with tax breakdowns

### Inventory Management
- Product catalog with categories
- Stock level tracking
- Low stock alerts
- Price management (purchase/selling)
- Unit of measurement tracking

### Customer Management
- Customer database with GSTIN validation
- Contact information management
- Transaction history
- State-wise customer classification

## 🧪 Testing Strategy

- **Unit Tests** - Business logic and utility functions
- **Widget Tests** - UI component testing
- **Integration Tests** - End-to-end user flows
- **Test Coverage** - Maintaining >80% code coverage

## 📊 Database Schema

The application uses SQLite with the following main tables:
- `items` - Product catalog
- `categories` - Product categories
- `customers` - Customer information
- `invoices` - Invoice headers
- `invoice_items` - Invoice line items
- `settings` - Application configuration

## 🔐 Security & Privacy

- **Local Data Storage** - All data stored locally on device
- **No Cloud Dependency** - Complete offline operation
- **Data Backup** - Export capabilities for data backup
- **Business Data Protection** - Secure local database

## 🚧 Future Enhancements

- Multi-business support
- Cloud synchronization (optional)
- Advanced reporting and analytics
- Barcode scanning
- Payment integration
- Multi-currency support
- Advanced inventory features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support and questions, please open an issue in the repository or contact the development team.

---

**BillMate** - Simplifying billing for Indian businesses with GST compliance and offline-first design.
