# 데이터베이스 스키마

## 개요

ScaledTales의 데이터베이스는 **정규화된 관계형 구조**로 설계되어 있으며, 확장성과 데이터 무결성을 보장합니다.

**DBMS**: PostgreSQL 15.x (Supabase)

---

## ERD (Entity Relationship Diagram)

```mermaid
erDiagram
    users ||--o{ animals : "owns"
    users ||--o{ care_logs : "creates"
    users ||--o{ measurement_logs : "records"
    
    species ||--o{ animals : "belongs to"
    genus ||--o{ species : "contains"
    family ||--o{ genus : "contains"
    order ||--o{ family : "contains"
    class ||--o{ order : "contains"
    
    animals ||--o{ care_logs : "has"
    animals ||--o{ measurement_logs : "has"
    animals ||--o{ animals : "father"
    animals ||--o{ animals : "mother"
    
    care_logs ||--o{ care_logs : "parent_log"
    
    country ||--o{ animals : "origin"
```

---

## 테이블 상세

### 1. 종 분류 (Species Taxonomy)

#### 1.1 class (강)

```sql
CREATE TABLE class (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_kr VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  code VARCHAR(20) NOT NULL UNIQUE,  -- 'REPTILE', 'AMPHIBIAN'
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_class_code ON class(code);
```

**예시 데이터:**
```sql
INSERT INTO class (name_kr, name_en, code) VALUES
  ('파충강', 'Reptilia', 'REPTILE'),
  ('양서강', 'Amphibia', 'AMPHIBIAN');
```

#### 1.2 order (목)

```sql
CREATE TABLE "order" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES class(id) ON DELETE CASCADE,
  name_kr VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_order_class_id ON "order"(class_id);
```

**예시 데이터:**
```sql
INSERT INTO "order" (class_id, name_kr, name_en) VALUES
  ('reptile-uuid', '뱀목', 'Squamata'),
  ('reptile-uuid', '거북목', 'Testudines'),
  ('amphibian-uuid', '개구리목', 'Anura');
```

#### 1.3 family (과)

```sql
CREATE TABLE family (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES "order"(id) ON DELETE CASCADE,
  name_kr VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_family_order_id ON family(order_id);
```

#### 1.4 genus (속)

```sql
CREATE TABLE genus (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID NOT NULL REFERENCES family(id) ON DELETE CASCADE,
  name_kr VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_genus_family_id ON genus(family_id);
```

#### 1.5 species (종)

```sql
CREATE TABLE species (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  genus_id UUID NOT NULL REFERENCES genus(id) ON DELETE CASCADE,
  
  -- 종 정보
  species_kr VARCHAR(100) NOT NULL,
  species_en VARCHAR(100) NOT NULL,
  scientific_name VARCHAR(200) NOT NULL,  -- 'Genus species'
  common_name_kr VARCHAR(200),
  common_name_en VARCHAR(200),
  
  -- 법적 정보
  is_cites BOOLEAN DEFAULT FALSE,
  cites_level VARCHAR(20),  -- 'APPENDIX_I', 'APPENDIX_II', 'APPENDIX_III'
  is_whitelist BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_species_genus_id ON species(genus_id);
CREATE INDEX idx_species_scientific_name ON species(scientific_name);
CREATE INDEX idx_species_common_name_kr ON species(common_name_kr);
CREATE INDEX idx_species_whitelist ON species(is_whitelist);
CREATE INDEX idx_species_cites ON species(is_cites);
```

**예시 데이터:**
```sql
INSERT INTO species (genus_id, species_kr, species_en, scientific_name, common_name_kr, common_name_en, is_whitelist) VALUES
  ('eublepharis-uuid', '표범게코', 'macularius', 'Eublepharis macularius', '레오파드게코', 'Leopard Gecko', TRUE);
```

---

### 2. 코드 테이블

#### 2.1 country (국가)

```sql
CREATE TABLE country (
  code VARCHAR(2) PRIMARY KEY,  -- ISO 3166-1 alpha-2
  name_kr VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  display_order INT DEFAULT 999,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_country_active ON country(is_active);
CREATE INDEX idx_country_display_order ON country(display_order);
```

**예시 데이터:**
```sql
INSERT INTO country (code, name_kr, name_en, display_order) VALUES
  ('KR', '대한민국', 'South Korea', 1),
  ('US', '미국', 'United States', 2),
  ('JP', '일본', 'Japan', 3),
  ('ID', '인도네시아', 'Indonesia', 4),
  ('TZ', '탄자니아', 'Tanzania', 5);
```

---

### 3. 개체 관리

#### 3.1 animal (개체)

```sql
CREATE TABLE animal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  species_id UUID NOT NULL REFERENCES species(id),
  
  -- 기본 정보
  name VARCHAR(100) NOT NULL,
  morph VARCHAR(200),
  sex VARCHAR(20) NOT NULL,  -- 'MALE', 'FEMALE', 'UNKNOWN'
  
  -- 생년월일 (분리)
  birth_year INT,
  birth_month INT,  -- 1-12
  birth_date INT,   -- 1-31
  
  -- 출신 정보
  origin_type VARCHAR(20) NOT NULL,  -- 'CB', 'WC', 'CH', 'CF', 'UNKNOWN'
  origin_country VARCHAR(2) REFERENCES country(code),
  
  -- 입양 정보
  acquisition_date DATE NOT NULL,
  acquisition_source VARCHAR(20) NOT NULL,  -- 'BREEDER', 'PET_SHOP', 'PRIVATE', 'RESCUED', 'BRED', 'OTHER'
  acquisition_note TEXT,
  
  -- 부모 개체
  father_id UUID REFERENCES animal(id) ON DELETE SET NULL,
  mother_id UUID REFERENCES animal(id) ON DELETE SET NULL,
  
  -- 최신 측정값 (캐싱)
  current_weight DECIMAL(10, 2),  -- g
  current_length DECIMAL(10, 2),  -- cm
  last_measured_at DATE,
  
  -- 상태
  status VARCHAR(20) NOT NULL DEFAULT 'ALIVE',  -- 'ALIVE', 'DECEASED', 'REHOMED'
  deceased_date DATE,
  
  -- 이미지
  profile_image_url TEXT,
  
  -- 메모
  notes TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_animal_user_id ON animal(user_id);
CREATE INDEX idx_animal_species_id ON animal(species_id);
CREATE INDEX idx_animal_status ON animal(status);
CREATE INDEX idx_animal_father_id ON animal(father_id);
CREATE INDEX idx_animal_mother_id ON animal(mother_id);
CREATE INDEX idx_animal_created_at ON animal(created_at DESC);

-- Row Level Security
ALTER TABLE animal ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own animals"
  ON animal FOR ALL
  USING (auth.uid() = user_id);
```

**제약 조건:**
```sql
ALTER TABLE animal ADD CONSTRAINT chk_birth_month 
  CHECK (birth_month IS NULL OR (birth_month >= 1 AND birth_month <= 12));

ALTER TABLE animal ADD CONSTRAINT chk_birth_date 
  CHECK (birth_date IS NULL OR (birth_date >= 1 AND birth_date <= 31));

ALTER TABLE animal ADD CONSTRAINT chk_deceased_date 
  CHECK (status != 'DECEASED' OR deceased_date IS NOT NULL);
```

---

#### 3.2 measurement_log (측정 기록)

```sql
CREATE TABLE measurement_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id UUID NOT NULL REFERENCES animal(id) ON DELETE CASCADE,
  
  measured_date DATE NOT NULL,
  weight DECIMAL(10, 2),  -- g
  length DECIMAL(10, 2),  -- cm
  notes TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_measurement_animal_id ON measurement_log(animal_id);
CREATE INDEX idx_measurement_date ON measurement_log(measured_date DESC);

-- Row Level Security
ALTER TABLE measurement_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access measurements of their animals"
  ON measurement_log FOR ALL
  USING (
    animal_id IN (
      SELECT id FROM animal WHERE user_id = auth.uid()
    )
  );
```

**트리거: animal 테이블 자동 업데이트**
```sql
CREATE OR REPLACE FUNCTION update_animal_measurement()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE animal
  SET 
    current_weight = COALESCE(NEW.weight, current_weight),
    current_length = COALESCE(NEW.length, current_length),
    last_measured_at = NEW.measured_date,
    updated_at = NOW()
  WHERE id = NEW.animal_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_animal_measurement
  AFTER INSERT ON measurement_log
  FOR EACH ROW
  EXECUTE FUNCTION update_animal_measurement();
```

---

### 4. 사육 일지

#### 4.1 care_log (사육 일지)

```sql
CREATE TABLE care_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id UUID NOT NULL REFERENCES animal(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- 일지 유형
  log_type VARCHAR(20) NOT NULL,  -- 'FEEDING', 'SHEDDING', 'DEFECATION', 'MATING', 'EGG_LAYING', 'CANDLING', 'HATCHING'
  log_date TIMESTAMP NOT NULL,
  
  -- 연관 일지 (산란 → 검란 → 부화)
  parent_log_id UUID REFERENCES care_log(id) ON DELETE SET NULL,
  
  -- 유형별 상세 정보 (JSONB)
  details JSONB NOT NULL,
  
  -- 이미지 (최대 3개)
  images JSONB,  -- [{url: string, order: number, caption: string}]
  
  -- 공통 메모
  notes TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_care_log_animal_id ON care_log(animal_id);
CREATE INDEX idx_care_log_user_id ON care_log(user_id);
CREATE INDEX idx_care_log_type ON care_log(log_type);
CREATE INDEX idx_care_log_date ON care_log(log_date DESC);
CREATE INDEX idx_care_log_parent ON care_log(parent_log_id);
CREATE INDEX idx_care_log_details ON care_log USING GIN(details);

-- Row Level Security
ALTER TABLE care_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their care logs"
  ON care_log FOR ALL
  USING (auth.uid() = user_id);
```

---

## JSONB details 스키마

### FEEDING (먹이급여)

```typescript
{
  food_type: 'LIVE_INSECT' | 'FROZEN_PREY' | 'PELLET' | 'FRUIT' | 'VEGETABLE' | 'SUPPLEMENT' | 'OTHER',
  food_item: string,
  quantity: number,
  unit: 'EA' | 'G' | 'ML',
  supplements?: string[],
  feeding_response?: 'GOOD' | 'NORMAL' | 'POOR' | 'REFUSED',
  feeding_method?: 'HAND_FED' | 'TONGS' | 'BOWL' | 'FREE_ROAMING' | 'OTHER'
}
```

### SHEDDING (탈피)

```typescript
{
  shed_completion: 'COMPLETE' | 'PARTIAL' | 'STUCK' | 'IN_PROGRESS',
  problem_areas?: string[],  // ['꼬리', '발가락', '눈', '머리']
  assistance_needed?: boolean,
  assistance_method?: string,
  humidity_level?: number
}
```

### DEFECATION (배변)

```typescript
{
  feces_present: boolean,
  feces_consistency?: 'NORMAL' | 'SOFT' | 'HARD' | 'WATERY' | 'BLOODY' | 'MUCUS',
  feces_color?: string,
  urate_present: boolean,
  urate_condition?: 'NORMAL' | 'YELLOW' | 'ORANGE' | 'GREEN' | 'ABSENT',
  abnormalities?: string
}
```

### MATING (짝짓기)

```typescript
{
  partner_id?: string,  // animal.id
  partner_name?: string,
  mating_success: 'SUCCESSFUL' | 'ATTEMPTED' | 'REJECTED' | 'IN_PROGRESS',
  duration_minutes?: number,
  behavior_notes?: string,
  expected_laying_date?: string  // ISO date
}
```

### EGG_LAYING (산란)

```typescript
{
  egg_count: number,
  fertile_count?: number,
  infertile_count?: number,
  clutch_number?: number,
  incubation_planned: boolean,
  incubation_method?: 'NATURAL' | 'ARTIFICIAL' | 'NONE',
  incubation_temp?: number,  // °C
  incubation_humidity?: number,  // %
  expected_hatch_date?: string,  // ISO date
  mating_log_id?: string  // care_log.id
}
```

### CANDLING (검란)

```typescript
{
  day_after_laying: number,
  fertile_count: number,
  infertile_count: number,
  stopped_development: number,
  total_viable: number  // fertile - stopped
}
```

### HATCHING (부화)

```typescript
{
  hatched_count: number,
  failed_count: number,
  offspring_ids?: string[],  // animal.id[]
  hatch_notes?: string
}
```

---

## 인덱스 전략

### 복합 인덱스

```sql
-- 개체 목록 조회 최적화 (user + status + created_at)
CREATE INDEX idx_animal_user_status_created 
  ON animal(user_id, status, created_at DESC);

-- 일지 목록 조회 최적화 (animal + type + date)
CREATE INDEX idx_care_log_animal_type_date 
  ON care_log(animal_id, log_type, log_date DESC);

-- 측정 기록 조회 최적화 (animal + date)
CREATE INDEX idx_measurement_animal_date 
  ON measurement_log(animal_id, measured_date DESC);
```

### 전문 검색 (Full-Text Search)

```sql
-- 종 검색 최적화
CREATE INDEX idx_species_search 
  ON species USING GIN(
    to_tsvector('simple', 
      coalesce(scientific_name, '') || ' ' || 
      coalesce(common_name_kr, '') || ' ' || 
      coalesce(common_name_en, '')
    )
  );
```

---

## 데이터 무결성

### 제약 조건 요약

1. **외래 키**: CASCADE 또는 SET NULL
2. **NOT NULL**: 필수 필드 강제
3. **CHECK**: 값 범위 검증
4. **UNIQUE**: 중복 방지

### Row Level Security (RLS)

모든 사용자 데이터 테이블에 RLS 적용:
- `animal`
- `measurement_log`
- `care_log`

**정책**: 본인 데이터만 접근 가능

---

## 마이그레이션 전략

### TypeORM 마이그레이션

```typescript
// migrations/1234567890-InitialSchema.ts
export class InitialSchema1234567890 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // 테이블 생성 SQL
  }
  
  public async down(queryRunner: QueryRunner): Promise<void> {
    // 롤백 SQL
  }
}
```

### 실행 순서

1. 종 분류 테이블 (class → order → family → genus → species)
2. 코드 테이블 (country)
3. 개체 테이블 (animal)
4. 측정 테이블 (measurement_log)
5. 일지 테이블 (care_log)
6. 인덱스 및 제약 조건
7. RLS 정책
8. 트리거

---

## 초기 데이터 (Seed)

### 필수 데이터

```sql
-- 1. 강 (class)
INSERT INTO class ...

-- 2. 주요 목 (order)
INSERT INTO "order" ...

-- 3. 주요 과 (family)
INSERT INTO family ...

-- 4. 주요 속 (genus)
INSERT INTO genus ...

-- 5. 백색목록 종 (species) - 30-50개
INSERT INTO species ...

-- 6. 주요 국가 (country) - 50개
INSERT INTO country ...
```

### Seed 실행

```bash
npm run seed
```

---

## 백업 전략

### Supabase 자동 백업

- **매일 자동 백업**: Supabase Pro 플랜
- **Point-in-Time Recovery**: 7일 이내

### 수동 백업

```bash
# PostgreSQL dump
pg_dump -h db.xxx.supabase.co -U postgres -d postgres > backup.sql

# 복원
psql -h db.xxx.supabase.co -U postgres -d postgres < backup.sql
```

---

## 성능 고려사항

### 쿼리 최적화

1. **필요한 컬럼만 SELECT**
   ```sql
   SELECT id, name, profile_image_url FROM animal;
   ```

2. **페이지네이션 필수**
   ```sql
   SELECT * FROM care_log 
   ORDER BY log_date DESC 
   LIMIT 20 OFFSET 0;
   ```

3. **JOIN 최소화**
   - 필요할 때만 JOIN
   - N+1 쿼리 주의

### 캐싱 전략

- **animal.current_weight**: 최신 측정값 캐싱
- API 레벨 캐싱 (Redis 고려)

---

**문서 버전**: 1.0  
**최종 수정일**: 2024-02-16  
**작성자**: 비늘꼬리 & 게코
