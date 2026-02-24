import {
  FoodType,
  Unit,
  FeedingResponse,
  FeedingMethod,
  ShedCompletion,
  FecesConsistency,
  UrateCondition,
  MatingSuccess,
  IncubationMethod,
} from '@common/enums';

// ── FEEDING ──────────────────────────────────────────────────────────────────

export interface FeedingDetails {
  food_type: FoodType;
  food_item: string;
  quantity?: number;
  unit?: Unit;
  supplements?: string[];
  feeding_response?: FeedingResponse;
  feeding_method?: FeedingMethod;
}

// ── SHEDDING ─────────────────────────────────────────────────────────────────

export interface SheddingDetails {
  shed_completion: ShedCompletion;
  problem_areas?: string[];
  assistance_needed?: boolean;
  assistance_method?: string;
  humidity_level?: number;
}

// ── DEFECATION ───────────────────────────────────────────────────────────────

export interface DefecationDetails {
  feces_present: boolean;
  urate_present: boolean;
  feces_consistency?: FecesConsistency;
  feces_color?: string;
  urate_condition?: UrateCondition;
  abnormalities?: string;
}

// ── MATING ───────────────────────────────────────────────────────────────────

export interface MatingDetails {
  mating_success: MatingSuccess;
  partner_id?: string;
  partner_name?: string;
  duration_minutes?: number;
  behavior_notes?: string;
  /** ISO 8601 date string (YYYY-MM-DD) */
  expected_laying_date?: string;
}

// ── EGG_LAYING ───────────────────────────────────────────────────────────────

export interface EggLayingDetails {
  egg_count: number;
  incubation_planned: boolean;
  fertile_count?: number;
  infertile_count?: number;
  clutch_number?: number;
  incubation_method?: IncubationMethod;
  incubation_temp?: number;
  incubation_humidity?: number;
  /** ISO 8601 date string (YYYY-MM-DD) */
  expected_hatch_date?: string;
}

// ── CANDLING ─────────────────────────────────────────────────────────────────

export interface CandlingDetails {
  day_after_laying: number;
  fertile_count: number;
  infertile_count: number;
  stopped_development: number;
  total_viable: number;
}

// ── HATCHING ─────────────────────────────────────────────────────────────────

export interface HatchingDetails {
  hatched_count: number;
  failed_count: number;
  offspring_ids?: string[];
  hatch_notes?: string;
}

// ── 유니언 타입 ───────────────────────────────────────────────────────────────

/** CareLog.details 컬럼에 저장되는 LogType별 상세 정보 유니언 타입 */
export type CareLogDetails =
  | FeedingDetails
  | SheddingDetails
  | DefecationDetails
  | MatingDetails
  | EggLayingDetails
  | CandlingDetails
  | HatchingDetails;
