#!/bin/bash
set -euo pipefail

MYSQL="/Applications/MAMP/Library/bin/mysql80/bin/mysql"
DUMP="/Applications/MAMP/Library/bin/mysql80/bin/mysqldump"
DB_USER="root"
DB_PASS="root"
DB_NAME="farkha"
MIGRATIONS_DIR="$(cd "$(dirname "$0")" && pwd)"
TRACKER_TABLE="_migrations"

run_sql() {
    "$MYSQL" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$1" 2>/dev/null
}

run_sql_file() {
    "$MYSQL" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$1" 2>/dev/null
}

if ! run_sql "SELECT 1 FROM $TRACKER_TABLE LIMIT 1;" &>/dev/null; then
    echo "📋 Creating migrations tracker table..."
    run_sql "CREATE TABLE IF NOT EXISTS $TRACKER_TABLE (
        id INT AUTO_INCREMENT PRIMARY KEY,
        migration VARCHAR(255) NOT NULL UNIQUE,
        applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"
fi

PENDING=()
APPLIED=0

for file in "$MIGRATIONS_DIR"/20*.sql; do
    [ -f "$file" ] || continue
    BASENAME=$(basename "$file")
    EXISTS=$(run_sql "SELECT COUNT(*) FROM $TRACKER_TABLE WHERE migration='$BASENAME';" 2>/dev/null | tail -1)
    if [ "$EXISTS" = "0" ]; then
        PENDING+=("$BASENAME")
    fi
done

if [ ${#PENDING[@]} -eq 0 ]; then
    echo "✅ All migrations already applied."
    exit 0
fi

echo "📦 Pending migrations: ${#PENDING[@]}"
for m in "${PENDING[@]}"; do
    echo "   → $m"
done
echo ""

for m in "${PENDING[@]}"; do
    echo "▶ Applying: $m"
    run_sql_file "$MIGRATIONS_DIR/$m"
    run_sql "INSERT INTO $TRACKER_TABLE (migration) VALUES ('$m');"
    APPLIED=$((APPLIED + 1))
done

echo ""
echo "🔄 Updating schema.sql dump..."
"$DUMP" -u "$DB_USER" -p"$DB_PASS" \
    --no-data \
    --skip-add-drop-table \
    --skip-comments \
    --complete-insert \
    "$DB_NAME" \
    | sed '/^-- Dump completed on/d' \
    > "$MIGRATIONS_DIR/schema.sql"
echo "   → schema.sql updated"

echo ""
echo "✅ Done! $APPLIED migration(s) applied and schema.sql synced."
