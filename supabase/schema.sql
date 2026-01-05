-- Enable required extensions
create extension if not exists "pgcrypto";
create extension if not exists "vector";

-- Enums
create type document_type as enum (
  'bill',
  'court_case',
  'exec_order'
);

-- Core documents table
create table documents (
  id uuid primary key default gen_random_uuid(),

  doc_type document_type not null,
  title text not null,

  summary_ai text,
  summary_human text,

  full_text text not null,
  source_url text not null,

  jurisdiction text not null,

  published_at timestamp with time zone,
  created_at timestamp with time zone default now(),

  search_vector tsvector,

  ai_model text,
  ai_generated_at timestamp with time zone
);

-- Metadata table
create table document_metadata (
  id uuid primary key default gen_random_uuid(),

  document_id uuid not null
    references documents(id) on delete cascade,

  key text not null,
  value text not null
);

-- Full-text search trigger
create function documents_search_vector_update() returns trigger as $$
begin
  new.search_vector :=
    to_tsvector(
      'english',
      coalesce(new.title, '') || ' ' ||
      coalesce(new.summary_ai, '') || ' ' ||
      coalesce(new.full_text, '')
    );
  return new;
end;
$$ language plpgsql;

create trigger documents_search_vector_trigger
before insert or update on documents
for each row execute function documents_search_vector_update();

-- Indexes
create index documents_search_idx
  on documents using gin (search_vector);

create index documents_published_at_idx
  on documents (published_at desc);

create index documents_doc_type_idx
  on documents (doc_type);

create index documents_jurisdiction_idx
  on documents (jurisdiction);

-- Embeddings table (future use)
create table document_embeddings (
  document_id uuid primary key
    references documents(id) on delete cascade,

  embedding vector(1536)
);

-- Row Level Security
alter table documents enable row level security;

create policy "Public read access"
  on documents
  for select
  using (true);
