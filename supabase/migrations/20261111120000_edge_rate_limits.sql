-- Edge Function tezlik chegarasi. Klientlar jadvalni o‘qiy olmaydi.
-- Yozish faqat service_role orqali bump_edge_rate_limit funksiyasida.

create table if not exists public.edge_rate_limits (
  user_id uuid not null,
  fn text not null,
  window_start timestamptz not null,
  count integer not null default 0,
  primary key (user_id, fn, window_start)
);

alter table public.edge_rate_limits enable row level security;

revoke all on table public.edge_rate_limits from public, anon, authenticated;
grant select, insert, update, delete on table public.edge_rate_limits to service_role;

create or replace function public.bump_edge_rate_limit(
  p_user_id uuid,
  p_fn text,
  p_window timestamptz,
  p_limit integer
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  new_count integer;
begin
  if p_user_id is null or p_fn is null or p_window is null or p_limit < 1
     or char_length(p_fn) > 64 then
    return -1;
  end if;

  insert into public.edge_rate_limits as t (user_id, fn, window_start, count)
  values (p_user_id, p_fn, p_window, 1)
  on conflict (user_id, fn, window_start)
  do update set count = t.count + 1
  returning count into new_count;

  if new_count > p_limit then
    return -1;
  end if;
  return new_count;
end;
$$;

revoke all on function public.bump_edge_rate_limit(uuid, text, timestamptz, integer)
  from public, anon, authenticated;
grant execute on function public.bump_edge_rate_limit(uuid, text, timestamptz, integer)
  to service_role;
