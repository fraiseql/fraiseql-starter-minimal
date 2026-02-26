-- Minimal starter schema
-- FraiseQL reads from views (v_*) and calls functions (fn_*)

CREATE TABLE IF NOT EXISTS items (
    id          SERIAL PRIMARY KEY,
    name        TEXT        NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- View used by the `items` and `item` queries
CREATE OR REPLACE VIEW v_item AS
SELECT
    id,
    name,
    description,
    created_at::TEXT AS created_at
FROM items;

-- Function used by the `create_item` mutation
CREATE OR REPLACE FUNCTION fn_create_item(
    p_name        TEXT,
    p_description TEXT DEFAULT NULL
) RETURNS SETOF v_item AS $$
    INSERT INTO items (name, description)
    VALUES (p_name, p_description)
    RETURNING *;
$$ LANGUAGE sql;

-- Seed data
INSERT INTO items (name, description) VALUES
    ('Hello', 'Your first FraiseQL item'),
    ('World', 'Another item to get you started');
