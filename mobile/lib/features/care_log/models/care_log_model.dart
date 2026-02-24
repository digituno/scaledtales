import 'care_log_details.dart';

class CareLogImage {
  final String url;
  final int order;
  final String? caption;

  const CareLogImage({
    required this.url,
    required this.order,
    this.caption,
  });

  factory CareLogImage.fromJson(Map<String, dynamic> json) {
    return CareLogImage(
      url: json['url'] as String,
      order: json['order'] as int,
      caption: json['caption'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'order': order,
        if (caption != null) 'caption': caption,
      };
}

class CareLog {
  final String id;
  final String animalId;
  final String? userId;
  final String logType;
  final String logDate;
  final Map<String, dynamic> details;
  final List<CareLogImage>? images;
  final String? notes;
  final String? parentLogId;
  final String createdAt;
  final String updatedAt;
  // animal relation (available when fetched via findAllForUser)
  final Map<String, dynamic>? animal;

  const CareLog({
    required this.id,
    required this.animalId,
    this.userId,
    required this.logType,
    required this.logDate,
    required this.details,
    this.images,
    this.notes,
    this.parentLogId,
    required this.createdAt,
    required this.updatedAt,
    this.animal,
  });

  String get animalName => animal?['name'] as String? ?? '';

  // ── Typed details getters (UI 레이어에서 타입 안전하게 접근) ──

  FeedingDetails? get feedingDetails =>
      logType == 'FEEDING' ? FeedingDetails.fromJson(details) : null;

  SheddingDetails? get sheddingDetails =>
      logType == 'SHEDDING' ? SheddingDetails.fromJson(details) : null;

  DefecationDetails? get defecationDetails =>
      logType == 'DEFECATION' ? DefecationDetails.fromJson(details) : null;

  MatingDetails? get matingDetails =>
      logType == 'MATING' ? MatingDetails.fromJson(details) : null;

  EggLayingDetails? get eggLayingDetails =>
      logType == 'EGG_LAYING' ? EggLayingDetails.fromJson(details) : null;

  CandlingDetails? get candlingDetails =>
      logType == 'CANDLING' ? CandlingDetails.fromJson(details) : null;

  HatchingDetails? get hatchingDetails =>
      logType == 'HATCHING' ? HatchingDetails.fromJson(details) : null;

  factory CareLog.fromJson(Map<String, dynamic> json) {
    return CareLog(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      userId: json['user_id'] as String?,
      logType: json['log_type'] as String,
      logDate: json['log_date'] as String,
      details: Map<String, dynamic>.from(json['details'] as Map),
      images: (json['images'] as List?)
          ?.map((e) => CareLogImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      parentLogId: json['parent_log_id'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      animal: json['animal'] != null
          ? Map<String, dynamic>.from(json['animal'] as Map)
          : null,
    );
  }
}
