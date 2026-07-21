# Setup Guide

This guide helps you run the project locally with Docker and create a login user.

## 1) Prerequisites

- Docker Desktop (Docker Engine + Docker Compose)
- Git

## 2) Clone repository

```bash
git clone git@github.com:martin-mfv/library_web.git
cd library_web
```

## 3) Start services

```bash
docker compose up -d --build
```

Keep this terminal running. Open a new terminal for the next steps.

## 4) Prepare database

```bash
docker compose exec web bin/rails db:prepare
```

## 5) Seed base data (optional but recommended)

```bash
docker compose exec web bin/rails db:seed
```

## 6) Create login user (required)

This project does not provide a registration UI, so you must create a user via rake task.

```bash
docker compose exec web bin/rake 'users:add[owner@example.com,Secret123!,Owner Name]'
```

Expected output:

```text
User ready: owner@example.com (id=...)
```

## 7) Build CSS

```bash
docker compose exec web bin/rails tailwindcss:build
```

## 8) Access application

- App: http://localhost:3000
- Login with the email/password you created in step 6.
