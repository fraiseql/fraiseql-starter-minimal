#!/usr/bin/env bash
set -euo pipefail

PSQL="psql -h localhost -U postgres -d starter --no-psqlrc -v ON_ERROR_STOP=1"

pass() { echo "✅ $1"; }
fail() { echo "❌ $1" >&2; exit 1; }

check_count() {
    local label="$1"
    local query="$2"
    local min="$3"
    local count
    count=$($PSQL -tAc "$query")
    if [ "$count" -ge "$min" ]; then
        pass "$label (count=$count)"
    else
        fail "$label: expected >= $min, got $count"
    fi
}

check_exists() {
    local label="$1"
    local query="$2"
    local count
    count=$($PSQL -tAc "$query")
    if [ "$count" -eq 1 ]; then
        pass "$label"
    else
        fail "$label: not found"
    fi
}

echo "── Tables ──────────────────────────────────────────────────────────────"
check_exists "table tb_item" \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='tb_item'"

echo "── Views ───────────────────────────────────────────────────────────────"
check_exists "view v_item" \
    "SELECT COUNT(*) FROM information_schema.views WHERE table_schema='public' AND table_name='v_item'"

echo "── Functions ───────────────────────────────────────────────────────────"
check_exists "function fn_create_item" \
    "SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema='public' AND routine_name='fn_create_item'"

echo "── Seed counts ─────────────────────────────────────────────────────────"
check_count "tb_item seed" "SELECT COUNT(*) FROM tb_item" 2

echo "── v_item columns ──────────────────────────────────────────────────────"
expected_cols="id identifier name description created_at"
actual_cols=$($PSQL -tAc \
    "SELECT string_agg(column_name, ' ' ORDER BY ordinal_position)
     FROM information_schema.columns
     WHERE table_schema='public' AND table_name='v_item'")
for col in $expected_cols; do
    if echo "$actual_cols" | grep -qw "$col"; then
        pass "v_item column: $col"
    else
        fail "v_item missing column: $col"
    fi
done

echo "── fn_create_item ──────────────────────────────────────────────────────"
new_id=$($PSQL -tAc \
    "SELECT id FROM fn_create_item('CI Test Item', 'Created by CI') LIMIT 1")
new_id=$(echo "$new_id" | tr -d '[:space:]')
if [ -z "$new_id" ]; then
    fail "fn_create_item returned no row"
fi
check_exists "fn_create_item result in v_item" \
    "SELECT COUNT(*) FROM v_item WHERE id = '$new_id'"
check_exists "fn_create_item identifier generated" \
    "SELECT COUNT(*) FROM v_item WHERE id = '$new_id' AND identifier = 'ci-test-item'"

if echo "$new_id" | grep -qE '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'; then
    pass "fn_create_item id is valid UUID"
else
    fail "fn_create_item id is not a valid UUID: $new_id"
fi

echo "── Cleanup ─────────────────────────────────────────────────────────────"
$PSQL -c "DELETE FROM tb_item WHERE id = '$new_id'"
pass "cleanup done"

echo ""
echo "All PostgreSQL integration tests passed."
