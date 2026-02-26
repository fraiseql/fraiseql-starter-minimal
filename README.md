# fraiseql/starter-minimal

The smallest possible FraiseQL project: **one type, two queries, one mutation, PostgreSQL**.

Use this to verify your installation or as a blank canvas.

## What's inside

| File | Purpose |
|------|---------|
| `schema.py` | Type and query definitions (authoring layer) |
| `fraiseql.toml` | Project and runtime configuration |
| `init.sql` | PostgreSQL table, view, and seed data |
| `docker-compose.yml` | One-command local stack |
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
query {
  items(limit: 5) {
    id
    name
    description
    createdAt
  }
}

query {
  item(id: 1) {
    id
    name
  }
}

mutation {
  createItem(name: "My item", description: "Created via GraphQL") {
    id
    name
    createdAt
  }
}
```

## GraphQL schema generated

```graphql
type Item {
  id: Int!
  name: String!
  description: String
  createdAt: String!
}

type Query {
  items(limit: Int, offset: Int): [Item!]!
  item(id: Int!): Item
}

type Mutation {
  createItem(name: String!, description: String): Item!
}
```

## Next steps

- `starter-blog` — posts, authors, tags, full-text search
- `starter-saas` — multi-tenant, auth, subscriptions, NATS
