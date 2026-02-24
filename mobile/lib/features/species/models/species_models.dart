class TaxonomyClass {
  final String id;
  final String nameKr;
  final String nameEn;
  final String code;

  const TaxonomyClass({
    required this.id,
    required this.nameKr,
    required this.nameEn,
    required this.code,
  });

  factory TaxonomyClass.fromJson(Map<String, dynamic> json) {
    return TaxonomyClass(
      id: json['id'] as String,
      nameKr: json['name_kr'] as String,
      nameEn: json['name_en'] as String,
      code: json['code'] as String,
    );
  }
}

class TaxonomyOrder {
  final String id;
  final String classId;
  final String nameKr;
  final String nameEn;

  const TaxonomyOrder({
    required this.id,
    required this.classId,
    required this.nameKr,
    required this.nameEn,
  });

  factory TaxonomyOrder.fromJson(Map<String, dynamic> json) {
    return TaxonomyOrder(
      id: json['id'] as String,
      classId: json['class_id'] ?? json['classId'] ?? '',
      nameKr: json['name_kr'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}

class TaxonomyFamily {
  final String id;
  final String orderId;
  final String nameKr;
  final String nameEn;

  const TaxonomyFamily({
    required this.id,
    required this.orderId,
    required this.nameKr,
    required this.nameEn,
  });

  factory TaxonomyFamily.fromJson(Map<String, dynamic> json) {
    return TaxonomyFamily(
      id: json['id'] as String,
      orderId: json['order_id'] ?? json['orderId'] ?? '',
      nameKr: json['name_kr'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}

class TaxonomyGenus {
  final String id;
  final String familyId;
  final String nameKr;
  final String nameEn;

  const TaxonomyGenus({
    required this.id,
    required this.familyId,
    required this.nameKr,
    required this.nameEn,
  });

  factory TaxonomyGenus.fromJson(Map<String, dynamic> json) {
    return TaxonomyGenus(
      id: json['id'] as String,
      familyId: json['family_id'] ?? json['familyId'] ?? '',
      nameKr: json['name_kr'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}

class SpeciesSummary {
  final String id;
  final String scientificName;
  final String? commonNameKr;
  final String? commonNameEn;
  final String speciesKr;
  final String? speciesEn;
  final String? classCode;
  final bool isCites;
  final String? citesLevel;
  final bool isWhitelist;

  const SpeciesSummary({
    required this.id,
    required this.scientificName,
    this.commonNameKr,
    this.commonNameEn,
    required this.speciesKr,
    this.speciesEn,
    this.classCode,
    this.isCites = false,
    this.citesLevel,
    this.isWhitelist = false,
  });

  factory SpeciesSummary.fromJson(Map<String, dynamic> json) {
    return SpeciesSummary(
      id: json['id'] as String,
      scientificName: json['scientific_name'] as String,
      commonNameKr: json['common_name_kr'] as String?,
      commonNameEn: json['common_name_en'] as String?,
      speciesKr: json['species_kr'] as String,
      speciesEn: json['species_en'] as String?,
      classCode: json['class_code'] as String?,
      isCites: json['is_cites'] as bool? ?? false,
      citesLevel: json['cites_level'] as String?,
      isWhitelist: json['is_whitelist'] as bool? ?? false,
    );
  }

  String get displayName => commonNameKr ?? speciesKr;
}

class SpeciesDetail {
  final String id;
  final TaxonomyInfo taxonomyClass;
  final TaxonomyInfo order;
  final TaxonomyInfo family;
  final TaxonomyInfo genus;
  final String speciesKr;
  final String speciesEn;
  final String scientificName;
  final String? commonNameKr;
  final String? commonNameEn;
  final bool isCites;
  final String? citesLevel;
  final bool isWhitelist;

  const SpeciesDetail({
    required this.id,
    required this.taxonomyClass,
    required this.order,
    required this.family,
    required this.genus,
    required this.speciesKr,
    required this.speciesEn,
    required this.scientificName,
    this.commonNameKr,
    this.commonNameEn,
    this.isCites = false,
    this.citesLevel,
    this.isWhitelist = false,
  });

  factory SpeciesDetail.fromJson(Map<String, dynamic> json) {
    return SpeciesDetail(
      id: json['id'] as String,
      taxonomyClass: TaxonomyInfo.fromJson(json['class']),
      order: TaxonomyInfo.fromJson(json['order']),
      family: TaxonomyInfo.fromJson(json['family']),
      genus: TaxonomyInfo.fromJson(json['genus']),
      speciesKr: json['species_kr'] as String,
      speciesEn: json['species_en'] as String,
      scientificName: json['scientific_name'] as String,
      commonNameKr: json['common_name_kr'] as String?,
      commonNameEn: json['common_name_en'] as String?,
      isCites: json['is_cites'] as bool? ?? false,
      citesLevel: json['cites_level'] as String?,
      isWhitelist: json['is_whitelist'] as bool? ?? false,
    );
  }

  String get displayName => commonNameKr ?? speciesKr;

  String get taxonomyPath =>
      '${taxonomyClass.nameKr} > ${order.nameKr} > ${family.nameKr} > ${genus.nameKr}';
}

class TaxonomyInfo {
  final String id;
  final String nameKr;
  final String nameEn;
  final String? code;

  const TaxonomyInfo({
    required this.id,
    required this.nameKr,
    required this.nameEn,
    this.code,
  });

  factory TaxonomyInfo.fromJson(Map<String, dynamic> json) {
    return TaxonomyInfo(
      id: json['id'] as String,
      nameKr: json['name_kr'] as String,
      nameEn: json['name_en'] as String,
      code: json['code'] as String?,
    );
  }
}
