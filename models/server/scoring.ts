// ----------------------------
// Core enums & helpers
// ----------------------------

export type SeniorityLevel = 'junior' | 'mid' | 'senior' | 'unclear'
export type QualitativeLevel = 'low' | 'medium' | 'high'

export interface MetaBase {
  report_type: 'freemium' | 'paid'
  role_targeted: string
  seniority_estimate: SeniorityLevel
}

export interface OverallScoreBase {
  value: number // 0–100
  label: string
}

export interface SubscoresBase {
  ats_match: QualitativeLevel
  role_alignment: QualitativeLevel
  clarity_impact: QualitativeLevel
}

// ----------------------------
// Freemium report
// ----------------------------

export interface FreemiumReport {
  meta: MetaBase & {
    report_type: 'freemium'
  }
  overall_score: OverallScoreBase
  subscores: SubscoresBase
  top_issues: [
    string,
    string?,
    string?,
  ]
  career_fit_signal: {
    summary: string // 1 sentence
  }
  confidence_note: string
}

// ----------------------------
// Paid-only subtypes
// ----------------------------

export interface ScoredSubsection {
  value: number // 0–100
  summary: string
}

export interface PrioritizedImprovement {
  priority: 'low' | 'medium' | 'high'
  title: string
  impact_score_gain_estimate: number
  reason: string
}

export interface CareerStrategy {
  application_advice: string[]
  role_targeting_advice: string[]
  market_readiness: string
}

export interface InterviewSignals {
  strengths: string[]
  risk_areas: string[]
}

// ----------------------------
// Paid report
// ----------------------------

export interface PaidReport {
  meta: MetaBase & {
    report_type: 'paid'
    confidence_level: QualitativeLevel
  }

  overall_score: OverallScoreBase & {
    explanation: string
  }

  subscores: {
    ats_match: ScoredSubsection
    role_alignment: ScoredSubsection
    clarity_impact: ScoredSubsection
  }

  key_gaps: {
    missing_skills: string[]
    experience_gaps: string[]
  }

  prioritized_improvements: PrioritizedImprovement[]

  career_strategy: CareerStrategy

  interview_signals: InterviewSignals

  confidence_note: string
}

// ----------------------------
// Unified report type
// ----------------------------

export type ResumeReport = FreemiumReport | PaidReport
