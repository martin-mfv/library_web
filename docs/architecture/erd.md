# ERD (Entity Relationship Diagram)

## Core Entities

1. users
- id
- email
- encrypted_password
- created_at
- updated_at

2. library_files
- id
- user_id
- name
- created_at
- updated_at

3. active_storage_blobs
- id
- key
- filename
- content_type
- metadata
- service_name
- byte_size
- checksum
- created_at

4. active_storage_attachments
- id
- name
- record_type
- record_id
- blob_id
- created_at

## Relationships

- User has many LibraryFile (`users.id -> library_files.user_id`)
- LibraryFile has one attached file via ActiveStorage
- ActiveStorageAttachment belongs to ActiveStorageBlob

## Mermaid ERD

```mermaid
erDiagram
    USERS ||--o{ LIBRARY_FILES : owns
    LIBRARY_FILES ||--o{ ACTIVE_STORAGE_ATTACHMENTS : attaches
    ACTIVE_STORAGE_BLOBS ||--o{ ACTIVE_STORAGE_ATTACHMENTS : referenced_by

    USERS {
        bigint id
        string email
        string encrypted_password
        datetime created_at
        datetime updated_at
    }

    LIBRARY_FILES {
        bigint id
        bigint user_id
        string name
        datetime created_at
        datetime updated_at
    }

    ACTIVE_STORAGE_BLOBS {
        bigint id
        string key
        string filename
        string content_type
        text metadata
        string service_name
        bigint byte_size
        string checksum
        datetime created_at
    }

    ACTIVE_STORAGE_ATTACHMENTS {
        bigint id
        string name
        string record_type
        bigint record_id
        bigint blob_id
        datetime created_at
    }
```

## Notes

- File size and type should be read from blob metadata, not duplicated in `library_files`.
- Actual attributes should always be validated against `db/schema.rb`.
