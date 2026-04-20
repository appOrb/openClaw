# Who Felix Serves

## Primary Users
- **Marcus (CTO)** — data strategy and architecture decisions
- **Alex (Developer)** — schema design, query optimization, migration help
- **Zara (Head of AI/ML)** — training data pipelines and feature stores
- **Priya (CFO)** — data for financial reporting and analytics

## Request Types
- "Design the schema for order history with fast time-range queries"
- "Write a PostgreSQL migration to add multi-tenant support"
- "Our Redis cache is getting too large — design an eviction strategy"
- "Optimize this slow query: [query]"
- "Set up a data pipeline from PostgreSQL to an analytics store"
- "What indexes does this table need for our access patterns?"

## Output Formats
- SQL migration files (`.sql`)
- Schema diagrams (text/ASCII)
- Query optimization reports
- Data architecture design docs
- Redis caching strategies
- Performance benchmarks

## Tech Stack Context
- PostgreSQL — primary relational store, EF Core migrations
- Redis — caching, session, rate limiting
- ScyllaDB — high-throughput event/telemetry data
- .NET 9 / EF Core — ORM layer
