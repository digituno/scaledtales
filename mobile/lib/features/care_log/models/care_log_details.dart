import '../../../core/enums/enums.dart';

// ── FEEDING ───────────────────────────────────────────────────────────────────

class FeedingDetails {
  final FoodType foodType;
  final String foodItem;
  final double? quantity;
  final Unit? unit;
  final List<String>? supplements;
  final FeedingResponse? feedingResponse;
  final FeedingMethod? feedingMethod;

  const FeedingDetails({
    required this.foodType,
    required this.foodItem,
    this.quantity,
    this.unit,
    this.supplements,
    this.feedingResponse,
    this.feedingMethod,
  });

  factory FeedingDetails.fromJson(Map<String, dynamic> json) => FeedingDetails(
        foodType: FoodType.fromValue(json['food_type'] as String),
        foodItem: json['food_item'] as String,
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] != null ? Unit.fromValue(json['unit'] as String) : null,
        supplements: (json['supplements'] as List?)?.map((e) => e as String).toList(),
        feedingResponse: json['feeding_response'] != null
            ? FeedingResponse.fromValue(json['feeding_response'] as String)
            : null,
        feedingMethod: json['feeding_method'] != null
            ? FeedingMethod.fromValue(json['feeding_method'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'food_type': foodType.value,
        'food_item': foodItem,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit!.value,
        if (supplements != null) 'supplements': supplements,
        if (feedingResponse != null) 'feeding_response': feedingResponse!.value,
        if (feedingMethod != null) 'feeding_method': feedingMethod!.value,
      };
}

// ── SHEDDING ──────────────────────────────────────────────────────────────────

class SheddingDetails {
  final ShedCompletion shedCompletion;
  final List<String>? problemAreas;
  final bool? assistanceNeeded;
  final String? assistanceMethod;
  final double? humidityLevel;

  const SheddingDetails({
    required this.shedCompletion,
    this.problemAreas,
    this.assistanceNeeded,
    this.assistanceMethod,
    this.humidityLevel,
  });

  factory SheddingDetails.fromJson(Map<String, dynamic> json) => SheddingDetails(
        shedCompletion: ShedCompletion.fromValue(json['shed_completion'] as String),
        problemAreas:
            (json['problem_areas'] as List?)?.map((e) => e as String).toList(),
        assistanceNeeded: json['assistance_needed'] as bool?,
        assistanceMethod: json['assistance_method'] as String?,
        humidityLevel: (json['humidity_level'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'shed_completion': shedCompletion.value,
        if (problemAreas != null) 'problem_areas': problemAreas,
        if (assistanceNeeded != null) 'assistance_needed': assistanceNeeded,
        if (assistanceMethod != null) 'assistance_method': assistanceMethod,
        if (humidityLevel != null) 'humidity_level': humidityLevel,
      };
}

// ── DEFECATION ────────────────────────────────────────────────────────────────

class DefecationDetails {
  final bool fecesPresent;
  final bool uratePresent;
  final FecesConsistency? fecesConsistency;
  final String? fecesColor;
  final UrateCondition? urateCondition;
  final String? abnormalities;

  const DefecationDetails({
    required this.fecesPresent,
    required this.uratePresent,
    this.fecesConsistency,
    this.fecesColor,
    this.urateCondition,
    this.abnormalities,
  });

  factory DefecationDetails.fromJson(Map<String, dynamic> json) =>
      DefecationDetails(
        fecesPresent: json['feces_present'] as bool,
        uratePresent: json['urate_present'] as bool,
        fecesConsistency: json['feces_consistency'] != null
            ? FecesConsistency.fromValue(json['feces_consistency'] as String)
            : null,
        fecesColor: json['feces_color'] as String?,
        urateCondition: json['urate_condition'] != null
            ? UrateCondition.fromValue(json['urate_condition'] as String)
            : null,
        abnormalities: json['abnormalities'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'feces_present': fecesPresent,
        'urate_present': uratePresent,
        if (fecesConsistency != null) 'feces_consistency': fecesConsistency!.value,
        if (fecesColor != null) 'feces_color': fecesColor,
        if (urateCondition != null) 'urate_condition': urateCondition!.value,
        if (abnormalities != null) 'abnormalities': abnormalities,
      };
}

// ── MATING ────────────────────────────────────────────────────────────────────

class MatingDetails {
  final MatingSuccess matingSuccess;
  final String? partnerId;
  final String? partnerName;
  final int? durationMinutes;
  final String? behaviorNotes;
  /// ISO 8601 date string (YYYY-MM-DD)
  final String? expectedLayingDate;

  const MatingDetails({
    required this.matingSuccess,
    this.partnerId,
    this.partnerName,
    this.durationMinutes,
    this.behaviorNotes,
    this.expectedLayingDate,
  });

  factory MatingDetails.fromJson(Map<String, dynamic> json) => MatingDetails(
        matingSuccess: MatingSuccess.fromValue(json['mating_success'] as String),
        partnerId: json['partner_id'] as String?,
        partnerName: json['partner_name'] as String?,
        durationMinutes: json['duration_minutes'] as int?,
        behaviorNotes: json['behavior_notes'] as String?,
        expectedLayingDate: json['expected_laying_date'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'mating_success': matingSuccess.value,
        if (partnerId != null) 'partner_id': partnerId,
        if (partnerName != null) 'partner_name': partnerName,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (behaviorNotes != null) 'behavior_notes': behaviorNotes,
        if (expectedLayingDate != null) 'expected_laying_date': expectedLayingDate,
      };
}

// ── EGG_LAYING ────────────────────────────────────────────────────────────────

class EggLayingDetails {
  final int eggCount;
  final bool incubationPlanned;
  final int? fertileCount;
  final int? infertileCount;
  final int? clutchNumber;
  final IncubationMethod? incubationMethod;
  final double? incubationTemp;
  final double? incubationHumidity;
  /// ISO 8601 date string (YYYY-MM-DD)
  final String? expectedHatchDate;

  const EggLayingDetails({
    required this.eggCount,
    required this.incubationPlanned,
    this.fertileCount,
    this.infertileCount,
    this.clutchNumber,
    this.incubationMethod,
    this.incubationTemp,
    this.incubationHumidity,
    this.expectedHatchDate,
  });

  factory EggLayingDetails.fromJson(Map<String, dynamic> json) => EggLayingDetails(
        eggCount: json['egg_count'] as int,
        incubationPlanned: json['incubation_planned'] as bool,
        fertileCount: json['fertile_count'] as int?,
        infertileCount: json['infertile_count'] as int?,
        clutchNumber: json['clutch_number'] as int?,
        incubationMethod: json['incubation_method'] != null
            ? IncubationMethod.fromValue(json['incubation_method'] as String)
            : null,
        incubationTemp: (json['incubation_temp'] as num?)?.toDouble(),
        incubationHumidity: (json['incubation_humidity'] as num?)?.toDouble(),
        expectedHatchDate: json['expected_hatch_date'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'egg_count': eggCount,
        'incubation_planned': incubationPlanned,
        if (fertileCount != null) 'fertile_count': fertileCount,
        if (infertileCount != null) 'infertile_count': infertileCount,
        if (clutchNumber != null) 'clutch_number': clutchNumber,
        if (incubationMethod != null) 'incubation_method': incubationMethod!.value,
        if (incubationTemp != null) 'incubation_temp': incubationTemp,
        if (incubationHumidity != null) 'incubation_humidity': incubationHumidity,
        if (expectedHatchDate != null) 'expected_hatch_date': expectedHatchDate,
      };
}

// ── CANDLING ──────────────────────────────────────────────────────────────────

class CandlingDetails {
  final int dayAfterLaying;
  final int fertileCount;
  final int infertileCount;
  final int stoppedDevelopment;
  final int totalViable;

  const CandlingDetails({
    required this.dayAfterLaying,
    required this.fertileCount,
    required this.infertileCount,
    required this.stoppedDevelopment,
    required this.totalViable,
  });

  factory CandlingDetails.fromJson(Map<String, dynamic> json) => CandlingDetails(
        dayAfterLaying: json['day_after_laying'] as int,
        fertileCount: json['fertile_count'] as int,
        infertileCount: json['infertile_count'] as int,
        stoppedDevelopment: json['stopped_development'] as int,
        totalViable: json['total_viable'] as int,
      );

  Map<String, dynamic> toJson() => {
        'day_after_laying': dayAfterLaying,
        'fertile_count': fertileCount,
        'infertile_count': infertileCount,
        'stopped_development': stoppedDevelopment,
        'total_viable': totalViable,
      };
}

// ── HATCHING ──────────────────────────────────────────────────────────────────

class HatchingDetails {
  final int hatchedCount;
  final int failedCount;
  final List<String>? offspringIds;
  final String? hatchNotes;

  const HatchingDetails({
    required this.hatchedCount,
    required this.failedCount,
    this.offspringIds,
    this.hatchNotes,
  });

  factory HatchingDetails.fromJson(Map<String, dynamic> json) => HatchingDetails(
        hatchedCount: json['hatched_count'] as int,
        failedCount: json['failed_count'] as int,
        offspringIds:
            (json['offspring_ids'] as List?)?.map((e) => e as String).toList(),
        hatchNotes: json['hatch_notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'hatched_count': hatchedCount,
        'failed_count': failedCount,
        if (offspringIds != null) 'offspring_ids': offspringIds,
        if (hatchNotes != null) 'hatch_notes': hatchNotes,
      };
}
