-- Minimal starter schema
-- FraiseQL reads from views (v_*) and calls functions (fn_*)

-- ── Table ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS tb_item (
    id          UUID        NOT NULL DEFAULT gen_random_uuid(),
    identifier  TEXT        NOT NULL UNIQUE,
    name        TEXT        NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT pk_item PRIMARY KEY (id)
);

-- ── View ──────────────────────────────────────────────────────────────────────

-- View used by the `items` and `item` queries
CREATE OR REPLACE VIEW v_item AS
SELECT
    id,
    identifier,
    name,
    description,
    created_at::TEXT AS created_at
FROM tb_item;

-- ── Functions ─────────────────────────────────────────────────────────────────

-- Function used by the `create_item` mutation
CREATE OR REPLACE FUNCTION fn_create_item(
    p_name        TEXT,
    p_description TEXT DEFAULT NULL
) RETURNS SETOF v_item AS $$
DECLARE
    v_identifier TEXT;
    v_id         UUID;
BEGIN
    v_identifier := lower(regexp_replace(p_name, '[^a-zA-Z0-9]+', '-', 'g'));
    INSERT INTO tb_item (identifier, name, description)
    VALUES (v_identifier, p_name, p_description)
    RETURNING id INTO v_id;
    RETURN QUERY SELECT * FROM v_item WHERE id = v_id;
END;
$$ LANGUAGE plpgsql;

-- ── Seed data ─────────────────────────────────────────────────────────────────

INSERT INTO tb_item (identifier, name, description) VALUES
    ('hello', 'Hello', 'Your first FraiseQL item'),
    ('world', 'World', 'Another item to get you started')
ON CONFLICT (identifier) DO NOTHING;
