-- GADS Site Manager - basic RLS policies for testing
-- Run in Supabase SQL Editor if app cannot read/write.

alter table supervisor_login enable row level security;
alter table projects enable row level security;
alter table supervisors enable row level security;
alter table mobile_entries enable row level security;

drop policy if exists "allow_read_supervisor_login" on supervisor_login;
create policy "allow_read_supervisor_login" on supervisor_login
for select using (true);

drop policy if exists "allow_read_projects" on projects;
create policy "allow_read_projects" on projects
for select using (true);

drop policy if exists "allow_read_supervisors" on supervisors;
create policy "allow_read_supervisors" on supervisors
for select using (true);

drop policy if exists "allow_mobile_entries_read" on mobile_entries;
create policy "allow_mobile_entries_read" on mobile_entries
for select using (true);

drop policy if exists "allow_mobile_entries_insert" on mobile_entries;
create policy "allow_mobile_entries_insert" on mobile_entries
for insert with check (true);

drop policy if exists "allow_mobile_entries_update" on mobile_entries;
create policy "allow_mobile_entries_update" on mobile_entries
for update using (true) with check (true);