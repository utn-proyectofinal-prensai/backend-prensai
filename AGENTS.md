# Repository Guidelines

## Project Structure & Module Organization
- Core Rails API code stays in `app/` (controllers, models, policies, serializers); share cross-cutting helpers through `lib/` instead of migrations.
- Tests live in `spec/`, with factories under `spec/factories` and shared helpers in `spec/support`; API references sit in `docs/` and `apiary.apib`.
- Configuration, scripts, and container scaffolding reside in `config/`, `bin/`, and `docker-compose*.yml`; keep compiled assets in `public/` and ESBuild outputs managed via yarn.

## Build, Test, and Development Commands
- `bin/dev` runs the Rails server alongside the ActiveAdmin asset watcher—use it for local development.
- `bin/rails db:prepare` (or `db:setup` on a fresh clone) aligns schema changes and seeds after pulling new migrations.
- `bin/rspec` executes the full suite; add `HEADLESS=true` for browserless system specs or target directories (`bin/rspec spec/requests`).
- `bundle exec rails code:analysis` runs RuboCop, Reek, Rails Best Practices, and Brakeman; treat a clean report as a pre-PR requirement.

## Coding Style & Naming Conventions
- Follow Ruby 3.4 norms: two-space indentation, `snake_case` methods, `CamelCase` classes, and `SCREAMING_SNAKE_CASE` constants.
- Keep controllers thin; move workflows into `app/services` and presenter logic into `app/serializers` or `app/decorators` for reuse.
- Lint with `bundle exec rubocop` and `bundle exec reek`; prefer updating config files over inline disable comments.

## Testing Guidelines
- Mirror the app structure when adding specs (`app/models/user.rb` → `spec/models/user_spec.rb`).
- Build data with FactoryBot and reuse helpers from `spec/support`; prioritize request specs for new endpoints.
- SimpleCov tracks coverage—avoid regressions and note any intentional gaps in the pull request.

## Commit & Pull Request Guidelines
- Use the conventional prefixes found in history (`feat:`, `fix:`, `docs:`, `test:`) with imperative summaries ≤72 characters.
- Keep commits focused; include migrations with their schema updates and adjust docs or seeds in the same change set.
- Pull requests should explain the change, link work items, list verification steps (`bin/rspec`, manual flows), and add API samples or admin screenshots when relevant.

## Security & Configuration Tips
- Store secrets in `.env` locally and `config/credentials` for shared settings; never commit raw keys.
- Revisit `config/initializers/rack_cors.rb`, feature flags, and GoodJob/New Relic configs when exposing new endpoints, background jobs, or telemetry.
