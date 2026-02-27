# 기술 스택

## 개요

ScaledTales는 현대적이고 확장 가능한 기술 스택을 기반으로 구축됩니다.

**핵심 원칙:**
- 타입 안정성 (TypeScript, Dart)
- 크로스 플랫폼 지원
- 빠른 개발 속도
- 장기적 유지보수 용이성

---

## 백엔드

### NestJS + TypeScript

**버전:** NestJS 10.x, TypeScript 5.x

**선택 이유:**
- **체계적인 아키텍처**: 모듈, 컨트롤러, 서비스 패턴으로 구조화
- **TypeScript 네이티브**: 강력한 타입 시스템으로 런타임 에러 감소
- **의존성 주입**: 테스트 가능하고 유지보수 쉬운 코드
- **풍부한 생태계**: Passport, TypeORM, Swagger 등 통합 쉬움
- **확장성**: 마이크로서비스로 전환 가능

**주요 라이브러리:**
```json
{
  "@nestjs/core": "^10.0.0",
  "@nestjs/common": "^10.0.0",
  "@nestjs/typeorm": "^10.0.0",
  "@nestjs/passport": "^10.0.0",
  "@nestjs/swagger": "^7.0.0"
}
```

### TypeORM

**버전:** 0.3.x

**선택 이유:**
- NestJS와 공식 통합
- TypeScript 데코레이터 기반 엔티티 정의
- 마이그레이션 시스템
- 트랜잭션 지원

**대안 고려:**
- Prisma: 타입 안정성 우수하나 NestJS 통합 복잡
- Drizzle: 새로운 라이브러리, 성숙도 부족

---

## 프론트엔드

### Flutter + Dart

**버전:** Flutter 3.x, Dart 3.x

**선택 이유:**
- **진정한 크로스 플랫폼**: 하나의 코드베이스로 iOS/Android
- **네이티브 성능**: 컴파일된 코드, 60fps 보장
- **풍부한 위젯**: Material Design, Cupertino 기본 제공
- **빠른 개발**: Hot Reload로 즉각적인 피드백
- **활발한 커뮤니티**: Google 공식 지원

### Riverpod

**버전:** 2.x

**선택 이유:**
- **타입 안전**: 컴파일 타임 오류 감지
- **테스트 용이**: Provider 쉽게 모킹 가능
- **성능**: 불필요한 리빌드 최소화
- **현대적**: Flutter 최신 패턴 반영

**대안 고려:**
- Bloc: 보일러플레이트 많음
- Provider: Riverpod의 이전 버전
- GetX: 매직 기능 많아 디버깅 어려움

**실제 구현 패턴:**

| Provider 타입 | 사용 사례 |
|-------------|---------|
| `AsyncNotifierProvider` | 전체 동물 목록, 전체 케어로그 목록 (CRUD 메서드 포함) |
| `AsyncNotifierProvider.family` | 동물별 케어로그/측정 목록 (animalId 기반) |
| `FutureProvider.family` | 동물 상세, 종 검색 등 단순 조회 |
| `StateNotifierProvider` | 인증 상태, 검색 상태 |

```dart
// CRUD 메서드 패턴: Notifier 내부에 정의
class CareLogListNotifier extends FamilyAsyncNotifier<List<CareLog>, String> {
  Future<CareLog> create(Map<String, dynamic> data) async {
    final response = await DioClient().dio.post(ApiConstants.careLogs(arg), data: data);
    state = await AsyncValue.guard(() => fetchCareLogs(arg)); // 자동 갱신
    return CareLog.fromJson(response.data['data']);
  }

  Future<CareLog> updateById(String id, Map<String, dynamic> data) async {
    // 주의: update()는 AsyncNotifierBase와 충돌 → updateById() 사용
    final response = await DioClient().dio.patch(ApiConstants.careLogDetail(id), data: data);
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
    return CareLog.fromJson(response.data['data']);
  }
}
```

### Dio

**버전:** 5.x

**선택 이유:**
- **인터셉터**: 토큰 자동 첨부, 에러 처리
- **타임아웃**: 네트워크 오류 관리
- **FormData**: 파일 업로드 지원
- **취소 가능**: 요청 취소 토큰

**주요 설정:**
```dart
final dio = Dio(BaseOptions(
  baseUrl: apiBaseUrl,
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
));

// 인터셉터
dio.interceptors.add(AuthInterceptor());
dio.interceptors.add(LogInterceptor());
```

### 이미지 처리

**image_picker**: 카메라/갤러리에서 이미지 선택  
**flutter_image_compress**: 업로드 전 이미지 압축 (성능, 스토리지 절약)

---

## 데이터베이스 및 백엔드 서비스

### Supabase

**구성 요소:**
- **PostgreSQL**: 관계형 데이터베이스
- **Authentication**: OAuth, JWT 기반 인증
- **Storage**: 이미지 파일 저장
- **Row Level Security**: 데이터 보안

**선택 이유:**
- **올인원 솔루션**: 백엔드 인프라 통합 관리
- **오픈소스**: 벤더 락인 위험 감소
- **PostgreSQL**: 강력한 관계형 DB
- **무료 티어**: MVP 단계 비용 절감
- **확장성**: 자체 호스팅 가능

**Supabase vs Firebase:**
| 항목 | Supabase | Firebase |
|------|----------|----------|
| DB | PostgreSQL (SQL) | Firestore (NoSQL) |
| 오픈소스 | ✅ | ❌ |
| 자체 호스팅 | ✅ | ❌ |
| 복잡한 쿼리 | ✅ (SQL) | 제한적 |
| 실시간 | ✅ | ✅ |

**환경 구성:**
- **개발**: Supabase 무료 프로젝트
- **프로덕션**: Supabase Pro ($25/월)

---

## 개발 도구

### 버전 관리

**Git + GitHub/GitLab**
- Monorepo 구조
- Conventional Commits
- GitHub Flow 브랜치 전략

### IDE

**백엔드:**
- VSCode + ESLint + Prettier
- NestJS Extension

**프론트엔드:**
- VSCode / Android Studio
- Flutter Extension
- Dart Extension

### API 문서화

**Swagger (OpenAPI)**
- NestJS 자동 생성
- Interactive API 문서
- API 클라이언트 자동 생성 가능

---

## 배포 및 인프라

### 백엔드 배포

**후보:**
1. **Vercel**: Serverless, 간편한 배포
2. **Railway**: Monorepo 지원, 자동 배포
3. **Fly.io**: 글로벌 엣지, 저렴한 가격

**MVP 추천**: Railway (무료 티어, NestJS 최적화)

### 프론트엔드 배포

**iOS:**
- TestFlight (베타 테스트)
- App Store Connect

**Android:**
- Google Play Console (내부 테스트)
- Play Store

---

## 모니터링 및 분석

### 에러 트래킹

**Sentry**
- 실시간 에러 모니터링
- 스택 트레이스
- 무료 티어: 5,000 events/월

### 분석

**Firebase Analytics** (선택사항)
- 사용자 행동 분석
- 이벤트 추적
- 무료

---

## 웹 어드민 (Admin Panel)

### Nuxt 3 + Vue 3 + TypeScript

**버전:** Nuxt 3.x, Vue 3.x

**선택 이유:**
- **SPA 모드**: SSR 불필요한 내부 도구에 적합 (`ssr: false`)
- **Nuxt UI v2**: Tailwind 기반 고품질 컴포넌트 세트
- **파일 기반 라우팅**: 페이지 추가가 간편
- **자동 임포트**: Vue/Nuxt composable 자동 임포트

**위치:** `web/` 디렉토리, 포트 3001

**주요 패키지:**
```json
{
  "nuxt": "^3.x",
  "@nuxt/ui": "^2.x",
  "@pinia/nuxt": "^0.x",
  "@supabase/supabase-js": "^2.x"
}
```

**패턴:**
- 상태 관리: Pinia (`stores/auth.ts`)
- HTTP 클라이언트: `$fetch.create()` — JWT 자동 첨부 인터셉터
- 전역 미들웨어: `middleware/auth.global.ts` — 비관리자 접근 차단

---

## 기술 스택 요약

```
┌─────────────────────────────────────┐   ┌─────────────────────────────────────┐
│         Mobile (Flutter)            │   │      Web Admin (Nuxt 3)             │
│  ┌──────────────────────────────┐  │   │  ┌──────────────────────────────┐  │
│  │  UI Layer (Widgets)          │  │   │  │  Pages (Vue 3 + Nuxt UI)     │  │
│  ├──────────────────────────────┤  │   │  ├──────────────────────────────┤  │
│  │  State (Riverpod)            │  │   │  │  State (Pinia)               │  │
│  ├──────────────────────────────┤  │   │  ├──────────────────────────────┤  │
│  │  HTTP Client (Dio)           │  │   │  │  HTTP Client ($fetch)         │  │
│  └──────────────────────────────┘  │   │  └──────────────────────────────┘  │
└─────────────────────────────────────┘   └─────────────────────────────────────┘
                 │                                          │
                 └──────────────┬───────────────────────────┘
                                │ REST API (JWT)
                                ↓
┌─────────────────────────────────────┐
│       Backend (NestJS)              │
│  ┌──────────────────────────────┐  │
│  │  Controllers                 │  │
│  ├──────────────────────────────┤  │
│  │  Services                    │  │
│  ├──────────────────────────────┤  │
│  │  TypeORM (Repositories)      │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────┐
│         Supabase                    │
│  ┌──────────────────────────────┐  │
│  │  PostgreSQL                  │  │
│  ├──────────────────────────────┤  │
│  │  Authentication (JWT)        │  │
│  ├──────────────────────────────┤  │
│  │  Storage (Images)            │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## 의존성 버전 관리

### 백엔드 (package.json)

```json
{
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/typeorm": "^10.0.0",
    "@supabase/supabase-js": "^2.39.0",
    "typeorm": "^0.3.17",
    "pg": "^8.11.0",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0"
  }
}
```

### 프론트엔드 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8

  # 상태 관리
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  freezed_annotation: ^2.4.1   # 불변 상태 클래스 (AuthState 등)

  # HTTP
  dio: ^5.4.0

  # Supabase
  supabase_flutter: ^2.0.0

  # 이미지
  image_picker: ^1.0.0
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.3.0

  # UI
  fl_chart: ^0.66.0

  # 다국어
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # 저장소
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 코드 생성 (freezed, riverpod_generator)
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.5.2

  # 린트
  flutter_lints: ^4.0.0
```

---

## 코드 품질 도구

### 백엔드

**ESLint + Prettier**
```json
{
  "extends": [
    "@nestjs/eslint-config",
    "prettier"
  ],
  "rules": {
    "semi": ["error", "always"],
    "quotes": ["error", "single"]
  }
}
```

### 프론트엔드

**Flutter Lints**
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - avoid_print
    - prefer_single_quotes
```

---

## 보안

### 백엔드

- **Helmet**: HTTP 헤더 보안
- **CORS**: 출처 제한
- **Rate Limiting**: DDoS 방지
- **JWT 검증**: 모든 보호된 엔드포인트

### 데이터베이스

- **Row Level Security**: Supabase 정책
- **환경 변수**: 민감 정보 분리
- **SQL Injection 방지**: TypeORM 파라미터화

### 프론트엔드

- **HTTPS**: 모든 통신 암호화
- **토큰 저장**: Secure Storage
- **입력 검증**: Client-side validation

---

## 테스트

### 백엔드

**Jest**
- 유닛 테스트 (서비스, 인터셉터, 필터, 헬퍼)
- E2E 테스트

**Jest 설정 핵심 포인트:**

```json
// package.json jest 설정
{
  "moduleNameMapper": {
    "^@/(.*)$": "<rootDir>/src/$1",
    "^@common/(.*)$": "<rootDir>/src/common/$1",
    "^@config/(.*)$": "<rootDir>/src/config/$1"
  },
  "transformIgnorePatterns": [
    "node_modules/(?!(uuid)/)"
  ]
}
```

**Mock Repository 헬퍼:**

```typescript
// test/helpers/mock-repository.helper.ts
export function createMockRepository<T extends ObjectLiteral>(): MockRepository<T> {
  return {
    findOne: jest.fn(),
    find: jest.fn(),
    findAndCount: jest.fn(),
    save: jest.fn(),
    create: jest.fn(),
    delete: jest.fn(),
    update: jest.fn(),
    createQueryBuilder: jest.fn().mockReturnValue({
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn().mockReturnThis(),
      // ...
    }),
  };
}
```

**테스트 현황 (Week 10 기준):** 82개 통과

```typescript
describe('AnimalService', () => {
  it('should create an animal', async () => {
    const animal = await service.create(createDto);
    expect(animal).toBeDefined();
  });
});
```

### 프론트엔드

**Flutter Test**
- 위젯 테스트
- 통합 테스트

```dart
testWidgets('AnimalCard displays name', (tester) async {
  await tester.pumpWidget(AnimalCard(animal));
  expect(find.text('레오'), findsOneWidget);
});
```

---

**문서 버전**: 1.3
**최종 수정일**: 2026-02-27
**작성자**: 비늘꼬리 & 게코
