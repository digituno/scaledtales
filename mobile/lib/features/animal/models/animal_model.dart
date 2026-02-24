class AnimalSummary {
  final String id;
  final String name;
  final AnimalSpeciesInfo species;
  final String? morph;
  final String sex;
  final String? profileImageUrl;
  final double? currentWeight;
  final double? currentLength;
  final String status;
  final String createdAt;

  const AnimalSummary({
    required this.id,
    required this.name,
    required this.species,
    this.morph,
    required this.sex,
    this.profileImageUrl,
    this.currentWeight,
    this.currentLength,
    required this.status,
    required this.createdAt,
  });

  factory AnimalSummary.fromJson(Map<String, dynamic> json) {
    return AnimalSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      species: AnimalSpeciesInfo.fromJson(json['species']),
      morph: json['morph'] as String?,
      sex: json['sex'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      currentWeight: _toDouble(json['current_weight']),
      currentLength: _toDouble(json['current_length']),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

class AnimalDetail {
  final String id;
  final String userId;
  final AnimalSpeciesInfo species;
  final String name;
  final String? morph;
  final String sex;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDate;
  final String originType;
  final String? originCountry;
  final String acquisitionDate;
  final String acquisitionSource;
  final String? acquisitionNote;
  final AnimalParentInfo? father;
  final AnimalParentInfo? mother;
  final double? currentWeight;
  final double? currentLength;
  final String? lastMeasuredAt;
  final String status;
  final String? deceasedDate;
  final String? profileImageUrl;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const AnimalDetail({
    required this.id,
    required this.userId,
    required this.species,
    required this.name,
    this.morph,
    required this.sex,
    this.birthYear,
    this.birthMonth,
    this.birthDate,
    required this.originType,
    this.originCountry,
    required this.acquisitionDate,
    required this.acquisitionSource,
    this.acquisitionNote,
    this.father,
    this.mother,
    this.currentWeight,
    this.currentLength,
    this.lastMeasuredAt,
    required this.status,
    this.deceasedDate,
    this.profileImageUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnimalDetail.fromJson(Map<String, dynamic> json) {
    return AnimalDetail(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      species: AnimalSpeciesInfo.fromJson(json['species']),
      name: json['name'] as String,
      morph: json['morph'] as String?,
      sex: json['sex'] as String,
      birthYear: json['birth_year'] as int?,
      birthMonth: json['birth_month'] as int?,
      birthDate: json['birth_date'] as int?,
      originType: json['origin_type'] as String,
      originCountry: json['origin_country'] as String?,
      acquisitionDate: json['acquisition_date'] as String,
      acquisitionSource: json['acquisition_source'] as String,
      acquisitionNote: json['acquisition_note'] as String?,
      father: json['father'] != null
          ? AnimalParentInfo.fromJson(json['father'])
          : null,
      mother: json['mother'] != null
          ? AnimalParentInfo.fromJson(json['mother'])
          : null,
      currentWeight: _toDouble(json['current_weight']),
      currentLength: _toDouble(json['current_length']),
      lastMeasuredAt: json['last_measured_at'] as String?,
      status: json['status'] as String,
      deceasedDate: json['deceased_date'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  String get birthDisplay {
    if (birthYear == null) return '-';
    final parts = <String>['$birthYear년'];
    if (birthMonth != null) parts.add('$birthMonth월');
    if (birthDate != null) parts.add('$birthDate일');
    return parts.join(' ');
  }
}

class AnimalSpeciesInfo {
  final String id;
  final String scientificName;
  final String? commonNameKr;
  final String? commonNameEn;

  const AnimalSpeciesInfo({
    required this.id,
    required this.scientificName,
    this.commonNameKr,
    this.commonNameEn,
  });

  factory AnimalSpeciesInfo.fromJson(Map<String, dynamic> json) {
    return AnimalSpeciesInfo(
      id: json['id'] as String,
      scientificName: json['scientific_name'] as String,
      commonNameKr: json['common_name_kr'] as String?,
      commonNameEn: json['common_name_en'] as String?,
    );
  }

  String get displayName => commonNameKr ?? scientificName;
}

class AnimalParentInfo {
  final String id;
  final String name;
  final String? profileImageUrl;

  const AnimalParentInfo({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });

  factory AnimalParentInfo.fromJson(Map<String, dynamic> json) {
    return AnimalParentInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }
}

class AnimalListResponse {
  final List<AnimalSummary> data;
  final PaginationInfo pagination;

  const AnimalListResponse({required this.data, required this.pagination});

  factory AnimalListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List;
    return AnimalListResponse(
      data: list.map((e) => AnimalSummary.fromJson(e)).toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
