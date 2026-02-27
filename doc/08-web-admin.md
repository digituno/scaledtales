# 웹 어드민 패널

## 개요

ScaledTales 웹 어드민 패널은 **관리자 전용** 백오피스 도구입니다.
Flutter 모바일 앱과 별개로 운영되며, 종 분류 데이터 관리 및 사용자 권한 제어를 담당합니다.

**URL**: `http://localhost:3001` (개발) / 별도 도메인 (프로덕션)
**접근 권한**: `user_profile.role = 'admin'` 계정만 로그인 가능
**위치**: 모노레포 `web/` 디렉토리

---

## 기술 스택

| 항목 | 기술 | 버전 |
|------|------|------|
| 프레임워크 | Nuxt 3 (SSR 비활성, SPA 모드) | 3.x |
| UI 언어 | Vue 3 + TypeScript | - |
| 컴포넌트 라이브러리 | Nuxt UI v2 (Tailwind CSS 기반) | 2.x |
| 상태 관리 | Pinia | 2.x |
| HTTP 클라이언트 | `$fetch` (Nuxt 내장, `ofetch` 기반) | - |
| 인증 | Supabase Auth (이메일/패스워드) | - |
| 포트 | 3001 | - |

---

## 디렉토리 구조

```
web/
├── .nuxt/                        # 자동 생성 (gitignore)
├── .output/                      # 빌드 결과 (gitignore)
├── components/
│   ├── dashboard/
│   │   └── StatsCard.vue         # 대시보드 통계 카드 컴포넌트
│   ├── species/
│   │   ├── SpeciesFormModal.vue  # 종 생성/수정 모달
│   │   └── SpeciesImportModal.vue # CSV 대량 임포트 모달
│   └── taxonomy/
│       └── TaxonomyNodeModal.vue # 분류 트리 노드 생성/수정 모달
├── layouts/
│   ├── default.vue               # 사이드바 + 콘텐츠 레이아웃 (인증 후)
│   └── blank.vue                 # 빈 레이아웃 (로그인 페이지)
├── middleware/
│   └── auth.global.ts            # 전역 인증/권한 미들웨어
├── pages/
│   ├── index.vue                 # 루트 → /dashboard 리다이렉트
│   ├── login.vue                 # 로그인 페이지
│   ├── dashboard.vue             # 대시보드 (통계 현황)
│   ├── species/
│   │   └── index.vue             # 종 목록 관리
│   ├── taxonomy/
│   │   └── index.vue             # 분류 트리 관리
│   └── users/
│       └── index.vue             # 사용자 목록 및 역할 관리
├── plugins/
│   ├── supabase.client.ts        # Supabase 클라이언트 초기화
│   └── api.client.ts             # $api 헬퍼 (JWT 자동 첨부)
├── stores/
│   └── auth.ts                   # Pinia 인증 스토어
├── nuxt.config.ts                # Nuxt 설정
└── package.json
```

---

## 인증 흐름

```
사용자 이메일/패스워드 입력
        ↓
Supabase.auth.signInWithPassword()
        ↓
GET /v1/auth/me → role 조회
        ↓
role === 'admin'? → 대시보드 진입
role !== 'admin'? → "권한 없음" 오류, 로그인 페이지로
```

### 미들웨어 (`middleware/auth.global.ts`)
- 모든 라우트 진입 시 실행
- 미인증 → `/login` 리다이렉트
- 인증됐지만 admin 아님 → `/login?error=forbidden`
- `/login` 페이지는 통과 (단, 이미 관리자 로그인 상태면 `/dashboard`로)

### API 요청 JWT 첨부 (`plugins/api.client.ts`)
```typescript
// $api 사용 시 자동으로 Authorization 헤더 첨부
const headers = new Headers(options.headers)
headers.set('Authorization', `Bearer ${session.access_token}`)
options.headers = headers

// 401 응답 시 자동 로그아웃 + /login 이동
```

### 백엔드 AdminGuard
```typescript
// JwtAuthGuard + AdminGuard 이중 검증
// AdminGuard: JWT user_id로 user_profile.role = 'admin' 확인
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/...')
```

---

## 페이지별 기능

### 대시보드 (`/dashboard`)

서비스 전체 현황을 한눈에 표시합니다.

| 항목 | 내용 |
|------|------|
| 데이터 소스 | `GET /v1/admin/stats` |
| 갱신 주기 | 페이지 진입 시 1회 |

**표시 정보:**
- **통계 카드 4종**: 전체 개체 수(생존 포함), 이번 달 신규 개체, 전체 케어로그 수, 등록 종 수
- **사용자 현황**: 전체 사용자 수, 이번 달 신규 가입
- **케어로그 타입별 현황**: 7가지 타입별 건수 바 차트 (FEEDING / SHEDDING / DEFECATION / MATING / EGG_LAYING / CANDLING / HATCHING)

---

### 종 관리 (`/species`)

등록된 파충류/양서류 종 정보를 CRUD 관리합니다.

| 항목 | 내용 |
|------|------|
| 데이터 소스 | `GET /v1/admin/species` |
| 페이지네이션 | 20개/페이지 |

**기능 목록:**

#### 종 목록 조회
- 한국명 / 영명 / 학명 통합 검색 (디바운스 400ms)
- 테이블 컬럼: 종명(한국어+학명), 영명, 속(Genus), CITES, 백색목록

#### 종 추가 (`SpeciesFormModal.vue`)
- 분류 계층 캐스케이딩 선택: 강 → 목 → 과 → 속
- 필드: 한국명, 영명, 학명(필수), 일반명 한국어/영어(선택)
- CITES 등재 여부 + 부속서 등급(I/II/III), 백색목록 여부

#### 종 수정
- 기존 데이터를 폼에 자동 채움 (분류 계층 역추적 포함)

#### 종 삭제
- 삭제 확인 모달 → `DELETE /v1/admin/species/:id`

#### CSV 대량 임포트 (`SpeciesImportModal.vue`)
> 수백~수천 종을 한 번에 등록할 때 사용합니다.

**3단계 워크플로:**
1. **입력**: CSV 파일 드래그&드롭 또는 텍스트 직접 붙여넣기
2. **미리보기**: 파싱 결과 테이블 확인 + 파싱 오류 즉시 표시
3. **결과**: 성공/실패 수 및 실패 행별 원인 표시

**CSV 형식:**
```csv
genus_name,species_kr,species_en,scientific_name,common_name_kr,common_name_en,is_cites,cites_level,is_whitelist
Python,볼파이썬,Ball Python,Python regius,,,false,,true
Eublepharis,레오파드게코,Leopard Gecko,Eublepharis macularius,레게코,,false,,true
Morelia,카펫파이썬,Carpet Python,Morelia spilota,,,false,,false
Bitis,가봉바이퍼,Gaboon Viper,Bitis gabonica,,,true,APPENDIX_II,false
```

**열 설명:**

| 열 | 필수 | 설명 |
|----|------|------|
| `genus_name` | ✅ | 속의 **영명** (DB `genus.name_en` ILIKE 매핑) |
| `species_kr` | ✅ | 한국명 |
| `species_en` | ✅ | 영명 |
| `scientific_name` | ✅ | 학명 (중복 시 자동 건너뜀) |
| `common_name_kr` | - | 일반명 (한국어), 빈 값 허용 |
| `common_name_en` | - | 일반명 (영어), 빈 값 허용 |
| `is_cites` | ✅ | `true` 또는 `false` |
| `cites_level` | 조건부 | `is_cites=true` 시 필수: `APPENDIX_I` / `APPENDIX_II` / `APPENDIX_III` |
| `is_whitelist` | ✅ | `true` 또는 `false` |

**주의 사항:**
- 첫 번째 행이 `genus` 또는 `속` 단어를 포함하면 헤더로 인식해 건너뜀
- `genus_name`은 DB에 등록된 속(Genus)의 영명과 정확히 일치해야 함 (대소문자 무시)
- 동일 배치 내 학명 중복은 두 번째부터 실패 처리

---

### 분류 트리 관리 (`/taxonomy`)

강(Class) → 목(Order) → 과(Family) → 속(Genus) 계층 구조를 관리합니다.

| 항목 | 내용 |
|------|------|
| 데이터 소스 | `GET /v1/admin/taxonomy/tree` |
| 표시 방식 | 아코디언 트리 (펼치기/접기) |

**계층별 CRUD:**

| 계층 | 생성 | 수정 | 삭제 |
|------|------|------|------|
| 강 (Class) | `POST /admin/taxonomy/classes` | `PATCH /admin/taxonomy/classes/:id` | `DELETE /admin/taxonomy/classes/:id` |
| 목 (Order) | `POST /admin/taxonomy/orders` | `PATCH /admin/taxonomy/orders/:id` | `DELETE /admin/taxonomy/orders/:id` |
| 과 (Family) | `POST /admin/taxonomy/families` | `PATCH /admin/taxonomy/families/:id` | `DELETE /admin/taxonomy/families/:id` |
| 속 (Genus) | `POST /admin/taxonomy/genera` | `PATCH /admin/taxonomy/genera/:id` | `DELETE /admin/taxonomy/genera/:id` |

**주의:** 삭제 시 하위 계층(및 종)이 CASCADE 삭제됩니다.

**강(Class) 고유 필드:** `code` (예: `REPTILIA`, `AMPHIBIA`) — 고유 코드, 대문자 자동 변환

---

### 사용자 관리 (`/users`)

전체 회원 목록 조회 및 역할(Role) 관리를 수행합니다.

| 항목 | 내용 |
|------|------|
| 데이터 소스 | `GET /v1/admin/users` |
| 이메일 검색 | 전체 유저 대상 메모리 필터링 (Supabase Auth 제약) |

**테이블 컬럼:** 이메일, 역할 배지, 가입일, 최근 로그인, 역할 변경 셀렉트

**역할(Role) 종류:**

| Role | 레이블 | 권한 |
|------|--------|------|
| `admin` | 관리자 | 전체 기능 |
| `seller` | 판매자 | 전체 기능 |
| `pro_breeder` | 전문 브리더 | 전체 기능 |
| `user` | 일반 사용자 | 전체 기능 |
| `suspended` | 정지 | 조회만 (생성·수정·삭제 UI 비노출) |

**역할 변경 플로:**
1. 셀렉트에서 새 역할 선택
2. 확인 모달 → 변경 전/후 역할 명시
3. `PATCH /v1/admin/users/:userId/role` 호출
4. 취소 시 기존 역할로 자동 복원

---

## 실행 방법

### 개발 서버

```bash
cd web
npm install        # 최초 1회
npm run dev        # http://localhost:3001
```

또는 `.claude/launch.json`에 등록된 `web-admin` 서버 기동:
```bash
# Claude Code preview_start로 실행 가능
```

### 환경 설정

`nuxt.config.ts`의 `runtimeConfig.public`에 하드코딩 (별도 `.env` 불필요):

```typescript
runtimeConfig: {
  public: {
    supabaseUrl: 'https://wawxltmniilnicrwvlar.supabase.co',
    supabaseAnonKey: '...',
    apiBase: 'http://localhost:3000/v1',  // 백엔드 주소
  },
}
```

> 프로덕션 배포 시 `apiBase`를 실제 API 도메인으로 변경해야 합니다.

### 빌드

```bash
cd web
npm run build      # .output/ 생성
npm run preview    # 빌드 결과 로컬 미리보기
```

### 타입 검사

```bash
cd web
npx nuxi typecheck
```

---

## 백엔드 연동 구조

```
웹 어드민 (port 3001)
        │
        │  HTTP + JWT
        ▼
NestJS API (port 3000)
  /v1/admin/*   ← AdminModule (JwtAuthGuard + AdminGuard)
  /v1/auth/me   ← 역할 조회
        │
        ▼
Supabase
  ├── Auth (사용자 목록/역할)
  └── DB / RLS (종·분류 데이터)
```

---

## 관리자 계정 설정

신규 관리자 지정은 Supabase MCP 또는 SQL로 직접 업데이트합니다:

```sql
UPDATE user_profile
SET role = 'admin'
WHERE id = '<Supabase Auth user UUID>';
```

> `user_profile` 테이블은 신규 가입 시 `handle_new_user` 트리거로 자동 생성됩니다.
> 기본 role은 `'user'`이므로, 관리자로 지정할 계정만 위 쿼리로 변경합니다.

---

## 보안 고려사항

- 웹 어드민은 **공개 URL로 서비스하지 않도록** 권고 (사내 네트워크 또는 VPN 뒤에서만 접근)
- 모든 API 요청은 `AdminGuard`를 통해 DB에서 역할을 실시간 검증 (JWT 클레임만으로 판단하지 않음)
- `CORS_ORIGIN`에 어드민 오리진(`http://localhost:3001` 또는 프로덕션 도메인)을 명시적으로 추가해야 함

---

**문서 버전**: 1.0
**최종 수정일**: 2026-02-27
**작성자**: 비늘꼬리 & 게코
