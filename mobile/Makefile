# ScaledTales Flutter 빌드 헬퍼
# 환경별 API_BASE_URL을 dart-define으로 주입한다.
#
# 사용:
#   make run-dev             # 개발 서버로 앱 실행
#   make build-ios-prod      # 프로덕션 iOS 릴리스 빌드
#   make build-android-prod  # 프로덕션 Android 릴리스 빌드
#   make analyze             # dart 정적 분석
#   make test                # 위젯 테스트 실행

API_DEV  = http://localhost:3000/v1
API_PROD = https://api.scaledtales.com/v1

# ── 실행 ────────────────────────────────────────────────────────────────────

run-dev:
	flutter run \
		--dart-define=API_BASE_URL=$(API_DEV)

run-prod:
	flutter run \
		--dart-define=API_BASE_URL=$(API_PROD)

# ── iOS 빌드 ─────────────────────────────────────────────────────────────────

build-ios-dev:
	flutter build ios \
		--dart-define=API_BASE_URL=$(API_DEV)

build-ios-prod:
	flutter build ios --release \
		--dart-define=API_BASE_URL=$(API_PROD)

# ── Android 빌드 ──────────────────────────────────────────────────────────────

build-android-dev:
	flutter build apk \
		--dart-define=API_BASE_URL=$(API_DEV)

build-android-prod:
	flutter build apk --release \
		--dart-define=API_BASE_URL=$(API_PROD)

# ── 품질 검사 ────────────────────────────────────────────────────────────────

analyze:
	dart analyze

test:
	flutter test

.PHONY: run-dev run-prod \
        build-ios-dev build-ios-prod \
        build-android-dev build-android-prod \
        analyze test
