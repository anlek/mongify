# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mongify is a Ruby gem that translates data from SQL databases (MySQL, PostgreSQL, SQLite, Oracle, SQLServer, DB2) to MongoDB. It uses a DSL-based translation file to define how tables map to MongoDB collections, including support for embedding documents and handling polymorphic relationships.

## Common Commands

```bash
# Install dependencies
bundle install

# Run all tests (RSpec + Cucumber)
rake test

# Run only RSpec tests
rake test:rspec

# Run only Cucumber features
rake test:cucumber

# Run a single spec file
bundle exec rspec spec/mongify/database/table_spec.rb

# Run a single Cucumber feature
bundle exec cucumber features/process.feature

# Setup test databases (requires database.yml configuration)
rake test:setup:mysql
rake test:setup:postgresql

# Build the gem
rake build
```

## Test Database Setup

### Using Docker (Recommended)

```bash
# Start all databases (MongoDB, MySQL, PostgreSQL)
bin/dev-db up

# Setup test database schema
bin/test-setup

# Run tests
bundle exec rspec

# Stop databases
bin/dev-db down
```

### Manual Setup

Copy `spec/support/database.example` to `spec/support/database.yml` and configure your MySQL/PostgreSQL/MongoDB connection settings.

## Architecture

### Core Processing Pipeline

1. **Configuration** (`lib/mongify/configuration.rb`) - Parses database connection config files defining `sql_connection` and `mongodb_connection` blocks
2. **Translation** (`lib/mongify/translation.rb`) - Parses translation files that define table/column mappings using the DSL
3. **Process/Sync** (`lib/mongify/translation/process.rb`, `sync.rb`) - Executes the translation:
   - `copy_data` - Copies non-embedded tables
   - `update_reference_ids` - Updates foreign key references to MongoDB ObjectIDs
   - `copy_embedded_tables` - Embeds documents into parent collections
   - `copy_polymorphic_tables` - Handles polymorphic relationships

### Key Domain Objects

- **`Database::Table`** (`lib/mongify/database/table.rb`) - Represents a SQL table with options for embedding (`:embed_in`, `:as`, `:on`), renaming (`:rename_to`), polymorphism (`:polymorphic`), and `before_save` callbacks
- **`Database::Column`** (`lib/mongify/database/column.rb`) - Represents a column with type casting, reference tracking (`:references`), and rename support
- **`Database::DataRow`** (`lib/mongify/database/data_row.rb`) - Hash wrapper used in `before_save` callbacks for row manipulation

### CLI Structure

Entry point: `bin/mongify` → `CLI::Application` → `CLI::Options` → `CLI::Command::Worker`

Commands: `check`, `translation`, `process`, `sync`

### Translation DSL

The DSL uses `instance_eval` to parse translation files. Tables can be:
- **Copy tables** - Straight copy to MongoDB collection
- **Embedded tables** - Embedded as array or object within parent document
- **Polymorphic tables** - Embedded based on `*_type` column value

## Important Rules

- **NEVER remove or delete `Gemfile.lock`** - Always use `bundle update <gem>` to update specific gems instead of regenerating the entire lockfile.

## Dependencies

- ActiveRecord 6.0.x for SQL database connectivity
- mongo/bson 1.12.5 for MongoDB connectivity
- RSpec 2.x for unit tests
- Cucumber for integration tests
