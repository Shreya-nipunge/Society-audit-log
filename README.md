# 🏛️ Society Audit Log

> **Digitized maintenance billing, payment tracking & audit records for cooperative housing societies.**

[![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)](https://flutter.dev)
[![Next.js](https://img.shields.io/badge/Next.js-16-000000?logo=nextdotjs)](https://nextjs.org)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore+Auth+Storage-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Private-red)]()

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Problem Statement](#-problem-statement)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Setup Instructions](#-setup-instructions)
- [User Roles & Access](#-user-roles--access)
- [API Overview](#-api-overview)
- [Usage Guide](#-usage-guide)
- [Audit System](#-audit-system)
- [Future Scope](#-future-scope)

---

## 🧠 Overview

**Society Audit Log** is a dual-platform application (Flutter mobile + Next.js web dashboard) designed to replace manual record-keeping in Indian cooperative housing societies (CHS). It provides structured, transparent, and audit-ready financial management — from member billing and payment tracking to expense recording and document storage.

**Currently deployed for:** Shivkrupasagar CHS Ltd. (29 members, 4 floors)

### Key Highlights
- 🔐 **Role-based access** — Chairman, Secretary, Treasurer, Member
- 📊 **Audit-ready** — Immutable audit trail for every financial action
- 📱 **Mobile-first** — Elder-friendly UI for quick payment recording
- 🖥️ **Web dashboard** — Admin-heavy operations with charts & reports
- ☁️ **Real-time sync** — Firestore live data across all devices
- 📄 **PDF generation** — Client-side receipts, bills, and reports

---

## 🚨 Problem Statement

Small cooperative housing societies face critical challenges:

| Problem | Impact |
|---|---|
| **Paper registers & Excel sheets** | No single source of truth. Data scattered across WhatsApp, diaries, and personal laptops. |
| **No audit trail** | Excel files are freely editable. No way to prove who changed what. |
| **Leadership transitions** | New committee loses access to old records. Years of financial history lost. |
| **Audit panic** | Societies scramble to reconstruct records weeks before statutory audits. |
| **Trust deficit** | Members suspect financial mismanagement but have no visibility into records. |

**Society Audit Log** solves this by making the system **audit-ready by design** — every action is logged, every financial entry is traceable, and data persists independently of the people who enter it.

---

## ✨ Features

### Mobile App (Flutter)

| Feature | Description |
|---|---|
| **Mock Authentication** | Admin-created accounts. Members log in with flat number as password. |
| **Role-Based Dashboards** | Chairman, Secretary, Treasurer, and Member each see their own dashboard. |
| **Member Management** | Add/edit/deactivate members. Bulk import from Excel. |
| **Payment Recording** | Record cash/UPI/cheque payments with automatic fund allocation (Maintenance 70%, Sinking 20%, Repairs 10%). |
| **Receipt Generation** | PDF receipts generated client-side. Share via WhatsApp. |
| **Bill Generation** | Generate monthly maintenance demand notices for all members. |
| **Expense Tracking** | 35+ audit-grade expense categories with vendor info, approval chain, and proof upload. |
| **Reports** | Fund balances, collection summaries, expense summaries with PDF export. |
| **Audit Logs** | Immutable, chronological record of every system action. |
| **Document Storage** | Upload/view AGM minutes, audit reports, circulars. Role-based visibility. |
| **Notices** | Create and publish society-wide announcements. |
| **Complaints** | Members submit complaints. Admin tracks resolution. |
| **Fund Allocation Editor** | Customize how payments are split across funds. |
| **System Health** | Admin view of system status. |

### Web Dashboard (Next.js)

| Feature | Description |
|---|---|
| **Admin Login** | Chairman/Secretary/Treasurer login with dedicated credentials. |
| **Overview Dashboard** | KPI cards, revenue vs expense charts, expense breakdown pie chart, recent activity feed. |
| **Members Management** | Full member list with ledger data. Add/edit via modal. |
| **Transactions View** | All recorded payments with details. |
| **Bills View** | All generated bills with status tracking. |
| **Expenses View** | Society expenses with categorization. |
| **Notices Management** | Create/publish notices. |
| **Documents** | View uploaded society documents. |
| **Audit Logs** | Chronological system activity log. |
| **Reports** | Visual charts powered by Recharts. |

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Mobile App | **Flutter 3.9+** (Dart) | Cross-platform mobile (Android/iOS) |
| Web Dashboard | **Next.js 16** (React 19, TypeScript) | Admin web interface |
| Styling (Web) | **Tailwind CSS v4** | Utility-first CSS framework |
| Charts (Web) | **Recharts 3.8** | Data visualization |
| Database | **Cloud Firestore** | NoSQL real-time database |
| Authentication | **Firebase Auth** | Email/password authentication |
| File Storage | **Firebase Storage** | Document and receipt storage |
| PDF Generation | **pdf + printing** (Dart packages) | Client-side PDF rendering |
| State (Mobile) | **Provider 6.1** + Static MockData | State management |
| Icons (Web) | **Lucide React** | Icon library |

---

## 🏗️ Architecture

```
┌──────────────────────┐     ┌──────────────────────────┐
│   Flutter Mobile App  │     │  Next.js Web Dashboard   │
│   (Members + Admins)  │     │  (Admin-heavy workflows) │
└──────────┬────────────┘     └───────────┬──────────────┘
           │                              │
           └──────────┬───────────────────┘
                      │
                      ▼
           ┌────────────────────┐
           │   Firebase Platform │
           │                    │
           │  • Firestore (DB)  │
           │  • Auth            │
           │  • Storage         │
           │  • Security Rules  │
           └────────────────────┘
```

**Architecture style**: Serverless Modular Monolith
- No custom backend server — Firebase handles all server-side concerns
- Feature-based module separation in Flutter (`lib/features/`)
- Real-time data sync via Firestore SDK (no REST APIs)
- Firestore Security Rules act as the authorization layer

---

## 📁 Project Structure

```
Society Audit Log/
├── lib/                              # Flutter mobile app source
│   ├── main.dart                     # App entry point + route definitions
│   ├── firebase_options.dart         # Firebase config (auto-generated)
│   ├── core/
│   │   ├── constants/                # App strings, constants
│   │   ├── guards/
│   │   │   └── role_guard.dart       # Route-level role enforcement
│   │   ├── services/
│   │   │   └── firestore_service.dart # Firestore CRUD streams
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # Material theme config
│   │   │   ├── app_colors.dart       # Color palette
│   │   │   └── app_text_styles.dart  # Typography
│   │   ├── utils/
│   │   │   ├── mock_data.dart        # In-memory data + Firestore sync
│   │   │   ├── real_society_data.dart # Seed data (29 real members)
│   │   │   ├── session_manager.dart  # Auth session singleton
│   │   │   ├── permission_manager.dart # Feature-level permissions
│   │   │   ├── validators.dart       # Form validation
│   │   │   └── firebase_seeder.dart  # Initial data seeding
│   │   └── widgets/
│   │       └── error_boundary.dart   # Global error handler
│   └── features/
│       ├── auth/
│       │   ├── models/user_model.dart     # UserModel + UserRole enum
│       │   ├── screens/login_screen.dart
│       │   └── services/auth_service.dart # Firebase Auth wrapper (stubbed)
│       ├── admin/
│       │   ├── screens/                   # Admin, Chairman, Treasurer dashboards
│       │   └── widgets/                   # Admin-specific UI components
│       ├── member/
│       │   ├── models/
│       │   └── screens/                   # Member dashboard, dues, profile
│       ├── payments/
│       │   ├── models/
│       │   │   ├── transaction_model.dart
│       │   │   └── fund_allocation.dart
│       │   ├── screens/                   # Record payment, allocation editor
│       │   └── services/
│       │       ├── payment_service.dart
│       │       └── receipt_service.dart   # PDF receipt generation
│       ├── billing/
│       │   ├── models/
│       │   │   ├── bill_model.dart
│       │   │   └── demand_notice_model.dart
│       │   ├── screens/
│       │   └── services/billing_service.dart
│       ├── audit/
│       │   ├── models/
│       │   │   ├── audit_log_model.dart
│       │   │   ├── document_model.dart
│       │   │   └── expense_model.dart     # 35+ expense categories
│       │   ├── screens/
│       │   └── services/audit_service.dart # Log generation
│       ├── reports/
│       │   ├── screens/reports_screen.dart
│       │   └── services/
│       │       ├── report_service.dart
│       │       └── report_export_service.dart # PDF report builder
│       ├── notices/
│       │   ├── models/notice_model.dart
│       │   └── screens/
│       ├── complaints/
│       │   ├── models/complaint_model.dart
│       │   └── screens/
│       └── splash/
│           └── splash_screen.dart
│
├── web-dashboard/                    # Next.js web admin panel
│   ├── src/
│   │   ├── app/
│   │   │   ├── layout.tsx            # Root layout with AuthProvider
│   │   │   ├── page.tsx              # Landing redirect
│   │   │   ├── login/                # Web login page
│   │   │   └── dashboard/
│   │   │       ├── page.tsx          # Main dashboard with charts
│   │   │       ├── layout.tsx        # Sidebar + header layout
│   │   │       ├── members/
│   │   │       ├── transactions/
│   │   │       ├── bills/
│   │   │       ├── expenses/
│   │   │       ├── notices/
│   │   │       ├── documents/
│   │   │       ├── audit-logs/
│   │   │       └── reports/
│   │   ├── components/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── StatsCard.tsx
│   │   │   ├── MemberModal.tsx
│   │   │   ├── ExpenseModal.tsx
│   │   │   └── NoticeModal.tsx
│   │   └── lib/
│   │       ├── firebase.ts           # Firebase client init
│   │       ├── auth.tsx              # AuthContext + AuthProvider
│   │       ├── firestore-service.ts  # Real-time Firestore listeners
│   │       ├── types.ts             # TypeScript interfaces
│   │       ├── hooks.ts             # Custom React hooks
│   │       ├── mock-data.ts         # Fallback mock data
│   │       ├── society-members.ts   # Member data
│   │       └── utils.ts            # Formatting utilities
│   ├── package.json
│   └── tsconfig.json
│
├── firestore.rules                   # Firestore security rules
├── storage.rules                     # Firebase Storage rules
├── firestore_schema_erd.html         # Interactive ERD diagram
├── pubspec.yaml                      # Flutter dependencies
├── android/                          # Android platform config
├── ios/                              # iOS platform config
├── assets/                           # Images, icons
└── README.md                         # This file
```

---

## 🚀 Setup Instructions

### Prerequisites

- **Flutter SDK** >= 3.9.0 ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Node.js** >= 18 ([Install Node.js](https://nodejs.org/))
- **Firebase CLI** ([Install Firebase CLI](https://firebase.google.com/docs/cli))
- **Android Studio** or **VS Code** with Flutter extension
- A **Firebase project** with Firestore, Auth, and Storage enabled

### 1. Clone the Repository

```bash
git clone https://github.com/Shreya-nipunge/Society-audit-log.git
cd Society-audit-log
```

### 2. Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in the project (select Firestore, Auth, Storage)
firebase init

# Deploy security rules
firebase deploy --only firestore:rules,storage:rules
```

Create a `.env` file in the project root with your Firebase config:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
```

### 3. Flutter Mobile App

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build APK for distribution
flutter build apk --release
```

### 4. Next.js Web Dashboard

```bash
cd web-dashboard

# Install dependencies
npm install

# Create .env.local with Firebase web config
cp .env.local.example .env.local
# Edit .env.local with your Firebase credentials

# Run development server
npm run dev
# → Opens at http://localhost:3000

# Build for production
npm run build
npm start
```

### 5. Seed Initial Data

The app comes pre-seeded with 29 real member records from Shivkrupasagar CHS Ltd. via `RealSocietyData`. For a fresh Firebase project:

```bash
cd web-dashboard
node seed_firestore.js
```

---

## 🔐 User Roles & Access

### Default Accounts (MVP)

| Role | Email | Password | Platform |
|---|---|---|---|
| Chairman | `chairman@society.com` | `123456` | Mobile + Web |
| Secretary | `secretary@society.com` | `123456` | Mobile + Web |
| Treasurer | `treasurer@society.com` | `123456` | Mobile + Web |
| Member (Flat 204) | `kedarpatankar@gmail.com` | `204` | Mobile only |
| Member (Flat 001) | `pradnyasabhyankar@gmail.com` | `001` | Mobile only |

> ⚠️ Members use their **flat number** as password. Admin accounts use `123456`.

### Permission Matrix

| Capability | Chairman | Secretary | Treasurer | Member |
|---|---|---|---|---|
| View Dashboard | ✅ | ✅ | ✅ | ✅ (own data) |
| Manage Members | ✅ | ✅ | ✅ | ❌ |
| Record Payments | ✅ | ✅ | ✅ | ❌ |
| Generate Bills | ✅ | ❌ | ✅ | ❌ |
| View Reports | ✅ | ✅ | ✅ | ❌ |
| Upload Documents | ✅ | ✅ | ❌ | ❌ |
| Create Notices | ✅ | ✅ | ❌ | ❌ |
| View Audit Logs | ✅ | ✅ | ✅ | ❌ |
| Record Expenses | ✅ | ✅ | ✅ | ❌ |
| Edit Fund Allocation | ✅ | ❌ | ✅ | ❌ |
| Bulk Import | ✅ | ✅ | ❌ | ❌ |
| System Health | ✅ | ✅ | ❌ | ❌ |
| Submit Complaints | ❌ | ❌ | ❌ | ✅ |
| Manage Complaints | ✅ | ✅ | ✅ | ❌ |

---

## 📡 API Overview

The system uses **Firebase SDK direct access** — there is no REST API server. Both clients communicate with Firestore using their respective SDKs.

### Firestore Collections

| Collection | Description | Read Access | Write Access |
|---|---|---|---|
| `users` | Member profiles + ledger data | Own profile or Admin | Admin only |
| `transactions` | Payment records | Admin + recorded-by user | Admin only |
| `bills` | Monthly demand notices | Own bills or Admin | Admin only |
| `expenses` | Society expenditures | Admin only | Admin only |
| `notices` | Society announcements | All authenticated | Admin only |
| `documents` | Uploaded files | Based on visibility | Admin only |
| `audit_logs` | System action trail | Admin only | Admin only |

### Real-Time Listeners (Firestore Streams)

```typescript
// Web Dashboard examples
subscribeToMembers(callback)      // users collection, ordered by flatNumber
subscribeToTransactions(callback) // transactions, ordered by paidAt DESC
subscribeToBills(callback)        // bills, ordered by dueDate DESC
subscribeToExpenses(callback)     // expenses, ordered by expenseDate DESC
subscribeToNotices(callback)      // notices, ordered by createdAt DESC
subscribeToDocuments(callback)    // documents, ordered by uploadedAt DESC
subscribeToAuditLogs(callback)    // audit_logs, ordered by timestamp DESC
```

---

## 📖 Usage Guide

### Admin Workflow: Monthly Billing Cycle

1. **Generate Bills** → Navigate to Generate Bills → Enter month, maintenance amount, water charges, other charges → System creates a bill for each active member

2. **Record Payments** → As members pay (cash/UPI/cheque) → Record Payment → Select member → Enter amount + mode → Fund allocation auto-calculated → Receipt generated

3. **Track Collections** → Treasurer Dashboard shows: total collected, pending dues, fund balances (maintenance, sinking, repairs)

4. **Record Expenses** → When society spends (e.g., lift repair) → Record Expense → Select category (35+ options) → Enter vendor, amount, payment proof → Approve

5. **Generate Reports** → Reports screen → Fund Balance Report / Collection Report / Expense Summary → Export as PDF

6. **Publish Notices** → Create Notice → Enter title + body → Publish → All members see it on their dashboard

### Member Workflow

1. **Login** → Enter email + flat number as password
2. **View Dashboard** → See outstanding dues, recent payments, active notices
3. **Check Dues** → My Dues → Detailed breakdown of charges
4. **Payment History** → View all past payments with receipt numbers
5. **Download Receipt** → From payment history → Share via WhatsApp
6. **Submit Complaint** → Report an issue (water, parking, noise, etc.)

---

## 🔍 Audit System

The audit system is the **core differentiator** of this application. Every significant action is logged automatically.

### What Gets Logged

| Action | Logged Data |
|---|---|
| Payment recorded | Who recorded, for which member, amount, payment mode |
| Member added/edited/deactivated | Who changed, what changed (old → new values) |
| Bill generated | Who generated, for which month, total amount |
| Report exported | Who exported, report type |
| Document uploaded | Who uploaded, document category |
| Notice published | Who published, notice title |
| Expense recorded | Who recorded, category, amount |
| User login | Who logged in, role |

### Audit Log Format

```
[2026-04-09T20:00:00] System Treasurer (Treasurer)
→ PAYMENT_RECORDED on member_21 (M.A. Ramnathkar, ₹3,000)
  Old: Outstanding ₹5,725
  New: Outstanding ₹2,725
```

### Accessing Audit Logs

- **Mobile**: Navigate to Audit Logs → Filter by category (All/Members/Payments/Reports)
- **Web**: Dashboard → Audit Logs → Chronological feed with real-time updates

---

## 🔮 Future Scope

| Feature | Priority | Description |
|---|---|---|
| **Real Firebase Auth** | 🔴 High | Migrate from mock auth to Firebase Auth with proper password hashing |
| **Payment Gateway** | 🟡 Medium | Razorpay integration for online payments |
| **Scheduled Billing** | 🟡 Medium | Cloud Functions for automatic monthly bill generation |
| **Push Notifications** | 🟡 Medium | Payment reminders, notice alerts via FCM |
| **Multi-Society Support** | 🟡 Medium | Multi-tenant architecture with `societyId` isolation |
| **Auditor Role** | 🟡 Medium | Read-only access specifically for chartered accountants |
| **Bank Reconciliation** | 🟢 Low | Import bank CSV, auto-match payments |
| **GST/TDS Compliance** | 🟢 Low | Tax calculation and filing support |
| **AI Analytics** | 🟢 Low | Payment prediction, expense anomaly detection |
| **OCR Receipt Scanning** | 🟢 Low | Camera → auto-fill expense fields |

---

## 👥 Contributors

- **Shreya Nipunge** — Project Lead & Developer

---

## 📄 License

This project is **private** and developed for Shivkrupasagar CHS Ltd. Unauthorized distribution is prohibited.

---

<p align="center">
  <strong>Built with ❤️ for transparent society management</strong>
</p>
