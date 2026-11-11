-- Ota-ona roziligi. Eski qatorlarda rozilik yo‘q (false, vaqt null).

alter table public.profiles
  add column if not exists parent_consent_granted boolean not null default false;

alter table public.profiles
  add column if not exists parent_consent_at timestamptz;

grant insert (parent_consent_granted, parent_consent_at)
  on table public.profiles to authenticated;

grant update (parent_consent_granted, parent_consent_at)
  on table public.profiles to authenticated;

grant delete on table public.profiles to authenticated;

drop policy if exists profiles_delete_own on public.profiles;
create policy profiles_delete_own on public.profiles
  for delete to authenticated
  using (id = auth.uid());
