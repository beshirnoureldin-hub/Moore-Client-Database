# Moore-Client-Database
Client Database

## Client logos setup

Client logos are stored in a private Supabase Storage bucket, `client-logos`, the same way signed engagement letters use `engagement-letters`. Before using the feature, run [`supabase/client-logos.sql`](supabase/client-logos.sql) once in the Supabase SQL editor. It adds `logo_file` and `logo_file_name` to `clients`, creates the bucket (images only, 5 MB max) and adds storage policies: active users can view logos, and the roles that can edit clients can upload or remove them.
