#!/usr/bin/env bash
set -euo pipefail

GQL_URL="${GRAPHQL_URL:-http://localhost:8080/graphql}"

gql() {
    local label="$1"
    local query="$2"
    local response
    response=$(curl -sf -X POST "$GQL_URL" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg q "$query" '{"query": $q}')")
    if echo "$response" | jq -e '.errors' > /dev/null 2>&1; then
        echo "❌ $label" >&2
        echo "$response" | jq '.errors' >&2
        exit 1
    fi
    echo "✅ $label"
    echo "$response"
}

echo "── GraphQL smoke tests ─────────────────────────────────────────────────"

gql "items query" '{ items(limit: 5) { id identifier name description createdAt } }' \
    | jq -e '.data.items | length >= 1' > /dev/null

gql "items where filter" '{ items(identifier: "hello") { id identifier name } }' \
    | jq -e '.data.items[0].identifier == "hello"' > /dev/null

gql "createItem mutation" \
    'mutation { createItem(name: "Smoke test", description: "CI smoke test") { id identifier name } }' \
    | jq -e '.data.createItem.identifier == "smoke-test"' > /dev/null

echo ""
echo "All GraphQL smoke tests passed."
