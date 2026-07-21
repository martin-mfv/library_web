# Library Web

Mini Dropbox-style application built with Ruby on Rails.

## Documentation Index

Use this README as an entry point. Detailed documentation is split into dedicated files under `docs/`.

### Getting Started

- Setup Guide: [docs/setup.md](docs/setup.md)

### Architecture

- System Design: [docs/architecture/system_design.md](docs/architecture/system_design.md)
- ERD: [docs/architecture/erd.md](docs/architecture/erd.md)

### Product and UI Context

- Implementation Roadmap: [docs/contexts/library-implementation-roadmap.md](docs/contexts/library-implementation-roadmap.md)
- Design Tokens (Dropbox-style): [docs/contexts/dropbox-design-tokens.md](docs/contexts/dropbox-design-tokens.md)

### Engineering Process

- Domain Documentation Workflow: [docs/agents/domain.md](docs/agents/domain.md)
- Issue Tracker Workflow: [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md)

## Quick Project Snapshot

- Backend: Ruby 3.4, Rails 7.2
- Database: PostgreSQL
- Frontend: ERB + Tailwind + Hotwire (React island for upload dropzone)
- Auth: Devise
- File Storage: ActiveStorage (Disk)
- Async: Redis + Sidekiq (roadmap phase dependent)

## Development Principle

Keep this file concise. Add or update detailed content in `docs/*.md`, then link it from the index above.
