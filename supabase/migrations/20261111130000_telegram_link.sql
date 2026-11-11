-- Telegram ulash: chat_id ni faqat server yozadi. Kod bir martalik.

alter table public.profiles
  add column if not exists telegram_chat_id text;

alter table public.profiles
  drop constraint if exists profiles_telegram_chat_check;

alter table public.profiles
  add constraint profiles_telegram_chat_check
  check (
    telegram_chat_id is null
    or telegram_chat_id ~ '^-?[0-9]{1,20}$'
  );

create table if not exists public.telegram_link_codes (
  code text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  expires_at timestamptz not null,
  used_at timestamptz,
  constraint telegram_link_codes_format check (code ~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$')
);

alter table public.telegram_link_codes enable row level security;

revoke all on table public.telegram_link_codes from public, anon, authenticated;
grant select, insert, update, delete on table public.telegram_link_codes to service_role;

-- Sana va chat_id ni mijoz o‘zgartira olmaydi.
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
      new.telegram_chat_id := null;
    else
      new.trial_started_at := old.trial_started_at;
      new.subscription_expires_at := old.subscription_expires_at;
      new.telegram_chat_id := old.telegram_chat_id;
    end if;
  end if;
  return new;
end;
$$;

create or replace function public.claim_telegram_link(
  p_code text,
  p_chat_id text
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  link public.telegram_link_codes%rowtype;
  updated integer;
begin
  if p_chat_id is null or p_chat_id !~ '^-?[0-9]{1,20}$' then
    return 'invalid_chat';
  end if;
  if p_code is null or p_code !~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$' then
    return 'not_found';
  end if;

  select * into link
  from public.telegram_link_codes
  where code = p_code
  for update;

  if not found then
    return 'not_found';
  end if;
  if link.used_at is not null then
    return 'used';
  end if;
  if link.expires_at <= now() then
    return 'expired';
  end if;

  update public.profiles
  set telegram_chat_id = p_chat_id
  where id = link.user_id;
  get diagnostics updated = row_count;
  if updated = 0 then
    return 'not_found';
  end if;

  update public.telegram_link_codes
  set used_at = now()
  where code = p_code;
  return 'ok';
end;
$$;

revoke all on function public.claim_telegram_link(text, text)
  from public, anon, authenticated;
grant execute on function public.claim_telegram_link(text, text) to service_role;
