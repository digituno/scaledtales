class ApiConstants {
  /// 빌드 시 --dart-define=API_BASE_URL=https://your-api.com/v1 로 주입 가능.
  /// 미설정 시 개발 서버(localhost:3000) 사용.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1',
  );

  // Auth
  static const String authMe = '/auth/me';

  // Species
  static const String speciesClasses = '/species/classes';
  static const String speciesSearch = '/species/search';
  static String speciesDetail(String id) => '/species/$id';
  static String speciesOrders(String classId) =>
      '/species/classes/$classId/orders';
  static String speciesFamilies(String orderId) =>
      '/species/orders/$orderId/families';
  static String speciesGenera(String familyId) =>
      '/species/families/$familyId/genera';
  static String speciesSpecies(String genusId) =>
      '/species/genera/$genusId/species';

  // Countries
  static const String countries = '/countries';

  // Animals
  static const String animals = '/animals';
  static String animalDetail(String id) => '/animals/$id';

  // Measurements
  static String measurements(String animalId) =>
      '/animals/$animalId/measurements';
  static String measurementDetail(String id) => '/measurements/$id';

  // Care Logs
  static const String allCareLogs = '/care-logs';
  static String careLogs(String animalId) => '/animals/$animalId/care-logs';
  static String careLogDetail(String logId) => '/care-logs/$logId';

  // Upload
  static const String uploadProfile = '/upload/profile';
  static const String uploadCareLog = '/upload/care-log';
}
