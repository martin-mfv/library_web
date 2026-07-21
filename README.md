# Library Web

Mini library application built with Ruby on Rails.

## Documentation Index

Use this README as an entry point. Detailed documentation is split into dedicated files under `docs/`.

### Getting Started

- Setup Guide: [docs/setup.md](docs/setup.md)

### Default Accounts

After running `rails db:seed`, you can sign in with either of these accounts:

| Email                 | Password       |
| --------------------- | -------------- |
| `demo@library.local`  | `Password123!` |
| `owner@library.local` | `Password123!` |

### Architecture

- System Design: [docs/architecture/System_design.png](docs/architecture/System_design.png)
- ERD: [docs/architecture/erd.md](docs/architecture/erd.md)

## Quick Project Snapshot

- Backend: Ruby 3.4, Rails 7.2
- Database: PostgreSQL
- Frontend: Slim + Tailwind + Hotwire
- Auth: Devise
- File Storage: ActiveStorage (Disk)



