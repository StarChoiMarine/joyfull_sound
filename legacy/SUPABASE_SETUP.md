# Supabase 설정 가이드

아래 SQL을 Supabase SQL Editor에서 실행하세요.

```sql
create table if not exists profiles (
  id bigint generated always as identity primary key,
  name text unique not null,
  password text not null,
  role text not null check (role in ('admin','member')),
  prayer_topic text,
  target_id bigint references profiles(id) on delete set null
);

create table if not exists letters (
  id bigint generated always as identity primary key,
  sender_name text not null,
  receiver_id bigint not null references profiles(id) on delete cascade,
  message text not null,
  anonymous boolean not null default false,
  created_at timestamptz not null default now()
);

insert into profiles(name,password,role)
values ('admin','admin1234','admin')
on conflict (name) do nothing;
```

RLS를 쓰려면 별도 정책 설계가 필요합니다. 현재 예시는 빠른 시작용입니다.
