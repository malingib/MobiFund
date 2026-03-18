# Gemini Code Assistant Context: MobiFund Project

This document provides a comprehensive overview of the MobiFund project for the Gemini Code Assistant, enabling it to understand the project's architecture, technologies, and development conventions.

## 1. Project Overview

**MobiFund** is a mobile application built with **Flutter** for managing group finances, specifically tailored for informal savings groups in Kenya known as "Chamas" or SACCOs. It provides a robust, multi-tenant platform where each group (organization) can manage its members, track contributions and expenses, and activate various financial modules.

The backend is powered by **Supabase**, which handles authentication, the PostgreSQL database, and serverless Edge Functions for backend logic.

The application is designed with an **offline-first** architecture, utilizing a local SQLite database for core data and ensuring functionality even with intermittent connectivity. Data is then synchronized with the Supabase backend when an internet connection is available.

### Core Features:

*   **Multi-Tenancy:** Each organization's data is isolated.
*   **Role-Based Access Control (RBAC):** Differentiates between Admins, Treasurers, Secretaries, and Members with specific permissions.
*   **Modular System:** Organizations can enable/disable modules like:
    *   Loans (Soft and Normal)
    *   Merry-Go-Round (Rotational Savings)
    *   Shares & Savings
    *   Goals & Investments
    *   Welfare (Member Support Fund)
*   **Offline-First Sync:** Uses a local SQLite database that syncs with the Supabase backend.
*   **Integrations:**
    *   **SMS Notifications:** via Mobiwave API for key events.
    *   **M-Pesa (Planned):** For automatic payment reconciliation.
*   **Platform Administration:** A separate interface for super admins to manage the platform and provide support.

## 2. Technologies & Architecture

*   **Frontend:** Flutter (v3.x)
*   **State Management:** `provider` package.
*   **Backend:** Supabase (PostgreSQL, Auth, Edge Functions)
*   **Local Database:** `sqflite` (SQLite)
*   **Key Packages:**
    *   `supabase_flutter`: For Supabase integration.
    *   `provider`: For state management.
    *   `sqflite`: For local persistence.
    *   `fl_chart`: For charts and reports.
    *   `http`: For external API calls (e.g., SMS).
    *   `flutter_dotenv`: For managing environment variables.

## 3. Building and Running the Project

### Prerequisites:

*   Flutter SDK installed.
*   An `.env` file in the project root containing Supabase credentials.

### `.env` File Structure:

Create a file named `.env` in the root of the project with the following content:

```
SUPABASE_URL=YOUR_SUPABASE_PROJECT_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Build & Run Commands:

1.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run the Application:**
    ```bash
    flutter run
    ```

3.  **Run Tests (if any):**
    ```bash
    flutter test
    ```

## 4. Key File Locations

*   **Main Entry Point:** `lib/main.dart`
*   **Data Models:**
    *   Core Models: `lib/models/models.dart`
    *   Module-specific Models: `lib/models/module_models.dart`
*   **UI Screens:** `lib/screens/` (Organized by feature)
*   **Core Services:**
    *   **Supabase Service:** `lib/services/supabase_service.dart` (Handles all backend communication)
    *   **Local Database Service:** `lib/services/local_db.dart`
    *   **App State:** `lib/services/app_state.dart` (Manages global application state like online status, user permissions, etc.)
    *   **Sync Service:** `lib/services/sync_service.dart` (Orchestrates data synchronization between local DB and Supabase)
*   **Backend Logic:**
    *   **Supabase Migrations:** `supabase/migrations/` (Defines the database schema)
    *   **Edge Functions:** `supabase/functions/` (Server-side TypeScript functions)
*   **Architectural Documentation:** `ARCHITECTURE.md` (Provides a detailed diagram and explanation of the system design)

## 5. Development Conventions

*   **State Management:** The project uses the `provider` package for state management. Services or states that need to be globally accessible are provided at the top of the widget tree in `lib/main.dart`.
*   **Offline-First:** When adding or modifying data, changes should be written to the local SQLite database first via `LocalDbService`. The `SyncService` is then responsible for pushing these changes to Supabase. Data fetching should prioritize the local database and fall back to Supabase.
*   **Environment Variables:** All secrets, especially Supabase keys, **must** be managed via the `.env` file and accessed through `flutter_dotenv`. Do not hardcode credentials.
*   **Code Style:** The project follows the conventions defined in `analysis_options.yaml`, which includes the `flutter_lints` package. All new code should adhere to these linting rules.
*   **Error Handling:** Use `try-catch` blocks for all network and database operations. Log errors to the debug console for easier debugging.
*   **Permissions:** Before displaying a UI element or allowing an action that requires specific permissions, always check the user's role and permissions using `AppState.hasPermission(UserRole)`.
