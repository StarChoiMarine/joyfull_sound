# Supabase 및 Kakao 연결 준비

현재 앱은 `VITE_APP_MODE=dev`에서만 샘플 데이터로 동작한다. 이 모드는 UI 검증용이며 실제 기도제목을 입력하면 안 된다.

1. 별도의 Supabase staging 프로젝트를 만든다.
2. `supabase/migrations/202607180001_initial_mvp.sql`을 Supabase CLI migration으로 적용한다.
3. Auth Providers에서 Kakao를 설정하고 Kakao Developers의 Redirect URI를 Supabase callback으로 등록한다.
4. 관리자 전용 Edge Function에서 멤버 프로필과 무작위 초대 토큰을 만든다. DB에는 토큰의 SHA-256 hash만 저장한다.
5. 최초 OAuth callback 뒤 Edge Function이 로그인 사용자와 유효한 미사용 초대를 결합한다. 브라우저가 `profiles.auth_user_id`를 직접 수정하면 안 된다.
6. `.env.example`을 참고해 로컬 `.env.local` 또는 호스팅 환경 변수에 URL과 anon key를 설정한다. service role key는 절대 브라우저 환경 변수에 넣지 않는다.
7. member/admin별 RLS 테스트를 통과하기 전에는 실제 기도제목을 입력하지 않는다.

운영 연결 UI와 Edge Function은 Supabase/Kakao 프로젝트가 준비된 다음 단계에서 완성한다. 비밀키는 채팅이나 Git에 공유하지 않는다.
