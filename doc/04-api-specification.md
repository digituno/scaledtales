# API 명세서

## 개요

ScaledTales REST API는 RESTful 원칙을 따르며, JSON 형식으로 데이터를 주고받습니다.

**Base URL**: `https://api.scaledtales.com/v1`

**인증 방식**: Bearer Token (JWT)

**Content-Type**: `application/json`

---

## 공통 사항

### 인증 헤더

```http
Authorization: Bearer {access_token}
```

모든 보호된 엔드포인트는 Supabase JWT 토큰이 필요합니다.

### 응답 형식

#### 성공 응답

```json
{
  "success": true,
  "data": {
    // 응답 데이터
  }
}
```

#### 에러 응답

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": {}  // 선택사항
  }
}
```

#### 페이지네이션 응답

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### HTTP 상태 코드

- `200 OK`: 성공
- `201 Created`: 리소스 생성 성공
- `400 Bad Request`: 잘못된 요청
- `401 Unauthorized`: 인증 실패
- `403 Forbidden`: 권한 없음
- `404 Not Found`: 리소스 없음
- `422 Unprocessable Entity`: 유효성 검사 실패
- `500 Internal Server Error`: 서버 오류

### 에러 코드

| 코드 | 설명 |
|------|------|
| `INVALID_INPUT` | 잘못된 입력값 |
| `UNAUTHORIZED` | 인증되지 않음 |
| `FORBIDDEN` | 권한 없음 |
| `NOT_FOUND` | 리소스 없음 |
| `VALIDATION_ERROR` | 유효성 검사 실패 |
| `DUPLICATE` | 중복 데이터 |
| `SERVER_ERROR` | 서버 오류 |

---

## 1. 인증 (Authentication)

Supabase Auth가 처리하므로 별도 엔드포인트 없음.

### 1.1 현재 사용자 조회

```http
GET /auth/me
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

---

## 2. 종 분류 (Species)

### 2.1 강 목록 조회

```http
GET /species/classes
```

**Query Parameters:**
- `lang`: `ko` | `en` (optional, default: `ko`)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "code": "REPTILE",
      "name_kr": "파충강",
      "name_en": "Reptilia"
    },
    {
      "id": "uuid",
      "code": "AMPHIBIAN",
      "name_kr": "양서강",
      "name_en": "Amphibia"
    }
  ]
}
```

### 2.2 목 목록 조회

```http
GET /species/classes/{classId}/orders
```

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "class_id": "uuid",
      "name_kr": "뱀목",
      "name_en": "Squamata"
    }
  ]
}
```

### 2.3 과 목록 조회

```http
GET /species/orders/{orderId}/families
```

### 2.4 속 목록 조회

```http
GET /species/families/{familyId}/genera
```

### 2.5 종 목록 조회

```http
GET /species/genera/{genusId}/species
```

### 2.6 종 검색

```http
GET /species/search
```

**Query Parameters:**
- `q`: 검색어 (required)
- `lang`: `ko` | `en` (optional, default: `ko`)
- `class_code`: `REPTILE` | `AMPHIBIAN` (optional)
- `limit`: number (optional, default: 20, max: 100)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "scientific_name": "Eublepharis macularius",
      "common_name_kr": "레오파드게코",
      "common_name_en": "Leopard Gecko",
      "class_code": "REPTILE",
      "is_cites": false,
      "cites_level": null,
      "is_whitelist": true
    }
  ]
}
```

### 2.7 종 상세 조회

```http
GET /species/{speciesId}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "class": {
      "id": "uuid",
      "name_kr": "파충강",
      "name_en": "Reptilia",
      "code": "REPTILE"
    },
    "order": {
      "id": "uuid",
      "name_kr": "뱀목",
      "name_en": "Squamata"
    },
    "family": {
      "id": "uuid",
      "name_kr": "게코과",
      "name_en": "Gekkonidae"
    },
    "genus": {
      "id": "uuid",
      "name_kr": "표범게코속",
      "name_en": "Eublepharis"
    },
    "species_kr": "표범게코",
    "species_en": "macularius",
    "scientific_name": "Eublepharis macularius",
    "common_name_kr": "레오파드게코",
    "common_name_en": "Leopard Gecko",
    "is_cites": false,
    "cites_level": null,
    "is_whitelist": true
  }
}
```

---

## 3. 국가 (Countries)

### 3.1 국가 목록 조회

```http
GET /countries
```

**Query Parameters:**
- `lang`: `ko` | `en` (optional, default: `ko`)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "code": "KR",
      "name": "대한민국"
    },
    {
      "code": "US",
      "name": "미국"
    }
  ]
}
```

---

## 4. 개체 관리 (Animals)

### 4.1 개체 목록 조회

```http
GET /animals
```

**Query Parameters:**
- `status`: `ALIVE` | `DECEASED` | `REHOMED` (optional)
- `species_id`: UUID (optional)
- `page`: number (optional, default: 1)
- `limit`: number (optional, default: 20, max: 100)
- `sort`: `name` | `created_at` | `acquisition_date` (optional, default: `created_at`)
- `order`: `asc` | `desc` (optional, default: `desc`)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "레오",
      "species": {
        "id": "uuid",
        "scientific_name": "Eublepharis macularius",
        "common_name_kr": "레오파드게코",
        "common_name_en": "Leopard Gecko"
      },
      "morph": "하이옐로우",
      "sex": "MALE",
      "profile_image_url": "https://...",
      "current_weight": 45.5,
      "current_length": 18.2,
      "status": "ALIVE",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "totalPages": 1
  }
}
```

### 4.2 개체 상세 조회

```http
GET /animals/{animalId}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "species": {
      "id": "uuid",
      "scientific_name": "Eublepharis macularius",
      "common_name_kr": "레오파드게코",
      "common_name_en": "Leopard Gecko",
      "class_code": "REPTILE"
    },
    "name": "레오",
    "morph": "하이옐로우",
    "sex": "MALE",
    "birth_year": 2022,
    "birth_month": 3,
    "birth_date": null,
    "origin_type": "CB",
    "origin_country": "KR",
    "acquisition_date": "2022-06-15",
    "acquisition_source": "BREEDER",
    "acquisition_note": "OOO 브리더",
    "father": null,
    "mother": null,
    "current_weight": 45.5,
    "current_length": 18.2,
    "last_measured_at": "2024-02-10",
    "status": "ALIVE",
    "deceased_date": null,
    "profile_image_url": "https://...",
    "notes": "건강함",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-02-10T00:00:00Z"
  }
}
```

### 4.3 개체 등록

```http
POST /animals
```

**Request Body:**
```json
{
  "species_id": "uuid",
  "name": "레오",
  "morph": "하이옐로우",
  "sex": "MALE",
  "birth_year": 2022,
  "birth_month": 3,
  "birth_date": null,
  "origin_type": "CB",
  "origin_country": "KR",
  "acquisition_date": "2022-06-15",
  "acquisition_source": "BREEDER",
  "acquisition_note": "OOO 브리더",
  "father_id": null,
  "mother_id": null,
  "current_weight": 45.5,
  "current_length": 18.2,
  "status": "ALIVE",
  "profile_image_url": "https://...",
  "notes": "건강함"
}
```

**필수 필드:**
- `species_id`
- `name`
- `sex`
- `origin_type`
- `acquisition_date`
- `acquisition_source`

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    // ... 전체 개체 정보
  }
}
```

### 4.4 개체 수정

```http
PATCH /animals/{animalId}
```

**Request Body:** (수정할 필드만 포함)
```json
{
  "name": "레오2",
  "current_weight": 46.0
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    // ... 수정된 개체 정보
  }
}
```

### 4.5 개체 삭제

```http
DELETE /animals/{animalId}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "deleted": true
  }
}
```

---

## 5. 측정 기록 (Measurements)

### 5.1 측정 기록 목록

```http
GET /animals/{animalId}/measurements
```

**Query Parameters:**
- `from_date`: ISO date (optional)
- `to_date`: ISO date (optional)
- `page`: number (optional, default: 1)
- `limit`: number (optional, default: 20)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "animal_id": "uuid",
      "measured_date": "2024-02-10",
      "weight": 45.5,
      "length": 18.2,
      "notes": "건강함",
      "created_at": "2024-02-10T14:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 10,
    "totalPages": 1
  }
}
```

### 5.2 측정 기록 등록

```http
POST /animals/{animalId}/measurements
```

**Request Body:**
```json
{
  "measured_date": "2024-02-10",
  "weight": 45.5,
  "length": 18.2,
  "notes": "건강함"
}
```

**필수 필드:**
- `measured_date`

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "animal_id": "uuid",
    "measured_date": "2024-02-10",
    "weight": 45.5,
    "length": 18.2,
    "notes": "건강함",
    "created_at": "2024-02-10T14:00:00Z"
  }
}
```

**Side Effect:**
- `animal` 테이블의 `current_weight`, `current_length`, `last_measured_at` 자동 업데이트

### 5.3 측정 기록 수정

```http
PATCH /measurements/{measurementId}
```

### 5.4 측정 기록 삭제

```http
DELETE /measurements/{measurementId}
```

---

## 6. 사육 일지 (Care Logs)

### 6.1 일지 목록 조회

```http
GET /animals/{animalId}/care-logs
```

**Query Parameters:**
- `log_type`: comma-separated (optional, 예: `FEEDING,SHEDDING`)
- `from_date`: ISO datetime (optional)
- `to_date`: ISO datetime (optional)
- `page`: number (optional, default: 1)
- `limit`: number (optional, default: 20)
- `sort`: `log_date` (optional, default: `log_date`)
- `order`: `asc` | `desc` (optional, default: `desc`)

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "animal_id": "uuid",
      "log_type": "FEEDING",
      "log_date": "2024-02-12T19:30:00Z",
      "details": {
        "food_type": "LIVE_INSECT",
        "food_item": "귀뚜라미",
        "quantity": 5,
        "unit": "EA",
        "supplements": ["칼슘파우더"],
        "feeding_response": "GOOD",
        "feeding_method": "TONGS"
      },
      "images": [
        {
          "url": "https://...",
          "order": 1,
          "caption": null
        }
      ],
      "notes": "잘 먹음",
      "parent_log_id": null,
      "created_at": "2024-02-12T19:30:00Z",
      "updated_at": "2024-02-12T19:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "totalPages": 3
  }
}
```

### 6.2 일지 상세 조회

```http
GET /care-logs/{logId}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "animal": {
      "id": "uuid",
      "name": "레오",
      "profile_image_url": "https://..."
    },
    "log_type": "FEEDING",
    "log_date": "2024-02-12T19:30:00Z",
    "details": {...},
    "images": [...],
    "notes": "잘 먹음",
    "parent_log_id": null,
    "parent_log": null,
    "created_at": "2024-02-12T19:30:00Z",
    "updated_at": "2024-02-12T19:30:00Z"
  }
}
```

### 6.3 일지 등록

```http
POST /animals/{animalId}/care-logs
```

**Request Body (FEEDING 예시):**
```json
{
  "log_type": "FEEDING",
  "log_date": "2024-02-12T19:30:00Z",
  "details": {
    "food_type": "LIVE_INSECT",
    "food_item": "귀뚜라미",
    "quantity": 5,
    "unit": "EA",
    "supplements": ["칼슘파우더"],
    "feeding_response": "GOOD",
    "feeding_method": "TONGS"
  },
  "images": [
    {
      "url": "https://...",
      "order": 1,
      "caption": null
    }
  ],
  "notes": "잘 먹음"
}
```

**Request Body (CANDLING 예시):**
```json
{
  "log_type": "CANDLING",
  "log_date": "2024-02-15T14:00:00Z",
  "parent_log_id": "uuid-of-egg-laying-log",
  "details": {
    "day_after_laying": 14,
    "fertile_count": 2,
    "infertile_count": 0,
    "stopped_development": 0,
    "total_viable": 2
  },
  "notes": "모두 정상 발육 중"
}
```

**필수 필드:**
- `log_type`
- `log_date`
- `details`

**Response 201:**
```json
{
  "success": true,
  "data": {
    // ... 전체 일지 정보
  }
}
```

### 6.4 일지 수정

```http
PATCH /care-logs/{logId}
```

### 6.5 일지 삭제

```http
DELETE /care-logs/{logId}
```

---

## 7. 이미지 업로드 (Image Upload)

### 7.1 프로필 이미지 업로드

```http
POST /upload/profile
```

**Content-Type:** `multipart/form-data`

**Form Data:**
- `file`: File (required)
- `animal_id`: UUID (required)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "url": "https://xxx.supabase.co/storage/v1/object/public/..."
  }
}
```

### 7.2 일지 이미지 업로드

```http
POST /upload/care-log
```

**Content-Type:** `multipart/form-data`

**Form Data:**
- `files`: File[] (required, 최대 3개)
- `log_id`: UUID (optional, 일지 생성 전이면 생략)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "urls": [
      "https://...",
      "https://...",
      "https://..."
    ]
  }
}
```

---

## 8. 통계 (Statistics) - v2

### 8.1 개체별 통계

```http
GET /animals/{animalId}/stats
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "total_logs": 50,
    "last_feeding_date": "2024-02-12",
    "last_shedding_date": "2024-02-05",
    "feeding_count_last_30days": 15,
    "weight_change_last_30days": 2.5,
    "growth_rate": 0.5
  }
}
```

### 8.2 사용자 전체 통계

```http
GET /users/me/stats
```

---

## API 사용 예시

### 예시 1: 개체 등록 플로우

```javascript
// 1. 종 검색
const searchResponse = await fetch('/species/search?q=레오파드&lang=ko');
const species = await searchResponse.json();

// 2. 개체 등록
const createResponse = await fetch('/animals', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    species_id: species.data[0].id,
    name: '레오',
    sex: 'MALE',
    // ...
  })
});

// 3. 프로필 이미지 업로드
const formData = new FormData();
formData.append('file', imageFile);
formData.append('animal_id', animal.id);

const uploadResponse = await fetch('/upload/profile', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});
```

### 예시 2: 일지 작성 플로우

```javascript
// 1. 일지 이미지 업로드 (선택)
const formData = new FormData();
formData.append('files', image1);
formData.append('files', image2);

const uploadResponse = await fetch('/upload/care-log', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` },
  body: formData
});
const { urls } = await uploadResponse.json();

// 2. 일지 작성
const logResponse = await fetch(`/animals/${animalId}/care-logs`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    log_type: 'FEEDING',
    log_date: new Date().toISOString(),
    details: {
      food_type: 'LIVE_INSECT',
      food_item: '귀뚜라미',
      quantity: 5,
      unit: 'EA'
    },
    images: urls.map((url, i) => ({ url, order: i + 1 })),
    notes: '잘 먹음'
  })
});
```

---

## Rate Limiting

- **인증 엔드포인트**: 10 requests/분
- **일반 엔드포인트**: 100 requests/분
- **이미지 업로드**: 20 requests/분

**초과 시:**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "retry_after": 60
  }
}
```

---

## 버전 관리

**현재 버전**: v1

**향후 변경 시**: `/v2/...` 형태로 새 버전 제공

---

**문서 버전**: 1.0  
**최종 수정일**: 2024-02-16  
**작성자**: 비늘꼬리 & 게코
