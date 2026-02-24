import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../enums/enums.dart';

/// Enum → 사용자 표시 레이블 변환 유틸리티.
///
/// 모든 enum 타입의 레이블 함수를 한 곳에 모아 중복 정의를 방지한다.
/// 각 함수는 AppLocalizations를 받아 현재 locale에 맞는 문자열을 반환한다.

String logTypeLabel(LogType type, AppLocalizations l10n) {
  return switch (type) {
    LogType.feeding => l10n.logTypeFeeding,
    LogType.shedding => l10n.logTypeShedding,
    LogType.defecation => l10n.logTypeDefecation,
    LogType.mating => l10n.logTypeMating,
    LogType.eggLaying => l10n.logTypeEggLaying,
    LogType.candling => l10n.logTypeCandling,
    LogType.hatching => l10n.logTypeHatching,
  };
}

String foodTypeLabel(FoodType type, AppLocalizations l10n) {
  return switch (type) {
    FoodType.liveInsect => l10n.foodTypeLiveInsect,
    FoodType.frozenPrey => l10n.foodTypeFrozenPrey,
    FoodType.pellet => l10n.foodTypePellet,
    FoodType.fruit => l10n.foodTypeFruit,
    FoodType.vegetable => l10n.foodTypeVegetable,
    FoodType.supplement => l10n.foodTypeSupplement,
    FoodType.other => l10n.foodTypeOther,
  };
}

String unitLabel(Unit unit, AppLocalizations l10n) {
  return switch (unit) {
    Unit.ea => l10n.unitEa,
    Unit.g => l10n.unitG,
    Unit.ml => l10n.unitMl,
  };
}

String feedingResponseLabel(FeedingResponse resp, AppLocalizations l10n) {
  return switch (resp) {
    FeedingResponse.good => l10n.feedingResponseGood,
    FeedingResponse.normal => l10n.feedingResponseNormal,
    FeedingResponse.poor => l10n.feedingResponsePoor,
    FeedingResponse.refused => l10n.feedingResponseRefused,
  };
}

String feedingMethodLabel(FeedingMethod method, AppLocalizations l10n) {
  return switch (method) {
    FeedingMethod.handFed => l10n.feedingMethodHandFed,
    FeedingMethod.tongs => l10n.feedingMethodTongs,
    FeedingMethod.bowl => l10n.feedingMethodBowl,
    FeedingMethod.freeRoaming => l10n.feedingMethodFreeRoaming,
    FeedingMethod.other => l10n.feedingMethodOther,
  };
}

String shedCompletionLabel(ShedCompletion sc, AppLocalizations l10n) {
  return switch (sc) {
    ShedCompletion.complete => l10n.shedCompletionComplete,
    ShedCompletion.partial => l10n.shedCompletionPartial,
    ShedCompletion.stuck => l10n.shedCompletionStuck,
    ShedCompletion.inProgress => l10n.shedCompletionInProgress,
  };
}

String fecesConsistencyLabel(FecesConsistency fc, AppLocalizations l10n) {
  return switch (fc) {
    FecesConsistency.normal => l10n.fecesConsistencyNormal,
    FecesConsistency.soft => l10n.fecesConsistencySoft,
    FecesConsistency.hard => l10n.fecesConsistencyHard,
    FecesConsistency.watery => l10n.fecesConsistencyWatery,
    FecesConsistency.bloody => l10n.fecesConsistencyBloody,
    FecesConsistency.mucus => l10n.fecesConsistencyMucus,
  };
}

String urateConditionLabel(UrateCondition uc, AppLocalizations l10n) {
  return switch (uc) {
    UrateCondition.normal => l10n.urateConditionNormal,
    UrateCondition.yellow => l10n.urateConditionYellow,
    UrateCondition.orange => l10n.urateConditionOrange,
    UrateCondition.green => l10n.urateConditionGreen,
    UrateCondition.absent => l10n.urateConditionAbsent,
  };
}

String matingSuccessLabel(MatingSuccess ms, AppLocalizations l10n) {
  return switch (ms) {
    MatingSuccess.successful => l10n.matingSuccessSuccessful,
    MatingSuccess.attempted => l10n.matingSuccessAttempted,
    MatingSuccess.rejected => l10n.matingSuccessRejected,
    MatingSuccess.inProgress => l10n.matingSuccessInProgress,
  };
}

String incubationMethodLabel(IncubationMethod im, AppLocalizations l10n) {
  return switch (im) {
    IncubationMethod.natural => l10n.incubationMethodNatural,
    IncubationMethod.artificial => l10n.incubationMethodArtificial,
    IncubationMethod.none => l10n.incubationMethodNone,
  };
}
