# AGENTS.md

## Project overview

PinFlags is a Rails engine (isolated namespace `PinFlags::`) for entity-based feature flags. It uses polymorphic associations to "pin" feature tags to any ActiveRecord model. The gem targets Rails 8+ and Ruby 3.0+.

## Setup

```bash
bundle install
```

The test suite uses a dummy Rails app at `test/dummy/` with SQLite.

## Common commands

```bash
bundle exec rails test              # Run all tests
bundle exec rails test test/models  # Run model tests only
bundle exec rubocop                 # Lint (rubocop-rails-omakase style)
```

## Architecture

This is a Rails engine, not a standalone app. Key directories:

- `app/models/pin_flags/` — Core models: `FeatureTag`, `FeatureSubscription`, `Page`
- `app/models/pin_flags/feature_tag/cacheable.rb` — Caching concern
- `app/models/pin_flags/feature_subscription/bulk_processor.rb` — Bulk operations service
- `app/models/concerns/pin_flags/feature_taggable.rb` — Mixin for host app models
- `app/controllers/pin_flags/` — Namespaced controllers with nested resources
- `app/controllers/concerns/pin_flags/basic_authentication.rb` — HTTP Basic Auth
- `app/views/pin_flags/` — ERB views with Turbo Stream templates
- `app/assets/` — Vendored Bulma CSS and Alpine.js (no Stimulus)
- `lib/pin_flags.rb` — Main module with configuration DSL
- `lib/pin_flags/engine.rb` — Engine definition
- `lib/generators/pin_flags/install/` — Installation generator
- `config/routes.rb` — Engine routes
- `db/migrate/` — Migration templates for `pin_flags_feature_tags` and `pin_flags_feature_subscriptions`

## Code conventions

- **Namespace**: All classes under `PinFlags::`. Table names prefixed `pin_flags_`.
- **Style**: Rubocop with `rubocop-rails-omakase`. Target Ruby 3.4.
- **Tag name normalization**: `strip.downcase.parameterize.underscore` via Rails `normalizes` callback.
- **Caching**: Configurable prefix and expiry via `PinFlags.config`. Cache cleared on tag updates.
- **Bulk operations**: Use `upsert_all` via `BulkProcessor` service object.
- **Views**: Turbo Stream for dynamic updates. Alpine.js for client-side interactivity. No Stimulus.
- **Controllers**: Inherit from `PinFlags::ApplicationController`. Nested resources use module organization.

## Testing

- Framework: Minitest (Rails default)
- Fixtures in `test/fixtures/`
- Prefer testing against a real Rails app over the dummy app when possible
- Test files mirror the app structure: `test/models/pin_flags/`, `test/helpers/pin_flags/`, `test/controllers/`
- Always run `bundle exec rails test` before submitting changes

## Dependencies

- `rails` ~> 8.0 (>= 8.0.2)
- `turbo-rails` ~> 2.0
- `propshaft` (asset pipeline, dev dependency)
- Frontend assets are vendored (no npm/yarn)

## PR guidelines

- Run `bundle exec rubocop` and `bundle exec rails test` before committing
- Add tests for new features
- Follow existing code style and namespace conventions
- Keep commit messages clear and descriptive
