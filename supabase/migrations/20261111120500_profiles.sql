-- Profillar va sinov muddati. Sanalarni faqat server qo‘yadi.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  student_name text not null,
  grade smallint not null,
  target_school text not null,
  parent_phone text not null,
  trial_started_at timestamptz not null default now(),
  subscription_expires_at timestamptz not null default (now() + interval '7 days'),
  constraint profiles_grade_check check (grade in (3, 4)),
  constraint profiles_name_check check (char_length(btrim(student_name)) between 2 and 80),
  constraint profiles_phone_check check (parent_phone ~ '^\+998[0-9]{9}$')
);

alter table public.profiles enable row level security;

revoke all on table public.profiles from public, anon, authenticated;
grant select on table public.profiles to authenticated;
grant insert (id, student_name, grade, target_school, parent_phone)
  on table public.profiles to authenticated;
grant update (student_name, grade, target_school, parent_phone)
  on table public.profiles to authenticated;

create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid());

create policy profiles_insert_own on public.profiles
  for insert to authenticated
  with check (id = auth.uid());

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create or replace function public.protect_profile_trial()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  jwt_role text := coalesce(auth.role(), '');
begin
  if jwt_role is distinct from 'service_role' then
    if tg_op = 'INSERT' then
      new.trial_started_at := now();
      new.subscription_expires_at := now() + interval '7 days';
    else
      new.trial_started_at := old.trial_started_at;
      new.subscription_expires_at := old.subscription_expires_at;
    end if;
  end if;
  return new;
end;
$$;

create trigger profiles_protect_trial
  before insert or update on public.profiles
  for each row execute function public.protect_profile_trial();

create or replace function public.my_subscription()
returns table (
  trial_started_at timestamptz,
  subscription_expires_at timestamptz,
  server_now timestamptz,
  has_access boolean
)
language sql
stable
security invoker
set search_path = public
as $$
  select
    p.trial_started_at,
    p.subscription_expires_at,
    now(),
    p.subscription_expires_at > now()
  from public.profiles p
  where p.id = auth.uid();
$$;

revoke all on function public.my_subscription() from public, anon;
grant execute on function public.my_subscription() to authenticated;

create or replace function public.set_subscription_expiry(
  p_user_id uuid,
  p_expires timestamptz
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set subscription_expires_at = p_expires
  where id = p_user_id;
end;
$$;

revoke all on function public.set_subscription_expiry(uuid, timestamptz)
  from public, anon, authenticated;
grant execute on function public.set_subscription_expiry(uuid, timestamptz)
  to service_role;
