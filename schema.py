"""FraiseQL Minimal Starter — schema definition.

One type, two queries, one mutation, PostgreSQL.

Run this to generate schema.json:
    python schema.py

Then compile and run:
    fraiseql compile
    fraiseql run
"""

import fraiseql
from fraiseql import ID


@fraiseql.type
class Item:
    """A simple item with a name and description."""

    id: ID
    identifier: str
    name: str
    description: str | None
    created_at: str


@fraiseql.query(
    sql_source="v_item",
    auto_params={"limit": True, "offset": True, "where": True, "order_by": True},
)
def items(limit: int = 10, offset: int = 0) -> list[Item]:
    """Get all items with pagination, filtering, and ordering."""
    pass


@fraiseql.query(sql_source="v_item")
def item(id: ID) -> Item | None:
    """Get a single item by ID."""
    pass


@fraiseql.mutation(sql_source="fn_create_item", operation="CREATE")
def create_item(name: str, description: str | None = None) -> Item:
    """Create a new item."""
    pass


if __name__ == "__main__":
    fraiseql.export_schema("schema.json")
    print("schema.json generated — run: fraiseql compile && fraiseql run")
