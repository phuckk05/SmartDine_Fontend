# Changelog

All notable changes to the SmartDine project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added (feature/branch-management-dashboard)
- **Branch Management Dashboard** with interactive charts
  - Revenue line chart with 3 filters (Month/Week/Today)
  - Orders bar chart with 3 filters (Month/Week/Today)
  - Tap-to-show, release-to-hide tooltips
  - Quick action buttons (4 buttons)
  - Spending comparison cards with trend indicators

- **Dish Statistics Screen**
  - Bar chart with 4 time filters (Year/Month/Week/Today)
  - Data table with 6 columns
  - Top 6 dishes with revenue and quantity tracking
  - Interactive tooltips on chart bars

- **Branch Performance Screen**
  - Overview cards (orders, revenue, customers, rating)
  - Top 3 employees ranking with real names
  - Hourly revenue breakdown (6 time slots)
  - Top 5 dishes statistics

- **Order Management System**
  - Order list screen with 6 sample orders
  - Order detail screen with dynamic data per order
  - 4 status types: Paid, Serving, Pending, Cancelled
  - Employee tracking: Hà Đức Lương, Phúc, Tú Kiệt
  - Print invoice functionality

- **Notifications System**
  - 10 diverse notification types
  - 4 filter categories (All, Payment, Tables, Orders)
  - Icon-based visual system with color coding
  - Real-time status indicators (new/read)

- **Today Activities Screen**
  - Revenue card with trend comparison
  - Table statistics (52 tables)
  - Reservation tracking (8 reservations)
  - Payment status (38 paid, 14 unpaid)
  - Dishes sold breakdown
  - Cancelled orders tracking

- **Settings Screen**
  - Branch information display
  - Business license details
  - Employee count (43 staff)
  - Logout functionality

- **UI/UX Improvements**
  - Dark/Light mode support across all screens
  - Consistent design system with Google Fonts
  - Smooth animations and color transitions
  - Responsive layouts for all screen sizes

### Changed
- Updated package name from `smart_dine` to `mart_dine`
- Enhanced navigation with parameter passing
- Improved state management with StatefulWidget

### Dependencies
- Added `fl_chart: ^0.66.0` for interactive charts
- Configured Google Fonts integration

### Documentation
- Updated README.md with comprehensive project information
- Created BRANCH_MANAGEMENT_SUMMARY.md
- Created ORDER_DETAIL_UPDATE.md
- Created NOTIFICATIONS_IMPROVEMENT.md
- Added Pull Request template

---

## [0.1.0] - 2025-01-XX (Initial Release - Planned)

### Added
- Initial project setup
- Basic Flutter structure
- Core navigation routes
- Custom AppBar widget
- Style system with theme support

### Technical
- Flutter SDK: ^3.7.0-323.0.dev
- Dart SDK: ^3.7.0
- Android/iOS support configured
- Web support configured

---

## Future Releases

### [0.2.0] - API Integration (Planned)
- Backend API connection
- Real-time data synchronization
- User authentication system
- JWT token management

### [0.3.0] - Advanced Features (Planned)
- Multi-branch support
- Export reports (PDF/Excel)
- Inventory management
- Advanced analytics

### [0.4.0] - Mobile Enhancements (Planned)
- Push notifications
- Offline mode with local storage
- QR code scanning
- Payment gateway integration

### [1.0.0] - Production Release (Planned)
- Full feature set completed
- All tests passing
- Performance optimized
- Documentation completed
- Production deployment ready

---

## Contributors
- Hà Đức Lương
- Phúc
- Tú Kiệt

---

**Legend:**
- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security improvements
