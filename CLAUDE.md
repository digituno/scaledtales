# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ScaledTales is a reptile/amphibian husbandry management app. Monorepo with NestJS backend (`backend/`) and Flutter mobile app (`mobile/`). Detailed specs live in `doc/` (01~07).

## Build & Run Commands

### Backend (NestJS)
```bash
cd backend
npm run start:dev          # Dev server with watch (port 3000)
npm run build              # Production build
npm run lint               # ESLint with auto-fix
npm run format             # Prettier format
npm run test               # Jest unit tests
npm run test:e2e           # E2E tests
```
Backend requires `backend/.env.development` (copy from `.env.example`). Swagger docs at `http://localhost:3000/api-docs`.

### Frontend (Flutter)
```bash
cd mobile
flutter pub get            # Install dependencies
flutter run                # Run on connected device/emulator
dart analyze               # Static analysis (must pass with zero issues)
flutter test               # Run widget tests
flutter test test/widget_test.dart  # Single test file
```
Localization auto-generates from ARB files via `l10n.yaml`. No manual `build_runner` needed for l10n.

## Architecture

### Backend
- **API prefix**: All endpoints under `/v1`
- **Response envelope**: `ResponseInterceptor` wraps all responses as `{ success: true, data, pagination? }`
- **Error handling**: `GlobalExceptionFilter` maps exceptions to `{ success: false, error: { code, message } }`
- **Auth**: Supabase Auth issues JWT → `JwtStrategy` (passport-jwt) validates → `@CurrentUser()` decorator extracts user
- **Supabase access**: `SupabaseService` (global module) provides `getClient()` and `getAdminAuth()` using SERVICE_ROLE_KEY
- **TypeORM**: Conditional loading — only connects if `DB_HOST` env var is set. Modules that depend on TypeORM (SpeciesModule, CountriesModule, AnimalsModule, MeasurementsModule, UploadModule, CareLogsModule) are pushed into imports inside the `if (process.env.DB_HOST)` block in `app.module.ts`.
- **Path aliases**: `@/*` → `src/*`, `@common/*` → `src/common/*`, `@config/*` → `src/config/*`

### Backend Modules
- **AuthModule**: JWT validation, `GET /auth/me` (응답에 `role` 포함 — `user_profile` 테이블 조회)
- **SpeciesModule**: Taxonomy hierarchy (class → order → family → genus → species), search, detail endpoints. Entities in `species/entities/`. Note: `TaxonomyClass` entity maps to `class` table (name avoids JS reserved word).
- **CountriesModule**: Country lookup (`GET /countries?lang=ko|en`)
- **AnimalsModule**: Full CRUD (`POST/GET/PATCH/DELETE /animals`). Ownership verification via `user_id`. Pagination, filtering by status/species_id. Species relation, breeding lineage (father_id/mother_id).
- **MeasurementsModule**: Nested routes (`POST/GET /animals/:animalId/measurements`, `PATCH/DELETE /measurements/:id`). Date range filtering. Ownership via animal relation. DB trigger auto-updates `animal.current_weight/current_length`.
- **UploadModule**: Supabase Storage integration. Profile image + care-log multi-image upload. File validation (5MB max, JPEG/PNG/WebP/HEIC).
- **CareLogsModule**: Full CRUD (`POST/GET /animals/:animalId/care-logs`, `GET /care-logs`, `GET/PATCH/DELETE /care-logs/:id`). JSONB `details` + `images` columns. Service-layer validation per log type (FEEDING implemented). Both `user_id` and `animal_id` for direct ownership check. `parent_log_id` self-reference for cascading logs (EGG_LAYING→CANDLING→HATCHING).

### Frontend
- **State management**: Riverpod (`StateNotifierProvider` for auth/search, `FutureProvider.family` for data fetching, `AsyncNotifierProvider.family` for list data, `FutureProvider` for userProfileProvider)
- **Role-based UI**: `userRoleProvider` (`Provider<UserRole>`) — `GET /auth/me`에서 role 조회. `role.canWrite`가 false(suspended)이면 생성·수정·삭제 버튼 비노출. Provider는 `features/auth/providers/user_profile_provider.dart`에 정의.
- **HTTP client**: Dio singleton (`DioClient`) with interceptor that auto-attaches Supabase session JWT and handles 401 logout
- **Auth flow**: `SplashScreen` checks session → routes to `MainShell` (authenticated) or `LoginScreen` (unauthenticated). Uses both `ref.listen` (future changes) and `ref.read` + `addPostFrameCallback` (already-resolved state).
- **Navigation**: `MainShell` uses `IndexedStack` + Drawer (`GlobalKey<ScaffoldState>`) with 5 menus (Home, Announcements, Animals, CareLogs, Settings). Each tab screen exposes `onOpenDrawer` callback for AppBar hamburger button. `AppDrawer` widget in `features/home/widgets/app_drawer.dart`.
- **Feature structure**: `lib/features/{feature}/providers/`, `screens/`, `widgets/`, `models/`
- **i18n**: ARB files in `lib/l10n/` (template: `app_ko.arb`). Access via `AppLocalizations.of(context)!`. Korean is primary locale.
- **API constants**: All endpoint paths defined in `core/constants/api_constants.dart`
- **Supabase config**: Hardcoded in `core/constants/app_config.dart` (URL + anon key)
- **Shared widgets**: `core/widgets/` — `AsyncValueWidget` (standard Riverpod AsyncValue handler with loading/error/retry), `EmptyStateWidget` (icon + title + subtitle + optional action). Import via `core/widgets/widgets.dart` barrel.

### Frontend Features
- **Animal**: Full CRUD — list (filtering by status), detail (tabbed: info/measurements/care logs), create/edit (5-step Stepper form), delete with confirmation
- **Measurement**: Growth charts via FL Chart (weight + length), period filter chips (1M/3M/6M/1Y/All), create/edit form with DatePicker. Integrated as Tab 2 in animal detail.
- **Species**: Taxonomy browsing (class→order→family→genus→species), search (ILIKE), detail view, selection mode for animal registration
- **Care log**: Full CRUD — list (Drawer menu with allCareLogsProvider, filter chips by log type), card widget (icon/color per type, summary, image thumbnails), 4-step Stepper form (Animal&Type, DateTime, Details, Photos&Memo), FEEDING details form (food_type/item/quantity/unit/supplements/response/method). Integrated as Tab 3 in animal detail via CareLogTab.

### Shared Patterns
- **ENUMs**: Backend (`src/common/enums/`) and frontend (`lib/core/enums/`) maintain matching enum definitions. Backend uses TypeScript string enums; frontend uses Dart enums with `fromValue()` static methods. Fixed codes are enums; dynamic data (species, countries) lives in DB. `UserRole` enum은 `user_profile.role` 값과 매핑 — `canWrite` getter로 쓰기 권한 판별.
- **i18n for enum labels**: Backend returns raw enum values; frontend translates them via ARB keys (e.g., `sexMale`, `originTypeCb`).
- **Nested resource routes**: Measurements are nested under animals (`/animals/:id/measurements`). Care logs similarly nested (`/animals/:id/care-logs`) with additional `GET /care-logs` for all user logs. Create/list use the nested path; update/delete use top-level resource paths.
- **Ownership verification**: All user-data services verify `user_id` from JWT matches the resource owner before allowing operations.

## Database

### Schema Overview
- **Taxonomy**: `class` → `order` → `family` → `genus` → `species` (hierarchical, CASCADE deletes)
- **Lookup**: `country` (ISO 3166-1 alpha-2, display_order)
- **User data**: `animal` (RLS), `measurement_log` (RLS + trigger), `care_log` (RLS + JSONB `details` + GIN index)
- **User profile**: `user_profile` (RLS) — `id` UUID FK → `auth.users`. `role` 컬럼 (admin/seller/pro_breeder/user/suspended). 신규 가입 시 `handle_new_user` 트리거로 자동 생성.
- **Trigger**: `trg_update_animal_measurement` auto-updates `animal.current_weight/current_length` on measurement insert

### RLS Policies
- Reference tables (class, order, family, genus, species, country): RLS enabled, `SELECT` allowed for everyone
- User data tables (animal, care_log): `auth.uid() = user_id`
- measurement_log: `animal_id IN (SELECT id FROM animal WHERE user_id = auth.uid())`
- user_profile: `auth.uid() = id` (SELECT/UPDATE)

### Migrations
Managed via Supabase MCP (`apply_migration` tool). Schema changes should use MCP migrations, not TypeORM's `synchronize`. TypeORM `synchronize: true` is only for development entity-to-table alignment.

## Supabase

Project ID: `wawxltmniilnicrwvlar` (region: ap-northeast-2). MCP is configured in `.mcp.json` (gitignored) for querying project info, running SQL, and managing migrations.

### DB Connection
Uses Supabase Pooler (Session mode): `aws-1-ap-northeast-2.pooler.supabase.com:5432`. Username format: `postgres.{project_id}`. Password with special chars must be double-quoted in `.env` files.

## Key Conventions
- Backend DTOs use `class-validator` decorators for input validation
- All user-data tables must have Row Level Security (RLS) policies
- Care log details stored as JSONB (flexible schema per log type: FEEDING, SHEDDING, DEFECATION, MATING, EGG_LAYING, CANDLING, HATCHING)
- Database uses UUID primary keys with cascade deletes
- Species search uses ILIKE for Korean/English/scientific name matching
