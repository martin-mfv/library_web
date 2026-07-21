# System Design

## Overview

Library Web is a mini cloud-drive style application built with Ruby on Rails. The current architecture follows a modular monolith approach:

- Presentation: Rails views (ERB) + Tailwind + Hotwire
- Application: Controllers + form objects
- Domain: Models and service objects
- Data: PostgreSQL
- File Storage: ActiveStorage (Disk service)
- Background Jobs: Sidekiq (planned/partial by phase)

## High-Level Components

1. Authentication
- Devise-based authentication
- No self-registration flow in UI

2. File Library
- Upload, list, search, and manage files
- Visibility/authorization handled centrally in model scope

3. Upload Pipeline
- Direct upload through ActiveStorage
- Metadata derived from blob attributes

4. Async Processing
- Redis + Sidekiq for bulk/background operations (roadmap phase dependent)

## Runtime Flow (Simplified)

1. User signs in.
2. User uploads a file.
3. ActiveStorage persists blob and attachment.
4. Library file record references uploaded blob.
5. User can browse/search files from the library interface.

## Design Decisions

- Keep controllers thin; move business logic into models/services.
- Keep authorization centralized to reduce policy drift.
- Avoid duplicating blob-owned metadata in custom columns.

## Future Enhancements

- Move storage from local disk to cloud object storage.
- Add richer audit trails and activity feeds.
- Add robust background workflows for batch actions.
