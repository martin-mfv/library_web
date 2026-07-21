# Setup Guide

## 1) Prerequisites

- Docker Desktop
- Docker Compose
- Git

## 2) Clone and enter project

```bash
git clone git@github.com:martin-mfv/library_web.git
cd library_web
```

## 3) Boot application with Docker

```bash
docker compose up --build
```

## 4) Setup database

In a new terminal:

```bash
docker compose exec web bin/rails db:prepare
```

## 5) Seed default data

```bash
docker compose exec web bin/rails db:seed
```

## 6) Access application

- App: http://localhost:3000

## 7) Useful commands

```bash
# Run test suite
docker compose exec web bundle exec rspec

# Run RuboCop
docker compose exec web bundle exec rubocop

# Rails console
docker compose exec web bin/rails c
```

## Notes

- For local non-Docker setup, use the Ruby and PostgreSQL versions declared in project files.
- If credentials are required, ensure `RAILS_MASTER_KEY` is correctly configured.
