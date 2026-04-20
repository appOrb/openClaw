---
name: postgres-migration
description: Write and apply PostgreSQL schema migrations for the ai_waiter.database repo
modelHint: repetitive
---

# PostgreSQL Migration Skill

## Repo: `appOrb/ai_waiter.database`
Structure: `migrations/`, `seeds/`, `scripts/`. Single initial migration: `migrations/001_initial_schema.sql`.

## Migration Naming Convention
```
migrations/
  001_initial_schema.sql
  002_add_orders_table.sql     ← sequential number + snake_case description
  003_add_menu_categories.sql
```

## Migration Template
```sql
-- migrations/002_add_orders_table.sql
-- Description: Add orders and order_items tables
-- Date: YYYY-MM-DD

BEGIN;

CREATE TABLE IF NOT EXISTS orders (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_id    UUID NOT NULL REFERENCES tables(id),
    status      VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id    UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_items(id),
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL
);

CREATE INDEX idx_orders_table_id ON orders(table_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

COMMIT;
```

## Applying Migrations
```bash
# Direct psql
psql -h <host> -U <user> -d aiwaiter -f migrations/002_add_orders_table.sql

# Via script (check scripts/ for existing runner)
bash scripts/migrate.sh
```

## Rollback Pattern
```sql
-- Always include a rollback comment at the top:
-- ROLLBACK: DROP TABLE IF EXISTS order_items, orders;
```

## Seed Data
```sql
-- seeds/menu_items.sql
INSERT INTO menu_items (id, name, price, category_id) VALUES
  (gen_random_uuid(), 'Burger', 12.99, '<category-id>'),
  (gen_random_uuid(), 'Pizza', 14.99, '<category-id>')
ON CONFLICT DO NOTHING;
```
