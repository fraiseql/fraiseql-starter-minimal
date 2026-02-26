# fraiseql/starter-minimal

[![CI](https://github.com/fraiseql/fraiseql-starter-minimal/actions/workflows/ci.yml/badge.svg)](https://github.com/fraiseql/fraiseql-starter-minimal/actions/workflows/ci.yml)
[![Docker](https://ghcr-badge.egpl.dev/fraiseql/fraiseql-starter-minimal/latest_tag?label=ghcr.io)](https://github.com/fraiseql/fraiseql-starter-minimal/pkgs/container/fraiseql-starter-minimal)

The smallest possible FraiseQL project: **one type, two queries, one mutation, PostgreSQL**.

Use this to verify your installation or as a blank canvas.

## What's inside

| File | Purpose |
|------|---------|
| `schema.py` | Type and query definitions (authoring layer) |
| `fraiseql.toml` | Project and runtime configuration |
| `init.sql` | PostgreSQL table, view, function, and seed data |
| `docker-compose.yml` | One-command local stack |
| `Dockerfile` | Multi-stage image for self-hosting |
| `.env.example` | Environment variable template |

## Quickstart (Docker)

```bash
# 1. Copy environment file
cp .env.example .env

# 2. Generate schema.json (requires Python + fraiseql package)
pip install fraiseql
python schema.py

# 3. Compile schema
fraiseql compile

# 4. Start the stack
docker compose up
```

The GraphQL API is at **http://localhost:8080/graphql**.

## Quickstart (local binary)

```bash
cp .env.example .env
source .env

pip install fraiseql
python schema.py
fraiseql compile
fraiseql run
```

## Example queries

```graphql
# List with pagination and ordering
query {
  items(limit: 5, offset: 0, orderBy: { createdAt: DESC }) {
    id
    identifier
    name
    createdAt
  }
}

# Filter by identifier
query {
  items(identifier: "hello") {
    id
    identifier
    name
  }
}

# Create an item — returns the full entity, including its generated UUID and identifier
mutation {
  createItem(name: "My item", description: "Created via GraphQL") {
    id
    identifier
    name
    createdAt
  }
}

# Fetch by UUID — use the id returned by the mutation above
query GetItem($id: ID!) {
  item(id: $id) {
    id
    identifier
    name
    description
    createdAt
  }
}
# variables: { "id": "018e4c1a-3f2b-7a9d-b1c8-4d2e5f6a7b8c" }
```

## GraphQL schema generated

```graphql
type Item {
  id: ID!
  identifier: String!
  name: String!
  description: String
  createdAt: String!
}

type Query {
  items(limit: Int, offset: Int, orderBy: ItemOrder, ...filters): [Item!]!
  item(id: ID!): Item
}

type Mutation {
  createItem(name: String!, description: String): Item!
}
```

## Next steps

- `starter-blog` — posts, authors, tags, full-text search
- `starter-saas` — multi-tenant, auth, subscriptions, NATS
