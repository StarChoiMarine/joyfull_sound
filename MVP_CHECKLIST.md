# 1차 MVP 체크리스트

## P0 — 기반

- [x] 제품 목표, 개인정보 원칙, 범위를 `PROJECT_BRIEF.md`에 기록
- [x] 기존 `index.html` 프로토타입 백업 및 사용자 변경 보존
- [x] React + TypeScript + Vite 앱 전환
- [x] Pretendard Variable과 공통 디자인 토큰 적용
- [x] 모바일 앱 shell, safe area, 하단 고정 내비게이션
- [x] PWA manifest와 설치 메타데이터 (아이콘은 후속 디자인 확정 시 추가)
- [x] `.env.example` 및 개발/운영 모드 구분

## P1 — 핵심 기능

- [x] 로그인·초대 화면과 교체 가능한 auth abstraction (운영 adapter 후속)
- [x] DEV DEMO 모드와 현실적인 14명 샘플 데이터
- [x] 내 기도제목 추가·완료 처리 (수정 UI 후속)
- [x] 관리자 시즌과 배정 미리보기/검증 (운영 확정 adapter 후속)
- [x] 배정 알고리즘의 본인 배정·중복·누락 방지
- [x] 멤버에게 본인의 현재 기도 대상만 표시
- [x] 대상자의 최신 활성 기도제목 표시
- [x] 기도 화면과 `기기완!` 처리
- [x] 날짜별 익명 밤하늘, 반복 기도 밝기 3단계
- [x] 전원 기도 시 공동체 축하 상태
- [x] profiles, prayer_topics, assignment_cycles, assignments, prayer_checkins, letters migration
- [x] RLS, 안전한 밤하늘 RPC, 초대 결합 지점 문서화

## P2 — MVP 후순위

- [ ] 대상자에게 익명 편지 보내기
- [ ] 내 기니또에게 익명 답장 보내기
- [ ] 받은 편지함과 읽음 상태
- [ ] 배포 준비 및 실제 모바일 QA

## 품질 게이트

- [x] 사용자 입력을 `innerHTML`로 삽입하지 않음
- [x] 로딩·빈 상태·오류·권한 없음 상태 (핵심 화면 기준)
- [x] 키보드 접근성, 의미 있는 label, 44px 터치 영역
- [x] 작은 화면과 iPhone safe area 확인
- [x] 배정 알고리즘 불변조건 테스트
- [x] 기도 별 집계 및 안정적 위치 테스트
- [ ] 권한/서비스 경계 테스트
- [x] lint, test, production build 통과
- [x] 실제 동작 범위와 Supabase/Kakao 설정 대기 범위 문서화

## 운영 전 필수 확인

- [ ] Supabase 프로젝트 및 Kakao Developers 앱 생성
- [ ] 환경 변수는 호스팅 설정에만 저장
- [ ] 14명 멤버·관리자 명단 확정
- [ ] 초대 토큰 수명과 재발급 정책 확정
- [ ] 관리자 기도제목 접근 범위 최종 확정
- [ ] 편지 익명성 및 신고/삭제 정책 최종 확정
- [ ] RLS 권한 테스트 후 실제 기도제목 입력 승인
