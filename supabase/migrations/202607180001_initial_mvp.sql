-- 기쁜소리 1차 MVP. 실제 데이터 입력 전 staging 프로젝트에서 RLS 권한 테스트 필수.
create extension if not exists pgcrypto;
create type public.member_role as enum ('admin','member');
create type public.cycle_status as enum ('draft','active','closed');

create table public.profiles (
  id uuid primary key default gen_random_uuid(), auth_user_id uuid unique references auth.users(id) on delete set null,
  display_name text not null check (char_length(display_name) between 1 and 30), role public.member_role not null default 'member',
  invite_token_hash text unique, invite_expires_at timestamptz, invited_at timestamptz not null default now(), joined_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.prayer_topics (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 500), is_completed boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), completed_at timestamptz
);
create table public.assignment_cycles (
  id uuid primary key default gen_random_uuid(), name text not null, starts_on date not null, ends_on date not null check (ends_on>=starts_on),
  status public.cycle_status not null default 'draft', created_by uuid not null references public.profiles(id), confirmed_at timestamptz,
  created_at timestamptz not null default now(), exclude_prior_cycle boolean not null default true
);
create unique index one_active_assignment_cycle on public.assignment_cycles(status) where status='active';
create table public.assignments (
  cycle_id uuid not null references public.assignment_cycles(id) on delete cascade, giver_id uuid not null references public.profiles(id) on delete cascade,
  target_id uuid not null references public.profiles(id) on delete cascade, created_at timestamptz not null default now(),
  primary key(cycle_id,giver_id), unique(cycle_id,target_id), check(giver_id<>target_id)
);
create table public.prayer_checkins (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references public.profiles(id) on delete cascade,
  prayer_date date not null default (timezone('Asia/Seoul',now()))::date, prayer_count smallint not null default 1 check(prayer_count between 1 and 3),
  first_prayed_at timestamptz not null default now(), last_prayed_at timestamptz not null default now(), public_id uuid not null default gen_random_uuid(),
  unique(member_id,prayer_date), unique(public_id)
);
create table public.letters (
  id uuid primary key default gen_random_uuid(), cycle_id uuid not null references public.assignment_cycles(id), sender_id uuid not null references public.profiles(id),
  receiver_id uuid not null references public.profiles(id), message text not null check(char_length(message) between 1 and 1000),
  created_at timestamptz not null default now(), read_at timestamptz, check(sender_id<>receiver_id)
);

create or replace function public.my_profile_id() returns uuid language sql stable security definer set search_path=public as $$select id from profiles where auth_user_id=auth.uid()$$;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$select coalesce((select role='admin' from profiles where auth_user_id=auth.uid()),false)$$;
revoke all on function public.my_profile_id() from public; grant execute on function public.my_profile_id() to authenticated;
revoke all on function public.is_admin() from public; grant execute on function public.is_admin() to authenticated;

alter table public.profiles enable row level security; alter table public.prayer_topics enable row level security;
alter table public.assignment_cycles enable row level security; alter table public.assignments enable row level security;
alter table public.prayer_checkins enable row level security; alter table public.letters enable row level security;

create policy profiles_read_self_or_admin on public.profiles for select to authenticated using(id=public.my_profile_id() or public.is_admin());
create policy profiles_admin_write on public.profiles for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy topics_read_owner_target on public.prayer_topics for select to authenticated using(
 owner_id=public.my_profile_id() or exists(select 1 from public.assignments a join public.assignment_cycles c on c.id=a.cycle_id where c.status='active' and a.giver_id=public.my_profile_id() and a.target_id=owner_id)
);
create policy topics_owner_insert on public.prayer_topics for insert to authenticated with check(owner_id=public.my_profile_id());
create policy topics_owner_update on public.prayer_topics for update to authenticated using(owner_id=public.my_profile_id()) with check(owner_id=public.my_profile_id());
create policy topics_owner_delete on public.prayer_topics for delete to authenticated using(owner_id=public.my_profile_id());
create policy cycles_member_read_active on public.assignment_cycles for select to authenticated using(status='active' or public.is_admin());
create policy cycles_admin_write on public.assignment_cycles for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy assignments_read_own on public.assignments for select to authenticated using(giver_id=public.my_profile_id() or public.is_admin());
create policy assignments_admin_write on public.assignments for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy checkins_insert_self on public.prayer_checkins for insert to authenticated with check(member_id=public.my_profile_id());
create policy checkins_update_self on public.prayer_checkins for update to authenticated using(member_id=public.my_profile_id()) with check(member_id=public.my_profile_id());
create policy checkins_read_self on public.prayer_checkins for select to authenticated using(member_id=public.my_profile_id());
create policy letters_read_receiver on public.letters for select to authenticated using(receiver_id=public.my_profile_id());
create policy letters_update_receiver on public.letters for update to authenticated using(receiver_id=public.my_profile_id()) with check(receiver_id=public.my_profile_id());
create policy letters_send_valid_assignment on public.letters for insert to authenticated with check(sender_id=public.my_profile_id() and exists(
 select 1 from public.assignments a join public.assignment_cycles c on c.id=a.cycle_id where c.status='active' and a.cycle_id=cycle_id and ((a.giver_id=sender_id and a.target_id=receiver_id) or (a.giver_id=receiver_id and a.target_id=sender_id))
));

-- 이름이나 내부 사용자 식별자를 반환하지 않는 공개 밤하늘 RPC.
create or replace function public.get_prayer_sky(p_date date default (timezone('Asia/Seoul',now()))::date)
returns table(public_id uuid, prayer_time timestamptz, brightness smallint, prayed_members integer, community_size integer, all_prayed boolean)
language sql stable security definer set search_path=public as $$
 with stats as (select count(*)::integer community_size from profiles where auth_user_id is not null), daily as (
   select public_id,last_prayed_at,prayer_count,count(*) over()::integer prayed_members from prayer_checkins where prayer_date=p_date
 ) select d.public_id,d.last_prayed_at,d.prayer_count,d.prayed_members,s.community_size,(d.prayed_members=s.community_size and s.community_size>0) from daily d cross join stats s;
$$;
revoke all on function public.get_prayer_sky(date) from public; grant execute on function public.get_prayer_sky(date) to authenticated;

-- 원자적으로 같은 날 별 한 개의 밝기만 최대 3단계로 높인다.
create or replace function public.complete_prayer()
returns void language plpgsql security definer set search_path=public as $$ declare v_id uuid:=public.my_profile_id(); v_date date:=(timezone('Asia/Seoul',now()))::date;
begin if v_id is null then raise exception 'not a bound member'; end if;
 insert into prayer_checkins(member_id,prayer_date) values(v_id,v_date)
 on conflict(member_id,prayer_date) do update set prayer_count=least(prayer_checkins.prayer_count+1,3),last_prayed_at=now(); end; $$;
revoke all on function public.complete_prayer() from public; grant execute on function public.complete_prayer() to authenticated;

-- 초대 토큰 원문은 저장하지 않는다. Edge Function이 service role로 hash 비교 후 auth.uid()를 한 번만 결합한다.
comment on column public.profiles.invite_token_hash is 'SHA-256 hash only; bind through trusted server/Edge Function, never from browser SQL';
