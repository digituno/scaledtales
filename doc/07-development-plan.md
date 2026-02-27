# 개발 계획

## 개요

ScaledTales MVP는 **14주+ (약 3.5개월)** 동안 개발됩니다.

**개발 방식:** 1인 개발 + Claude Code 활용
**목표:** 완성도 높은 MVP 완성 및 앱 스토어 제출

---

## 개발 원칙

1. **Thin Vertical Slice**: 각 기능을 얇게, 수직으로 완성 (백엔드 + 프론트엔드)
2. **점진적 구현**: 단순 → 복잡 순서로 개발
3. **지속적 테스트**: 기능 완성 시마다 테스트
4. **문서 우선**: Claude Code에 명확한 스펙 제공

---

## 전체 일정 요약

| 주차 | 단계 | 주요 내용 | 완료 기준 |
|------|------|----------|----------|
| Week 1 | 기반 구축 | 프로젝트 초기화 + 인증 | ✅ 로그인 성공 |
| Week 2 | 데이터 기반 | 종 분류 시스템 | ✅ 종 검색 가능 |
| Week 3 | 개체 핵심 | 개체 등록/조회 | ✅ 개체 1마리 등록 |
| Week 4 | 개체 완성 | 개체 수정/삭제 + 측정 | ✅ 측정 그래프 표시 |
| Week 5 | 일지 기반 | 먹이급여 일지 | ✅ 일지 작성 가능 |
| Week 6 | 일지 확장 | 나머지 일지 타입 | ✅ 모든 타입 작성 |
| Week 7 | 완성도 | 수정/삭제 + 폴리싱 | ✅ UX 완성도 향상 |
| Week 8 | 배포 준비 | 테스트 + 배포 준비 | ✅ 앱 스토어 제출 준비 |
| Week 9 | 일지 타입 완성 | 6종 일지 타입 + TypeScript 타입 | ✅ 7가지 타입 완성 |
| Week 10 | 품질 강화 | 단위 테스트(82개) + CORS/환경변수 | ✅ `npm test` 82개 통과 |
| Week 11 | 아키텍처 정비 | Provider CRUD 통일 + ApiConstants 정비 | ✅ `dart analyze` 0 issues |
| Week 12 | 리팩터링 완성 | Form 상태 분리 + Freezed 도입 | ✅ `dart analyze` 0 issues |
| Week 13 | Role 시스템 | 사용자 역할 도입 + 권한 기반 UI | ✅ suspended role 쓰기 버튼 비노출 |
| Week 14 | 웹 어드민 | Nuxt 3 관리자 패널 + CSV 임포트 | ✅ 관리자 로그인 및 종/사용자 관리 |

---

## Week 1: 기반 구축

**목표:** 프로젝트 초기 설정 및 인증 구현

### Day 1-2: 프로젝트 초기화

#### 백엔드 (NestJS)
```bash
# 프로젝트 생성
npx @nestjs/cli new scaledtales-backend
cd scaledtales-backend

# 의존성 설치
npm install @nestjs/typeorm typeorm pg
npm install @supabase/supabase-js
npm install @nestjs/passport passport passport-jwt
npm install @nestjs/swagger
npm install class-validator class-transformer

# 개발 의존성
npm install -D @types/passport-jwt
```

**폴더 구조:**
```
src/
  ├── common/
  │   ├── enums/
  │   ├── decorators/
  │   └── filters/
  ├── config/
  ├── auth/
  ├── animals/
  ├── care-logs/
  ├── species/
  └── main.ts
```

**설정 파일:**
- `.env` 환경 변수
- `ormconfig.ts` TypeORM 설정
- `main.ts` Swagger, CORS 설정

#### 프론트엔드 (Flutter)
```bash
# 프로젝트 생성
flutter create scaledtales_mobile
cd scaledtales_mobile

# 의존성 추가 (pubspec.yaml)
dependencies:
  flutter_riverpod: ^2.4.0
  dio: ^5.4.0
  supabase_flutter: ^2.0.0
  image_picker: ^1.0.0
  flutter_image_compress: ^2.1.0
  fl_chart: ^0.66.0
  intl: ^0.18.0
```

**폴더 구조:**
```
lib/
  ├── core/
  │   ├── constants/
  │   ├── enums/
  │   ├── routes/
  │   └── theme/
  ├── features/
  │   ├── auth/
  │   ├── animal/
  │   ├── care_log/
  │   └── settings/
  └── main.dart
```

**설정:**
- 상태 관리 (Riverpod) 초기화
- 라우팅 설정
- i18n 설정 (app_ko.arb, app_en.arb)

---

### Day 3-5: 인증 구현

#### 백엔드
**작업:**
1. Supabase 연동 모듈
2. JWT 검증 가드
3. `/auth/me` 엔드포인트

```typescript
// auth/auth.guard.ts
@Injectable()
export class AuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);
    // JWT 검증
    return true;
  }
}
```

**테스트:**
```bash
curl -H "Authorization: Bearer TOKEN" http://localhost:3000/auth/me
```

#### 프론트엔드
**화면:**
1. 스플래시 화면
2. 로그인 화면
3. 회원가입 화면

**기능:**
- Supabase Auth 로그인/회원가입
- 토큰 저장 (Secure Storage)
- 자동 로그인

**테스트:**
- 회원가입 → 로그인 → 홈 화면 진입 확인

---

### 주말: 리뷰 및 문서화

- 코드 리뷰
- 환경 변수 확인
- Git 커밋 정리

**Week 1 완료 기준:**
- ✅ 로그인 성공
- ✅ `/auth/me` API 동작
- ✅ 홈 화면 진입 (빈 상태)

---

## Week 2: 데이터 기반 구축

**목표:** 종 분류 시스템 완성

### Day 6-7: DB 스키마 및 초기 데이터

#### 작업
1. 마이그레이션 파일 생성
2. 종 분류 테이블 생성 (class, order, family, genus, species)
3. Country 테이블 생성
4. 초기 데이터 준비

**마이그레이션:**
```bash
npm run typeorm migration:create -- src/migrations/InitialSchema
npm run typeorm migration:run
```

**Seed 데이터:**
- 강 2개 (파충강, 양서강)
- 주요 목 10개
- 주요 과 20개
- 주요 속 30개
- **백색목록 종 30-50개**
- 국가 코드 50개

**작업 방법:**
```sql
-- seed.sql
INSERT INTO class (name_kr, name_en, code) VALUES
  ('파충강', 'Reptilia', 'REPTILE'),
  ('양서강', 'Amphibia', 'AMPHIBIAN');

INSERT INTO "order" (class_id, name_kr, name_en) VALUES
  (...);

-- 종 데이터는 CSV에서 가져오기
```

---

### Day 8-9: 백엔드 API

#### Species API
```typescript
// species.controller.ts
@Controller('species')
export class SpeciesController {
  @Get('classes')
  getClasses() { ... }
  
  @Get('classes/:classId/orders')
  getOrders(@Param('classId') classId: string) { ... }
  
  @Get('search')
  search(@Query('q') query: string) { ... }
  
  @Get(':id')
  getOne(@Param('id') id: string) { ... }
}
```

#### Country API
```typescript
@Get('countries')
getCountries(@Query('lang') lang: string) { ... }
```

**테스트:**
```bash
curl http://localhost:3000/species/search?q=레오파드
curl http://localhost:3000/countries?lang=ko
```

---

### Day 10: 프론트엔드 UI

#### 화면
1. 종 선택 화면 (계층적 드릴다운)
2. 종 검색 화면
3. 국가 선택 드롭다운

**구현:**
```dart
// species_selector.dart
class SpeciesSelector extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    // 계층적 선택 UI
    return Column(
      children: [
        SearchBar(),
        ClassSelector(),
        OrderSelector(),
        // ...
      ],
    );
  }
}
```

**테스트:**
- 레오파드게코 검색 → 선택 가능 확인

---

### 주말: 데이터 추가 및 검증

- 종 데이터 추가 입력
- 검색 기능 테스트
- 오타, 누락 확인

**Week 2 완료 기준:**
- ✅ 종 50개 이상 등록
- ✅ 검색 기능 동작
- ✅ 계층 선택 가능

---

## Week 3: 개체 관리 핵심

**목표:** 개체 등록 및 조회 완성

### Day 11-12: 백엔드

#### Animal Entity & API
```typescript
// animal.entity.ts
@Entity()
export class Animal {
  @PrimaryGeneratedColumn('uuid')
  id: string;
  
  @Column()
  user_id: string;
  
  @ManyToOne(() => Species)
  species: Species;
  
  @Column()
  name: string;
  
  // ... 나머지 필드
}
```

**API:**
- `POST /animals` 생성
- `GET /animals` 목록
- `GET /animals/:id` 상세

**이미지 업로드:**
```typescript
// upload.controller.ts
@Post('upload/profile')
@UseInterceptors(FileInterceptor('file'))
uploadProfile(@UploadedFile() file, @Body() body) {
  // Supabase Storage 업로드
}
```

**테스트:**
```bash
curl -X POST http://localhost:3000/animals \
  -H "Authorization: Bearer TOKEN" \
  -d '{"name": "레오", "species_id": "...", ...}'
```

---

### Day 13-15: 프론트엔드

#### 화면
1. 개체 목록 화면
2. 개체 등록 폼 (5단계)
3. 개체 상세 화면

**개체 등록 플로우:**
```dart
// animal_create_screen.dart
class AnimalCreateScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      steps: [
        Step(title: Text('종 선택'), content: SpeciesSelector()),
        Step(title: Text('기본 정보'), content: BasicInfoForm()),
        Step(title: Text('출신 정보'), content: OriginInfoForm()),
        Step(title: Text('부모 정보'), content: ParentInfoForm()),
        Step(title: Text('사진 및 메모'), content: PhotoForm()),
      ],
    );
  }
}
```

**테스트:**
- 개체 1마리 등록
- 목록에서 확인
- 상세 화면 진입

---

### 주말: 사용성 테스트

- 실제 개체 3-5마리 등록
- UI/UX 개선점 파악
- 버그 수정

**Week 3 완료 기준:**
- ✅ 개체 등록 성공
- ✅ 목록 조회 가능
- ✅ 상세 화면 표시

---

## Week 4: 개체 관리 완성

**목표:** 수정/삭제 + 측정 기록

### Day 16-17: 개체 수정/삭제

#### 백엔드
```typescript
@Patch('animals/:id')
update(@Param('id') id: string, @Body() dto: UpdateAnimalDto) { ... }

@Delete('animals/:id')
delete(@Param('id') id: string) { ... }
```

#### 프론트엔드
- 수정 화면 (등록 폼 재사용)
- 삭제 확인 다이얼로그
- 상태 변경 (사망, 분양)

---

### Day 18-20: 측정 기록

#### 백엔드
```typescript
// measurement_log.entity.ts
@Entity()
export class MeasurementLog {
  @Column('decimal')
  weight: number;
  
  @Column('decimal')
  length: number;
  
  @Column('date')
  measured_date: Date;
}

// 트리거: animal 최신값 자동 업데이트
```

**API:**
- `POST /animals/:id/measurements` 생성
- `GET /animals/:id/measurements` 목록

#### 프론트엔드
- 측정 입력 화면
- 측정 이력 목록
- **성장 그래프** (FL Chart)

```dart
// growth_chart.dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: measurements.map((m) => 
          FlSpot(m.date, m.weight)
        ).toList(),
      ),
    ],
  ),
)
```

**테스트:**
- 측정 기록 추가
- 그래프 표시 확인
- 개체 상세에서 최신값 확인

---

### 주말: 통합 테스트

- 개체 생성 → 측정 → 그래프 전체 플로우

**Week 4 완료 기준:**
- ✅ 개체 수정/삭제 가능
- ✅ 측정 기록 추가
- ✅ 성장 그래프 표시

---

## Week 5: 사육 일지 기반

**목표:** 먹이급여 일지 완성

### Day 21-22: 백엔드

#### CareLog Entity
```typescript
@Entity()
export class CareLog {
  @Column()
  log_type: LogType;
  
  @Column('timestamp')
  log_date: Date;
  
  @Column('jsonb')
  details: any;  // 타입별 상세 정보
  
  @Column('jsonb', { nullable: true })
  images: any[];
}
```

**DTO & Validation:**
```typescript
// feeding-details.dto.ts
export class FeedingDetailsDto {
  @IsEnum(FoodType)
  food_type: FoodType;
  
  @IsString()
  food_item: string;
  
  @IsNumber()
  quantity: number;
  
  // ...
}
```

**API:**
- `POST /animals/:id/care-logs` 생성
- `GET /animals/:id/care-logs` 목록
- `GET /care-logs/:id` 상세

---

### Day 23-25: 프론트엔드

#### 화면
1. 일지 타입 선택
2. 먹이급여 일지 폼
3. 일지 목록 (타임라인)
4. 일지 상세

**일지 작성 플로우:**
```dart
// care_log_create_screen.dart
class CareLogCreateScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Stepper(
      steps: [
        Step(title: Text('개체 & 타입'), content: AnimalTypeSelector()),
        Step(title: Text('날짜/시간'), content: DateTimeSelector()),
        Step(title: Text('상세 정보'), content: FeedingForm()),
        Step(title: Text('이미지 & 메모'), content: PhotoMemoForm()),
      ],
    );
  }
}
```

**타임라인 UI:**
```dart
// care_log_timeline.dart
ListView.builder(
  itemBuilder: (context, index) {
    return CareLogCard(log: logs[index]);
  },
)
```

**테스트:**
- 먹이급여 일지 작성
- 목록에서 확인
- 상세 화면 표시

---

### 주말: 일지 기능 테스트

- 여러 개체의 일지 작성
- 이미지 업로드 테스트
- 타임라인 정렬 확인

**Week 5 완료 기준:**
- ✅ 먹이급여 일지 작성
- ✅ 타임라인 표시
- ✅ 이미지 첨부 가능

---

## Week 6: 사육 일지 확장

**목표:** 나머지 6가지 일지 타입 구현

### Day 26-27: 탈피, 배변

#### 백엔드
```typescript
// shedding-details.dto.ts
export class SheddingDetailsDto {
  @IsEnum(ShedCompletion)
  shed_completion: ShedCompletion;
  
  @IsArray()
  @IsOptional()
  problem_areas?: string[];
  
  // ...
}

// defecation-details.dto.ts
export class DefecationDetailsDto {
  @IsBoolean()
  feces_present: boolean;
  
  @IsEnum(FecesConsistency)
  @IsOptional()
  feces_consistency?: FecesConsistency;
  
  // ...
}
```

#### 프론트엔드
- 탈피 일지 폼
- 배변 일지 폼

---

### Day 28-29: 짝짓기, 산란

#### 백엔드
```typescript
// mating-details.dto.ts
export class MatingDetailsDto {
  @IsUUID()
  @IsOptional()
  partner_id?: string;
  
  @IsEnum(MatingSuccess)
  mating_success: MatingSuccess;
  
  // ...
}

// egg-laying-details.dto.ts
export class EggLayingDetailsDto {
  @IsNumber()
  egg_count: number;
  
  @IsBoolean()
  incubation_planned: boolean;
  
  // ...
}
```

#### 프론트엔드
- 짝짓기 일지 폼 (파트너 선택)
- 산란 일지 폼

---

### Day 30: 검란, 부화

#### 백엔드
```typescript
// candling-details.dto.ts
export class CandlingDetailsDto {
  @IsNumber()
  day_after_laying: number;
  
  @IsNumber()
  fertile_count: number;
  
  // ...
}

// hatching-details.dto.ts
export class HatchingDetailsDto {
  @IsNumber()
  hatched_count: number;
  
  @IsArray()
  @IsUUID({each: true})
  @IsOptional()
  offspring_ids?: string[];
  
  // ...
}
```

#### 프론트엔드
- 검란 일지 폼 (산란 일지 선택)
- 부화 일지 폼 (부화 개체 연결)

---

### 주말: 전체 일지 타입 테스트

- 모든 타입 일지 최소 1개씩 작성
- 타입별 아이콘/색상 확인
- parent_log_id 연관 관계 테스트

**Week 6 완료 기준:**
- ✅ 7가지 일지 타입 모두 작성 가능
- ✅ 타입별 UI 구분
- ✅ 산란→검란→부화 연결

---

## Week 7: 완성도 향상

**목표:** 수정/삭제 + 폴리싱

### Day 31-32: 일지 수정/삭제

#### 백엔드
```typescript
@Patch('care-logs/:id')
update(@Param('id') id: string, @Body() dto: UpdateCareLogDto) { ... }

@Delete('care-logs/:id')
delete(@Param('id') id: string) { ... }
```

#### 프론트엔드
- 일지 수정 화면
- 삭제 확인 다이얼로그

---

### Day 33-35: 폴리싱

#### 에러 처리
```dart
// error_handler.dart
class GlobalErrorHandler {
  static void handle(Object error, StackTrace stack) {
    if (error is DioError) {
      // 네트워크 에러
      showErrorSnackBar('인터넷 연결을 확인해주세요');
    } else {
      // 기타 에러
      showErrorSnackBar('오류가 발생했습니다');
    }
  }
}
```

#### 로딩 상태
```dart
// shimmer_loading.dart
Shimmer.fromColors(
  baseColor: Colors.grey[300],
  highlightColor: Colors.grey[100],
  child: ListTile(),
)
```

#### 빈 상태
```dart
// empty_state.dart
class EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/empty.png'),
        Text(message),
        if (onAction != null) ElevatedButton(...),
      ],
    );
  }
}
```

#### 성능 최적화
- 이미지 캐싱 (cached_network_image)
- 리스트 가상화 (ListView.builder)
- API 응답 캐싱

#### 다국어 완성
- 모든 하드코딩된 텍스트 i18n 적용
- 한/영 전환 테스트

---

### 주말: 전체 앱 테스트

- 실제 사용 시나리오 10개 테스트
- 버그 리스트 작성 및 수정
- 성능 프로파일링

**Week 7 완료 기준:**
- ✅ 일지 수정/삭제 가능
- ✅ 에러 처리 완료
- ✅ 로딩/빈 상태 적용
- ✅ 다국어 완성

---

## Week 8: 테스트 및 배포 준비

**목표:** 앱 스토어 제출

### Day 36-37: 테스트

#### E2E 테스트 시나리오
1. 회원가입 → 로그인
2. 개체 등록 → 측정 기록 → 그래프 확인
3. 먹이급여 일지 작성 → 목록 확인
4. 산란 → 검란 → 부화 전체 플로우
5. 개체 수정 → 상태 변경 (사망)

#### 테스트 체크리스트
- [ ] 모든 화면 정상 표시
- [ ] API 에러 처리
- [ ] 오프라인 상태 처리
- [ ] 이미지 업로드/표시
- [ ] 한/영 번역 확인
- [ ] 다크 모드 (선택)

#### 버그 수정
- 발견된 버그 전부 수정
- 크리티컬 버그 0건 목표

---

### Day 38-39: 문서화 및 배포 준비

#### API 문서화
```typescript
// Swagger 설정
const config = new DocumentBuilder()
  .setTitle('ScaledTales API')
  .setDescription('파충류/양서류 사육 관리 API')
  .setVersion('1.0')
  .addBearerAuth()
  .build();
```

#### README 작성
```markdown
# ScaledTales

파충류/양서류 사육 관리 앱

## 기능
- 개체 관리
- 사육 일지
- 측정 기록
- 브리딩 관리

## 기술 스택
- Backend: NestJS + TypeScript
- Frontend: Flutter
- Database: Supabase (PostgreSQL)

## 설치 방법
...
```

#### 환경 설정
- **개발**: `dev.env`
- **프로덕션**: `prod.env`

```bash
# .env.example
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
DATABASE_URL=postgresql://...
```

#### Supabase 프로덕션 설정
- 프로젝트 생성
- RLS 정책 적용
- 백업 설정

#### Flutter 빌드 설정
```yaml
# pubspec.yaml
name: scaledtales
description: Reptile & Amphibian Care Management
version: 1.0.0+1

# 앱 아이콘
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"

# 스플래시 스크린
flutter_native_splash:
  color: "#4CAF50"
  image: assets/splash.png
```

**iOS:**
```bash
cd ios
pod install
```

**Android:**
```bash
cd android
./gradlew assembleRelease
```

---

### Day 40: 배포

#### 백엔드 배포
**Railway 배포:**
```bash
railway login
railway init
railway up
```

**환경 변수 설정:**
- `DATABASE_URL`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `JWT_SECRET`

**배포 확인:**
```bash
curl https://scaledtales-api.railway.app/health
```

#### 프론트엔드 배포

**iOS (TestFlight):**
1. Apple Developer 계정 설정
2. App Store Connect에 앱 등록
3. Xcode에서 Archive
4. TestFlight 업로드
5. 내부 테스터 초대

**Android (내부 테스트):**
1. Google Play Console에 앱 등록
2. AAB 빌드
   ```bash
   flutter build appbundle
   ```
3. 내부 테스트 트랙 업로드
4. 테스터 이메일 등록

---

### 주말: 버퍼 및 최종 마무리

- 예상치 못한 이슈 해결
- 최종 테스트
- 앱 스토어 설명 작성
- 스크린샷 준비

**Week 8 완료 기준:**
- ✅ 백엔드 배포 완료
- ✅ TestFlight/내부 테스트 배포
- ✅ 크리티컬 버그 0건
- ✅ API 문서 완성

---

## 마일스톤 및 데모

### Week 2 종료: 데모 1
**내용:** 로그인 → 종 검색 → 선택 가능

### Week 4 종료: 데모 2
**내용:** 개체 등록 → 측정 기록 → 그래프 확인

### Week 6 종료: 데모 3
**내용:** 전체 일지 작성 → 타임라인 확인

### Week 8 종료: 최종 데모
**내용:** 전체 플로우 시연 + 앱 스토어 제출

---

## 주간 회고

**매주 주말:**
1. 완료한 기능 리스트
2. 발견한 버그/이슈
3. 다음 주 계획 조정
4. 학습한 내용 기록

**템플릿:**
```markdown
## Week X 회고

### 완료
- [ ] 기능 1
- [ ] 기능 2

### 이슈
- 이슈 1: 해결 방법
- 이슈 2: 미해결 (다음 주 계속)

### 학습
- TypeORM 관계 설정
- Flutter Riverpod 상태 관리

### 다음 주 목표
- 기능 3 완성
- 버그 5건 수정
```

---

## 클로드 코드 활용 전략

### 각 Phase 시작 시

**1. 컨텍스트 제공**
```
지금까지 작성한 문서 전달:
- 01-project-overview.md
- 02-tech-stack.md
- 03-database-schema.md
- 04-api-specification.md
- 05-code-management.md
- 06-frontend-screens.md
```

**2. 작은 단위로 요청**
```
❌ "개체 관리 전체 만들어줘"

✅ "Animal Entity를 DB 스키마 문서대로 생성해줘"
✅ "이제 Animal Repository 만들어줘"
✅ "Animal Service CRUD 메서드 구현해줘"
✅ "Animal Controller 엔드포인트 만들어줘"
```

**3. 테스트와 함께**
```
"Animal Service 유닛 테스트도 함께 생성해줘"
"API 엔드포인트 E2E 테스트 추가해줘"
```

**4. 점진적 개선**
```
1차: "기본 CRUD 구현해줘"
2차: "권한 검증 추가해줘"
3차: "페이지네이션 추가해줘"
4차: "에러 처리 개선해줘"
```

**5. 일관성 유지**
```
"이전에 만든 Species API와 동일한 패턴으로 Animal API 만들어줘"
```

---

## 위험 요소 및 대응

### 위험 1: 초기 데이터 준비 지연
**대응:**
- Week 2 주말 집중 작업
- 최소 10종으로 시작, 점진적 확대
- CSV 파일로 일괄 입력

### 위험 2: 복잡한 일지 폼 구현
**대응:**
- Week 5에서 1개 타입 완벽 구현 후 복제
- 공통 컴포넌트 재사용
- 조건부 렌더링 패턴 확립

### 위험 3: 성능 이슈
**대응:**
- Week 7 폴리싱 단계에서 프로파일링
- 필요시 캐싱, 페이지네이션 조정
- 이미지 압축 강화

### 위험 4: 예상치 못한 버그
**대응:**
- Week 8을 버퍼로 활용
- 주요 기능 우선 안정화
- 마이너 버그는 v1.1로 연기

### 위험 5: 앱 스토어 심사 지연
**대응:**
- 가이드라인 사전 숙지
- 스크린샷, 설명 미리 준비
- 거절 시 빠른 수정 후 재제출

---

## 성공 기준

### MVP 완성 기준
- [ ] 개체 5마리 이상 등록 가능
- [ ] 모든 일지 타입 작성 가능
- [ ] 측정 그래프 정상 표시
- [ ] 산란→검란→부화 전체 플로우 동작
- [ ] 한국어/영어 완벽 지원
- [ ] 크리티컬 버그 제로

### 사용자 만족도
- [ ] 직관적인 UI/UX
- [ ] 빠른 응답 속도 (< 2초)
- [ ] 안정적인 데이터 저장
- [ ] 이미지 업로드 성공률 95% 이상

### 기술적 품질
- [ ] API 응답 시간 < 500ms
- [ ] 앱 크래시율 < 1%
- [ ] 테스트 커버리지 > 70%
- [ ] Lighthouse 점수 > 90

---

## 개발 후 계획

### v1.0 출시 (Week 8)
- 앱 스토어 제출
- 베타 테스터 모집
- 피드백 수집

### v1.1 (출시 후 4주)
- 사용자 피드백 반영
- 버그 수정 및 안정화
- 성능 최적화
- 마이너 기능 추가

### v2.0 (출시 후 12주)
- 종 추가 요청 기능
- 관리자 페이지
- 통계 대시보드
- 알림 기능
- 데이터 백업/복원

### v3.0 (TBD)
- 브리더 전용 기능
- 판매자 기능
- 소셜 기능
- 커뮤니티

---

## Week 9: 일지 타입 완성

**목표:** 6종 추가 일지 타입 구현 완성

### 구현 내용
- **백엔드**: SHEDDING, DEFECATION, MATING, EGG_LAYING, CANDLING, HATCHING DTO 및 Service 검증 로직
- **프론트엔드**: 각 타입별 상세 폼 (Step 3), 일지 카드 아이콘/색상, `parent_log_id` 선택 UI

**Week 9 완료 기준:**
- ✅ 7가지 일지 타입 모두 작성/수정/삭제 가능
- ✅ parent_log_id 연관 관계 (EGG_LAYING → CANDLING → HATCHING)
- ✅ 타입별 아이콘/색상 구분

---

## Week 10: 품질 강화

**목표:** 백엔드 단위 테스트 작성 + 환경 설정 정비

### 백엔드 단위 테스트 (82개)

**테스트 대상:**
- `GlobalExceptionFilter` — HTTP 예외, TypeORM EntityNotFound, 일반 에러 처리
- `ResponseInterceptor` — 응답 래핑 (`{ success, data, pagination }`)
- `PaginationHelper` — 페이지네이션 계산
- `OwnershipHelper` — 소유권 검증
- `UploadService` — 파일 업로드, 타입/크기 검증
- `AuthService` — 현재 사용자 조회

**Jest 설정 보강:**
```json
{
  "moduleNameMapper": {
    "^@/(.*)$": "<rootDir>/src/$1"
  },
  "transformIgnorePatterns": ["node_modules/(?!(uuid)/)"]
}
```

### CORS / 환경변수 정비
- 백엔드 `CORS_ORIGINS` 환경변수로 허용 오리진 제어
- Flutter dart-define 방식으로 `API_BASE_URL` 분리
- `Makefile` + `.vscode/launch.json` 작성 (환경별 빌드 자동화)

**Week 10 완료 기준:**
- ✅ `npm test` 82개 통과
- ✅ CORS 허용 오리진 환경변수로 제어
- ✅ `dart analyze` 0 issues

---

## Week 11: 아키텍처 정비

**목표:** Provider CRUD 패턴 통일 (1차)

### 변경 내용

**ApiConstants 보강:**
```dart
static String measurementDetail(String id) => '/measurements/$id';
```

**Notifier CRUD 메서드 추가:**
- `AnimalListNotifier`: `create`, `updateById`, `deleteAnimalById`
- `CareLogListNotifier` / `AllCareLogsNotifier`: `create`, `updateById`, `deleteCareLogById`
- `MeasurementListNotifier`: `create`, `updateById`, `deleteMeasurementById`

**전역 함수 제거:**
- `createCareLog()`, `updateCareLog()`, `deleteCareLog()`
- `updateAnimal()`, `deleteAnimal()`
- `createMeasurement()`, `updateMeasurement()`, `deleteMeasurement()`

**Screen 수정:**
- `AnimalCreateScreen`: `DioClient().dio.post` → `ref.read(animalListProvider.notifier).create()`
- `AnimalEditScreen`: `updateAnimal()` → `animalListProvider.notifier.updateById()`
- `AnimalDetailScreen`: `deleteAnimal()` → `animalListProvider.notifier.deleteAnimalById()`

**Week 11 완료 기준:**
- ✅ `dart analyze` 0 issues
- ✅ Screen에서 DioClient 직접 호출 없음

---

## Week 12: 리팩터링 완성 + Freezed 도입

**목표:** Form 상태 분리, AuthState Freezed 전환

### Freezed 도입

```yaml
# pubspec.yaml
dependencies:
  freezed_annotation: ^2.4.1
dev_dependencies:
  freezed: ^2.5.2
```

```dart
// auth_provider.dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    User? user,
    String? errorMessage,
  }) = _AuthState;
}
```

코드 생성: `dart run build_runner build --delete-conflicting-outputs`

### MeasurementFormScreen ConsumerStatefulWidget 전환

```dart
// 변경 전
class MeasurementFormScreen extends StatefulWidget { ... }
class _MeasurementFormScreenState extends State<MeasurementFormScreen> { ... }

// 변경 후
class MeasurementFormScreen extends ConsumerStatefulWidget { ... }
class _MeasurementFormScreenState extends ConsumerState<MeasurementFormScreen> { ... }
```

### 잔존 전역 함수 호출 제거

- `animal_detail_screen.dart`: `deleteAnimal()` → `animalListProvider.notifier.deleteAnimalById()`
- `care_log_list_screen.dart`: `deleteCareLog()` → `allCareLogsProvider.notifier.deleteCareLogById()`
- `care_log_tab.dart`: `deleteCareLog()` → `careLogListProvider(id).notifier.deleteCareLogById()`
- `measurement_tab.dart`: `deleteMeasurement()` → `measurementListProvider(id).notifier.deleteMeasurementById()`

**Week 12 완료 기준:**
- ✅ `dart analyze` 0 issues
- ✅ 모든 CRUD 호출이 Notifier 메서드를 통해 이루어짐
- ✅ `AuthState` Freezed 적용

---

## Week 13: 사용자 Role 시스템

**목표:** Supabase Auth 기반 사용자별 역할 부여 + 기존 네비게이션 구조 유지하면서 권한 기반 UI 제어

### 역할 정의

| Role | 설명 | 권한 |
|------|------|------|
| `admin` | 관리자 | 전체 기능 |
| `seller` | 판매업체 | 전체 기능 |
| `pro_breeder` | 전문브리더 | 전체 기능 |
| `user` | 일반사육자 | 전체 기능 |
| `suspended` | 탈퇴/정지 | 조회만 (생성·수정·삭제 버튼 비노출) |

### DB 마이그레이션

```sql
CREATE TABLE user_profile (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_role CHECK (role IN ('admin','seller','pro_breeder','user','suspended'))
);
ALTER TABLE user_profile ENABLE ROW LEVEL SECURITY;
-- 신규 가입 시 자동 생성 트리거 (SECURITY DEFINER)
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### 백엔드

- `auth.service.ts`: `getUserById()` 에서 `user_profile` 테이블 role 조회
- `auth/dto/user-me-response.dto.ts`: role 포함 응답 DTO
- `GET /v1/auth/me` 응답: `{ id, email, role, created_at }`

### 프론트엔드

신규 파일:
- `core/enums/user_role.dart`: `UserRole` enum + `canWrite` getter (suspended → false)
- `features/auth/models/user_profile.dart`: `UserProfile` 모델
- `features/auth/providers/user_profile_provider.dart`: `userProfileProvider` + `userRoleProvider`

수정 파일 (권한 적용):
- `animal_list_screen.dart`: FAB + EmptyState 버튼 `canWrite` 조건부
- `animal_detail_screen.dart`: 수정/삭제 PopupMenuButton `canWrite` 조건부
- `care_log_list_screen.dart`: FAB + EmptyState + CareLogCard 수정/삭제 조건부
- `care_log_tab.dart`: 추가 버튼 + CareLogCard 수정/삭제 조건부
- `measurement_tab.dart`: EmptyState + 추가 버튼 + 히스토리 팝업메뉴 조건부

**Week 13 완료 기준:**
- ✅ `user_profile` 테이블 생성 + 기존 사용자 백필
- ✅ `GET /auth/me` 응답에 `role` 포함
- ✅ `dart analyze` 0 issues
- ✅ `suspended` role: 생성·수정·삭제 UI 완전 비노출

---

## Week 14: 웹 어드민 패널

**목표:** 관리자 전용 백오피스 구축 — 종 데이터 관리 및 사용자 권한 제어

### 구현 내용

#### 백엔드 — AdminModule (`src/admin/`)

**AdminGuard:**
```typescript
// JWT user_id → user_profile.role = 'admin' 실시간 검증
// JwtAuthGuard + AdminGuard 이중 보호
@Injectable()
export class AdminGuard implements CanActivate {
  async canActivate(context): Promise<boolean> {
    const user = context.switchToHttp().getRequest().user;
    const { data } = await supabase.from('user_profile')
      .select('role').eq('id', user.sub).single();
    return data?.role === 'admin';
  }
}
```

**엔드포인트 요약:**

| 경로 | 설명 |
|------|------|
| `GET /admin/stats` | 개체/일지/종/사용자 통계 |
| `GET /admin/users` | 사용자 목록 (이메일 검색) |
| `PATCH /admin/users/:id/role` | 역할 변경 |
| `GET /admin/species` | 종 목록 (검색/페이지네이션) |
| `POST /admin/species` | 종 단건 생성 |
| `PATCH /admin/species/:id` | 종 수정 |
| `DELETE /admin/species/:id` | 종 삭제 |
| `POST /admin/species/bulk-import` | CSV 대량 임포트 |
| `GET /admin/taxonomy/tree` | 전체 분류 트리 |
| `POST/PATCH/DELETE /admin/taxonomy/classes` | 강 CRUD |
| `POST/PATCH/DELETE /admin/taxonomy/orders` | 목 CRUD |
| `POST/PATCH/DELETE /admin/taxonomy/families` | 과 CRUD |
| `POST/PATCH/DELETE /admin/taxonomy/genera` | 속 CRUD |

#### 프론트엔드 — 웹 어드민 (`web/`)

**기술 스택:** Nuxt 3 (SPA) + Vue 3 + TypeScript + Nuxt UI v2 + Pinia

**페이지 구성:**

| 페이지 | 경로 | 주요 기능 |
|--------|------|----------|
| 대시보드 | `/dashboard` | 통계 카드 4종 + 케어로그 타입별 바 차트 |
| 종 관리 | `/species` | 검색/페이지네이션 + CRUD + CSV 임포트 |
| 분류 트리 | `/taxonomy` | 계층별 아코디언 + 인라인 CRUD |
| 사용자 관리 | `/users` | 이메일 검색 + 역할 변경 셀렉트 |

**CSV 임포트 (`SpeciesImportModal.vue`):**
- 3단계 워크플로: 입력 → 미리보기 → 결과
- 파일 드래그&드롭 또는 텍스트 직접 붙여넣기
- 클라이언트 파싱 + 실시간 오류 표시
- 성공/실패 수 + 실패 행별 원인 상세 표시

**인증 흐름:**
```
이메일/패스워드 → Supabase Auth
→ GET /auth/me (role 확인)
→ role === 'admin'이면 대시보드 진입
→ 미들웨어(auth.global.ts)가 모든 라우트 보호
```

### 이슈 및 해결

| 이슈 | 원인 | 해결 |
|------|------|------|
| 이메일 검색 결과 없음 | `listUsers({ perPage: 20 })`은 첫 20건만 반환 | 전체 페이지 loop 후 메모리 필터링 |
| API 응답 필드 불일치 | `ResponseInterceptor`가 `{ data: [], pagination }` → `{ data: [], pagination }` 평탄화 | `res.data` (배열), `res.pagination` 직접 접근 |
| 모달 backdrop 닫힘 미전파 | `UModal v-model`만으로는 부모에게 close 미전달 | `watch(open, val => !val && emit('close'))` 추가 |

**Week 14 완료 기준:**
- ✅ 백엔드 AdminModule 구현 및 빌드 통과
- ✅ 웹 어드민 4개 페이지 구현 (대시보드/종/분류/사용자)
- ✅ CSV 대량 임포트 기능 (3단계 UI)
- ✅ 관리자 계정(`nije1983@gmail.com`) role='admin' 설정
- ✅ `nuxi typecheck` 통과 + Nuxt 빌드 성공
- ✅ TypeScript 오류 및 모달 버그 수정 완료

---

## 일정 조정 가이드

### 빠른 MVP (6주)
- Week 5-6: 일지 타입 3개만 (먹이급여, 탈피, 배변)
- Week 7: 폴리싱 축소
- Week 8: 배포

### 여유 있는 MVP (10주)
- Week 1-2: 더 많은 종 데이터 입력
- Week 7-8: 폴리싱 강화
- Week 9: 추가 기능 (통계 등)
- Week 10: 배포

---

## 체크리스트

### 개발 시작 전
- [ ] Supabase 프로젝트 생성
- [ ] Git Repository 생성
- [ ] 환경 변수 설정
- [ ] 문서 검토

### 개발 중 (매주)
- [ ] 주간 목표 달성
- [ ] 코드 리뷰
- [ ] 테스트 실행
- [ ] 회고 작성

### 배포 전
- [ ] E2E 테스트 완료
- [ ] API 문서 완성
- [ ] README 작성
- [ ] 스크린샷 준비
- [ ] 앱 설명 작성

---

**문서 버전**: 1.4
**최종 수정일**: 2026-02-27
**작성자**: 비늘꼬리 & 게코
