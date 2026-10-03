-- Current vs former client: optional manual override.
-- NULL means "automatic" (the app derives it from engagements:
-- current while any engagement is open or the latest engagement year is this year or last year).
alter table public.clients
  add column if not exists relationship_status text
  check (relationship_status in ('current', 'former'));

comment on column public.clients.relationship_status is
  'Manual override for current/former client status. NULL = derived from engagements in the app.';
