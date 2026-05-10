# Farkha Admin — Progress Report

**Date:** 2026-05-09
**Status:** Phase 1-4 implemented (backend + Flutter)

## Completed

### Backend (PHP)
- **Migration:** `migrations/2026_05_09_admin_panel.sql` — 3 tables (`admin_users`, `admin_sessions`, `admin_audit_log`)
- **Rollback:** `migrations/rollback_2026_05_09_admin_panel.sql`
- **Seed script:** `scripts/seed_first_admin.php` (CLI-only)
- **Core classes:**
  - `core/AdminAuth.php` — login, logout, token verification, audit logging
  - `core/AdminBaseApi.php` — extends BaseApi with AdminAuth
  - `core/RemoteConfigService.php` — Firebase Remote Config CRUD
- **Auth endpoints:** `admin/auth/login.php`, `logout.php`, `me.php`
- **Dashboard:** `admin/dashboard/overview.php` — 12+ KPIs + 30-day timeline
- **Remote Config:** `admin/remote_config/get.php`, `update.php`, `delete.php`
- **Updated existing:** All `admin/prices/` and `admin/articles/` now use `AdminBaseApi` + audit
- **Phase 2:** Users (list/detail/delete/send_notification), Cycles (list/detail/force_close/soft_delete/restore/hard_delete), Categories & Types (full CRUD)
- **Phase 3:** Notifications (broadcast/topic/user), Reviews (app + cycle feedbacks)
- **Phase 4:** DB schema/preview/SQL select, Cache stats/clear, Audit log, Account deletions stats

### Flutter Admin App
- **Rewritten** with GetX + dark theme + Cairo font + RTL
- **Screens:** Login, Dashboard (KPIs + charts), Remote Config, Users, User Detail, Cycles, Notifications, Reviews, Categories/Types, System (DB/Cache/Audit)
- **API client:** Bearer token auth with auto-logout on 401
- **Analysis:** 0 errors, 0 warnings (only deprecation infos for `withOpacity`)

## Before Running

1. Run the migration: `mysql -u root -p farkha < backend_farkha/migrations/2026_05_09_admin_panel.sql`
2. Seed admin: `php backend_farkha/scripts/seed_first_admin.php nims YOUR_PASSWORD`
3. Delete seed script after use
4. Test login: `curl -X POST https://your-domain/backend_farkha/admin/auth/login.php -H 'Content-Type: application/json' -d '{"username":"nims","password":"YOUR_PASSWORD"}'`
5. Verify existing endpoints reject requests without Bearer token

## Known Limitations
- Prices/Articles/Analytics screens are placeholders (existing functionality preserved in backend)
- `kreait/firebase-php` Remote Config `deleteParameter` depends on SDK version — check `withRemovedParameter` availability
- No `.htaccess` added inside `admin/` directory yet (consider IP allowlist)
