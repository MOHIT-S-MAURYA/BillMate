# BillMate UI/UX Enhancement Roadmap

This document outlines the planned tasks to improve the app's user experience, making it more professional, intuitive, and efficient.

---

### Phase 1: Core Experience & Onboarding

- [ ] **1.1. First-Time User Onboarding**: Create a skippable, multi-step tutorial on first launch to guide users through setting up their business, adding inventory, and creating an invoice.
- [ ] **1.2. Consistent Empty States & Loading UI**: Replace blank screens and simple loaders with illustrative "Empty State" widgets (e.g., "No invoices yet. Create one!") and modern "shimmer" loading effects.
- [ ] **1.3. Refine App Theme & Typography**: Centralize theme data, establish a clear typography scale, and ensure full dark mode support for a more cohesive look.

### Phase 2: Dashboard & Navigation

- [ ] **2.1. Interactive Dashboard Cards**: Make dashboard statistics (Total Sales, Items in Store) tappable, navigating directly to the relevant report or page.
- [ ] **2.2. Dashboard "Quick Actions"**: Add prominent buttons on the dashboard for the most common tasks: `+ New Invoice`, `+ New Item`, `+ New Customer`.

### Phase 3: Feature Enhancements

- [ ] **3.1. Redesign On-Screen Invoice View**: Rework the `InvoiceDetailPage` to display items in a clean, professional table format, mirroring the PDF design.
- [ ] **3.2. Barcode/QR Code Scanning**: Integrate a barcode scanner to quickly add items to invoices and look up products in the inventory.
- [ ] **3.3. Interactive Charts**: Upgrade reports with interactive charts (using `fl_chart`) that allow tapping to view details and filtering data series.

### Phase 4: Polish & Final Touches

- [ ] **4.1. Enhanced Form Validation**: Implement real-time form validation with visual cues (checkmarks for success, icons for errors).
- [ ] **4.2. Granular Report Filtering**: Add multi-select and "Group By" options to all reports for deeper data analysis.
- [ ] **4.3. Review and Refine All UI**: Conduct a final pass on all screens to ensure consistency, fix minor layout issues, and improve animations.
