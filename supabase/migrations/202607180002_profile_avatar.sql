alter table public.profiles add column if not exists avatar_url text;

-- 멤버가 role이나 초대 정보는 건드리지 않고 자신의 사진 URL만 변경하도록 제한한다.
create or replace function public.update_my_avatar(p_avatar_url text)
returns void language plpgsql security definer set search_path=public as $$
begin
  if public.my_profile_id() is null then raise exception 'not a bound member'; end if;
  if p_avatar_url is not null and char_length(p_avatar_url) > 500 then raise exception 'avatar url too long'; end if;
  update public.profiles set avatar_url=nullif(trim(p_avatar_url),''),updated_at=now() where id=public.my_profile_id();
end;
$$;
revoke all on function public.update_my_avatar(text) from public;
grant execute on function public.update_my_avatar(text) to authenticated;
