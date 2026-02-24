# 코드 관리 전략

## 개요

ScaledTales는 **하이브리드 코드 관리 전략**을 사용합니다. 자주 변경되지 않는 코드는 애플리케이션 레벨(ENUM)에서, 동적 관리가 필요한 데이터는 데이터베이스에서 관리합니다.

---

## 관리 전략 요약

| 항목 | 관리 방식 | 이유 |
|------|----------|------|
| **고정 코드** (sex, origin_type 등) | **ENUM/상수** | 변경 빈도 낮음, 타입 안정성 |
| **가변 데이터** (country, species) | **DB 테이블** | 자주 추가/수정, 동적 관리 필요 |
| **다국어** | **i18n 파일** (프론트엔드) | 번역 중앙 관리, 성능 |

---

## 1. ENUM으로 관리하는 코드

### 1.1 백엔드 (NestJS)

#### Sex (성별)

```typescript
// src/common/enums/sex.enum.ts
export enum Sex {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  UNKNOWN = 'UNKNOWN'
}
```

#### OriginType (출신 유형)

```typescript
// src/common/enums/origin-type.enum.ts
export enum OriginType {
  CB = 'CB',        // Captive Bred (사육 번식)
  WC = 'WC',        // Wild Caught (야생 채집)
  CH = 'CH',        // Captive Hatched (사육 부화)
  CF = 'CF',        // Captive Farmed (사육장 번식)
  UNKNOWN = 'UNKNOWN'
}
```

#### AcquisitionSource (입양 경로)

```typescript
// src/common/enums/acquisition-source.enum.ts
export enum AcquisitionSource {
  BREEDER = 'BREEDER',
  PET_SHOP = 'PET_SHOP',
  PRIVATE = 'PRIVATE',
  RESCUED = 'RESCUED',
  BRED = 'BRED',
  OTHER = 'OTHER'
}
```

#### AnimalStatus (개체 상태)

```typescript
// src/common/enums/animal-status.enum.ts
export enum AnimalStatus {
  ALIVE = 'ALIVE',
  DECEASED = 'DECEASED',
  REHOMED = 'REHOMED'
}
```

#### LogType (일지 유형)

```typescript
// src/common/enums/log-type.enum.ts
export enum LogType {
  FEEDING = 'FEEDING',
  SHEDDING = 'SHEDDING',
  DEFECATION = 'DEFECATION',
  MATING = 'MATING',
  EGG_LAYING = 'EGG_LAYING',
  CANDLING = 'CANDLING',
  HATCHING = 'HATCHING'
}
```

#### FoodType (먹이 종류)

```typescript
// src/common/enums/food-type.enum.ts
export enum FoodType {
  LIVE_INSECT = 'LIVE_INSECT',
  FROZEN_PREY = 'FROZEN_PREY',
  PELLET = 'PELLET',
  FRUIT = 'FRUIT',
  VEGETABLE = 'VEGETABLE',
  SUPPLEMENT = 'SUPPLEMENT',
  OTHER = 'OTHER'
}
```

#### Unit (단위)

```typescript
// src/common/enums/unit.enum.ts
export enum Unit {
  EA = 'EA',    // 개
  G = 'G',      // 그램
  ML = 'ML'     // 밀리리터
}
```

#### FeedingResponse (급여 반응)

```typescript
// src/common/enums/feeding-response.enum.ts
export enum FeedingResponse {
  GOOD = 'GOOD',
  NORMAL = 'NORMAL',
  POOR = 'POOR',
  REFUSED = 'REFUSED'
}
```

#### FeedingMethod (급여 방법)

```typescript
// src/common/enums/feeding-method.enum.ts
export enum FeedingMethod {
  HAND_FED = 'HAND_FED',
  TONGS = 'TONGS',
  BOWL = 'BOWL',
  FREE_ROAMING = 'FREE_ROAMING',
  OTHER = 'OTHER'
}
```

#### ShedCompletion (탈피 완성도)

```typescript
// src/common/enums/shed-completion.enum.ts
export enum ShedCompletion {
  COMPLETE = 'COMPLETE',
  PARTIAL = 'PARTIAL',
  STUCK = 'STUCK',
  IN_PROGRESS = 'IN_PROGRESS'
}
```

#### FecesConsistency (대변 상태)

```typescript
// src/common/enums/feces-consistency.enum.ts
export enum FecesConsistency {
  NORMAL = 'NORMAL',
  SOFT = 'SOFT',
  HARD = 'HARD',
  WATERY = 'WATERY',
  BLOODY = 'BLOODY',
  MUCUS = 'MUCUS'
}
```

#### UrateCondition (요산 상태)

```typescript
// src/common/enums/urate-condition.enum.ts
export enum UrateCondition {
  NORMAL = 'NORMAL',
  YELLOW = 'YELLOW',
  ORANGE = 'ORANGE',
  GREEN = 'GREEN',
  ABSENT = 'ABSENT'
}
```

#### MatingSuccess (짝짓기 성공 여부)

```typescript
// src/common/enums/mating-success.enum.ts
export enum MatingSuccess {
  SUCCESSFUL = 'SUCCESSFUL',
  ATTEMPTED = 'ATTEMPTED',
  REJECTED = 'REJECTED',
  IN_PROGRESS = 'IN_PROGRESS'
}
```

#### IncubationMethod (부화 방법)

```typescript
// src/common/enums/incubation-method.enum.ts
export enum IncubationMethod {
  NATURAL = 'NATURAL',
  ARTIFICIAL = 'ARTIFICIAL',
  NONE = 'NONE'
}
```

### 1.2 프론트엔드 (Flutter)

Flutter에서는 백엔드와 동일한 ENUM을 정의합니다.

```dart
// lib/core/enums/sex.dart
enum Sex {
  male('MALE'),
  female('FEMALE'),
  unknown('UNKNOWN');

  const Sex(this.value);
  final String value;
}

// lib/core/enums/origin_type.dart
enum OriginType {
  cb('CB'),
  wc('WC'),
  ch('CH'),
  cf('CF'),
  unknown('UNKNOWN');

  const OriginType(this.value);
  final String value;
}

// ... 나머지 ENUM들도 동일하게
```

---

## 2. DB로 관리하는 데이터

### 2.1 Country (국가)

**이유:**
- 목록이 많음 (50+ 국가)
- 표시 순서 관리 필요
- 활성화/비활성화 관리

**테이블 구조:**
```sql
CREATE TABLE country (
  code VARCHAR(2) PRIMARY KEY,
  name_kr VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  display_order INT DEFAULT 999,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**API:**
```http
GET /countries?lang=ko
```

### 2.2 Species (종 분류)

**이유:**
- 계층 구조 (class → order → family → genus → species)
- 지속적인 추가 필요
- 검색 기능 필요

**테이블 구조:**
- `class` (강)
- `order` (목)
- `family` (과)
- `genus` (속)
- `species` (종)

**API:**
```http
GET /species/search?q=레오파드
GET /species/{speciesId}
```

---

## 3. 다국어 (i18n)

### 3.1 프론트엔드 (Flutter)

**패키지:** `flutter_localizations` + `intl`

**구조:**
```
lib/
  l10n/
    app_en.arb
    app_ko.arb
```

**app_ko.arb:**
```json
{
  "@@locale": "ko",
  
  "sex_male": "수컷",
  "sex_female": "암컷",
  "sex_unknown": "미확인",
  
  "origin_type_cb": "사육 번식",
  "origin_type_wc": "야생 채집",
  "origin_type_ch": "사육 부화",
  "origin_type_cf": "사육장 번식",
  "origin_type_unknown": "알 수 없음",
  
  "acquisition_source_breeder": "브리더",
  "acquisition_source_pet_shop": "펫샵",
  "acquisition_source_private": "개인거래",
  "acquisition_source_rescued": "구조",
  "acquisition_source_bred": "자가번식",
  "acquisition_source_other": "기타",
  
  "status_alive": "생존",
  "status_deceased": "사망",
  "status_rehomed": "분양됨",
  
  "log_type_feeding": "먹이급여",
  "log_type_shedding": "탈피",
  "log_type_defecation": "배변",
  "log_type_mating": "짝짓기",
  "log_type_egg_laying": "산란",
  "log_type_candling": "검란",
  "log_type_hatching": "부화",
  
  "food_type_live_insect": "살아있는 곤충",
  "food_type_frozen_prey": "냉동 먹이",
  "food_type_pellet": "펠렛",
  "food_type_fruit": "과일",
  "food_type_vegetable": "채소",
  "food_type_supplement": "보충제",
  "food_type_other": "기타",
  
  "unit_ea": "개",
  "unit_g": "g",
  "unit_ml": "ml",
  
  "feeding_response_good": "좋음",
  "feeding_response_normal": "보통",
  "feeding_response_poor": "나쁨",
  "feeding_response_refused": "거부",
  
  "feeding_method_hand_fed": "손 급여",
  "feeding_method_tongs": "집게 사용",
  "feeding_method_bowl": "그릇",
  "feeding_method_free_roaming": "자유 급여",
  "feeding_method_other": "기타",
  
  "shed_completion_complete": "완전 탈피",
  "shed_completion_partial": "부분 탈피",
  "shed_completion_stuck": "탈피 불량",
  "shed_completion_in_progress": "진행 중",
  
  "feces_consistency_normal": "정상",
  "feces_consistency_soft": "무름",
  "feces_consistency_hard": "딱딱함",
  "feces_consistency_watery": "묽음",
  "feces_consistency_bloody": "혈변",
  "feces_consistency_mucus": "점액",
  
  "urate_condition_normal": "정상",
  "urate_condition_yellow": "노란색",
  "urate_condition_orange": "주황색",
  "urate_condition_green": "녹색",
  "urate_condition_absent": "없음",
  
  "mating_success_successful": "성공",
  "mating_success_attempted": "시도",
  "mating_success_rejected": "거부",
  "mating_success_in_progress": "진행 중",
  
  "incubation_method_natural": "자연 부화",
  "incubation_method_artificial": "인공 부화",
  "incubation_method_none": "하지 않음"
}
```

**app_en.arb:**
```json
{
  "@@locale": "en",
  
  "sex_male": "Male",
  "sex_female": "Female",
  "sex_unknown": "Unknown",
  
  "origin_type_cb": "Captive Bred",
  "origin_type_wc": "Wild Caught",
  "origin_type_ch": "Captive Hatched",
  "origin_type_cf": "Captive Farmed",
  "origin_type_unknown": "Unknown",
  
  // ... 영어 번역
}
```

**사용 예시:**
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Widget에서 사용
Text(AppLocalizations.of(context)!.sex_male)

// 또는 헬퍼 함수
String getSexLabel(BuildContext context, Sex sex) {
  switch (sex) {
    case Sex.male:
      return AppLocalizations.of(context)!.sex_male;
    case Sex.female:
      return AppLocalizations.of(context)!.sex_female;
    case Sex.unknown:
      return AppLocalizations.of(context)!.sex_unknown;
  }
}
```

### 3.2 백엔드 (NestJS)

백엔드는 값만 반환하고, 번역은 프론트엔드에서 처리합니다.

```typescript
// API 응답
{
  "sex": "MALE"  // ENUM 값만 반환
}

// 프론트엔드에서 번역
sex_male → "수컷" (한국어) / "Male" (영어)
```

---

## 4. 코드 사용 패턴

### 4.1 백엔드 DTO에서 ENUM 사용

```typescript
// src/animals/dto/create-animal.dto.ts
import { Sex } from '@/common/enums/sex.enum';
import { OriginType } from '@/common/enums/origin-type.enum';
import { AcquisitionSource } from '@/common/enums/acquisition-source.enum';
import { IsEnum, IsString, IsOptional } from 'class-validator';

export class CreateAnimalDto {
  @IsString()
  name: string;

  @IsEnum(Sex)
  sex: Sex;

  @IsEnum(OriginType)
  origin_type: OriginType;

  @IsEnum(AcquisitionSource)
  acquisition_source: AcquisitionSource;

  // ...
}
```

### 4.2 백엔드 Entity에서 ENUM 사용

```typescript
// src/animals/entities/animal.entity.ts
import { Entity, Column } from 'typeorm';
import { Sex } from '@/common/enums/sex.enum';

@Entity()
export class Animal {
  @Column({
    type: 'varchar',
    length: 20
  })
  sex: Sex;

  // ...
}
```

### 4.3 프론트엔드에서 ENUM → 번역

```dart
// lib/features/animal/widgets/sex_selector.dart
class SexSelector extends StatelessWidget {
  final Sex? value;
  final ValueChanged<Sex?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return DropdownButton<Sex>(
      value: value,
      items: [
        DropdownMenuItem(
          value: Sex.male,
          child: Text(l10n.sex_male),
        ),
        DropdownMenuItem(
          value: Sex.female,
          child: Text(l10n.sex_female),
        ),
        DropdownMenuItem(
          value: Sex.unknown,
          child: Text(l10n.sex_unknown),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
```

### 4.4 프론트엔드 모델에서 ENUM 파싱

```dart
// lib/features/animal/models/animal.dart
class Animal {
  final String id;
  final String name;
  final Sex sex;
  final OriginType originType;

  Animal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        sex = Sex.values.firstWhere(
          (e) => e.value == json['sex'],
          orElse: () => Sex.unknown,
        ),
        originType = OriginType.values.firstWhere(
          (e) => e.value == json['origin_type'],
          orElse: () => OriginType.unknown,
        );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sex': sex.value,
    'origin_type': originType.value,
  };
}
```

---

## 5. 코드 확장 전략

### 5.1 새 ENUM 값 추가

**단계:**
1. 백엔드 ENUM에 값 추가
2. 프론트엔드 ENUM에 값 추가
3. i18n 파일에 번역 추가
4. 배포

**예시: 새로운 입양 경로 추가**

```typescript
// 백엔드
export enum AcquisitionSource {
  BREEDER = 'BREEDER',
  PET_SHOP = 'PET_SHOP',
  PRIVATE = 'PRIVATE',
  RESCUED = 'RESCUED',
  BRED = 'BRED',
  EXPO = 'EXPO',  // ← 새로 추가
  OTHER = 'OTHER'
}
```

```dart
// 프론트엔드
enum AcquisitionSource {
  breeder('BREEDER'),
  petShop('PET_SHOP'),
  private('PRIVATE'),
  rescued('RESCUED'),
  bred('BRED'),
  expo('EXPO'),  // ← 새로 추가
  other('OTHER');

  const AcquisitionSource(this.value);
  final String value;
}
```

```json
// app_ko.arb
{
  "acquisition_source_expo": "전시회"
}

// app_en.arb
{
  "acquisition_source_expo": "Expo"
}
```

### 5.2 ENUM → DB 테이블 전환

나중에 특정 ENUM을 DB로 전환해야 할 경우:

**예시: morph를 DB 테이블로 전환**

1. **DB 테이블 생성**
   ```sql
   CREATE TABLE morph (
     id UUID PRIMARY KEY,
     species_id UUID REFERENCES species(id),
     name_kr VARCHAR(200),
     name_en VARCHAR(200),
     is_verified BOOLEAN DEFAULT FALSE
   );
   ```

2. **기존 데이터 마이그레이션**
   ```sql
   INSERT INTO morph (species_id, name_kr, name_en, is_verified)
   SELECT DISTINCT 
     species_id, 
     morph, 
     morph, 
     FALSE
   FROM animal
   WHERE morph IS NOT NULL;
   ```

3. **animal 테이블 수정**
   ```sql
   ALTER TABLE animal 
   ADD COLUMN morph_id UUID REFERENCES morph(id);
   
   -- 데이터 연결
   UPDATE animal a
   SET morph_id = m.id
   FROM morph m
   WHERE a.morph = m.name_kr
     AND a.species_id = m.species_id;
   
   -- 기존 컬럼 삭제 (선택)
   ALTER TABLE animal DROP COLUMN morph;
   ```

4. **API 추가**
   ```http
   GET /species/{speciesId}/morphs
   POST /morphs (관리자용)
   ```

---

## 6. 코드 검증

### 6.1 백엔드 Validation

```typescript
// class-validator 사용
import { IsEnum } from 'class-validator';

export class CreateAnimalDto {
  @IsEnum(Sex, {
    message: 'sex must be one of: MALE, FEMALE, UNKNOWN'
  })
  sex: Sex;
}
```

**에러 응답:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "sex": ["sex must be one of: MALE, FEMALE, UNKNOWN"]
    }
  }
}
```

### 6.2 프론트엔드 Validation

```dart
// Riverpod + Freezed
@freezed
class AnimalFormState with _$AnimalFormState {
  const factory AnimalFormState({
    required String name,
    required Sex? sex,  // nullable = 필수 선택
    String? errorMessage,
  }) = _AnimalFormState;
}

// Validator
String? validateSex(Sex? sex) {
  if (sex == null) {
    return '성별을 선택해주세요';
  }
  return null;
}
```

> **Freezed 의존성**: `freezed_annotation: ^2.4.1` (dep), `freezed: ^2.5.2` (dev).
> 코드 생성: `dart run build_runner build --delete-conflicting-outputs`
> 생성 파일: `*.freezed.dart` (Git 추적 제외 가능)

---

## 7. 코드 문서화

### 7.1 ENUM 주석

```typescript
/**
 * 개체 성별
 * 
 * @description
 * 개체의 생물학적 성별을 나타냅니다.
 * 정확히 알 수 없는 경우 UNKNOWN을 사용합니다.
 */
export enum Sex {
  /** 수컷 */
  MALE = 'MALE',
  
  /** 암컷 */
  FEMALE = 'FEMALE',
  
  /** 미확인 */
  UNKNOWN = 'UNKNOWN'
}
```

### 7.2 코드 목록 문서

모든 ENUM 값과 번역을 정리한 문서 유지:

**docs/codes.md**
```markdown
# 코드 목록

## Sex (성별)
| 코드 | 한국어 | English |
|------|--------|---------|
| MALE | 수컷 | Male |
| FEMALE | 암컷 | Female |
| UNKNOWN | 미확인 | Unknown |

## OriginType (출신 유형)
| 코드 | 한국어 | English | 설명 |
|------|--------|---------|------|
| CB | 사육 번식 | Captive Bred | 사육장에서 번식 |
| WC | 야생 채집 | Wild Caught | 야생에서 채집 |
| CH | 사육 부화 | Captive Hatched | 사육장에서 부화 (야생 부모) |
| CF | 사육장 번식 | Captive Farmed | 대량 사육장 번식 |
| UNKNOWN | 알 수 없음 | Unknown | 출신 불명 |

...
```

---

## 8. 테스트

### 8.1 백엔드 ENUM 테스트

```typescript
// animal.service.spec.ts
describe('AnimalService', () => {
  it('should validate sex enum', async () => {
    const dto = {
      sex: 'INVALID_VALUE'
    };
    
    await expect(service.create(dto))
      .rejects
      .toThrow('sex must be one of: MALE, FEMALE, UNKNOWN');
  });
});
```

### 8.2 프론트엔드 번역 테스트

```dart
// sex_test.dart
void main() {
  testWidgets('Sex dropdown displays correct labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ko'),
        home: SexSelector(),
      ),
    );
    
    expect(find.text('수컷'), findsOneWidget);
    expect(find.text('암컷'), findsOneWidget);
    expect(find.text('미확인'), findsOneWidget);
  });
}
```

---

## 전략 요약

| 항목 | 관리 방식 | 위치 | 장점 |
|------|----------|------|------|
| **코드값** | ENUM | 백엔드/프론트엔드 | 타입 안정성, 빠른 검증 |
| **번역** | i18n 파일 | 프론트엔드 | 중앙 관리, 성능 |
| **국가** | DB 테이블 | Supabase | 동적 관리 |
| **종** | DB 테이블 | Supabase | 검색, 계층 구조 |

---

## 9. Provider CRUD 패턴

### 9.1 기본 원칙

- CRUD 로직은 반드시 Notifier 메서드 내에 정의한다. Screen이나 전역 함수에서 직접 `DioClient().dio`를 호출하지 않는다.
- CRUD 성공 후 `state = await AsyncValue.guard(() => fetch...())` 로 목록을 자동 갱신한다.
- **`update()` 이름 금지**: Riverpod `AsyncNotifierBase`가 `update()` 메서드를 정의하므로 커스텀 업데이트 메서드는 반드시 `updateById()` 등 다른 이름을 사용한다.

### 9.2 AsyncNotifierProvider.family CRUD 패턴

```dart
// lib/features/care_log/providers/care_log_provider.dart

final careLogListProvider = AsyncNotifierProvider.family<
    CareLogListNotifier, List<CareLog>, String>(
  CareLogListNotifier.new,
);

class CareLogListNotifier extends FamilyAsyncNotifier<List<CareLog>, String> {
  @override
  Future<List<CareLog>> build(String arg) => fetchCareLogs(arg);

  Future<List<CareLog>> fetchCareLogs(String animalId) async {
    final response = await DioClient().dio.get(ApiConstants.careLogs(animalId));
    return (response.data['data'] as List)
        .map((e) => CareLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CareLog> create(Map<String, dynamic> data) async {
    final response = await DioClient().dio.post(
      ApiConstants.careLogs(arg), data: data);
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
    return CareLog.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<CareLog> updateById(String logId, Map<String, dynamic> data) async {
    final response = await DioClient().dio.patch(
      ApiConstants.careLogDetail(logId), data: data);
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
    return CareLog.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCareLogById(String logId) async {
    await DioClient().dio.delete(ApiConstants.careLogDetail(logId));
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
  }
}
```

### 9.3 Screen에서 Notifier 메서드 호출

```dart
// 생성
await ref.read(careLogListProvider(animalId).notifier).create(data);

// 수정
await ref.read(careLogListProvider(animalId).notifier).updateById(logId, data);

// 삭제
await ref.read(careLogListProvider(animalId).notifier).deleteCareLogById(logId);

// 두 Provider 동기화 (동물별 목록 갱신 후 전체 목록도 갱신)
ref.invalidate(allCareLogsProvider);
```

### 9.4 ConsumerStatefulWidget 사용 시점

로컬 상태(TextEditingController, PageController 등)와 Riverpod `ref`를 함께 사용해야 할 Form 화면에서는 `ConsumerStatefulWidget` + `ConsumerState`를 사용한다.

```dart
class MeasurementFormScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MeasurementFormScreen> createState() =>
      _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends ConsumerState<MeasurementFormScreen> {
  final _weightController = TextEditingController();

  Future<void> _submit() async {
    await ref
        .read(measurementListProvider(widget.animalId).notifier)
        .create(data);
  }
}
```

---

**문서 버전**: 1.2
**최종 수정일**: 2026-02-24
**작성자**: 비늘꼬리 & 게코
