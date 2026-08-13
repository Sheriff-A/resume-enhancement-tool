export type ZodError = { message: string, path: string }

export interface SignInData {
  email: string
  password: string
}

export interface SignUpData extends SignInData {
  name: string
}

export interface Route {
  label: string // Display label for the route
  path: string // Doubles as the key at the moment
  icon?: string // Optional icon for the route
  target?: string
}

export interface ComposableReturn<T> {
  status: 'validation_error' | 'error' | 'success' // Status of the operation
  errors?: string[] // Array of error messages if any
  data: T | null // The data returned by the composable
}

export type UpdateDecision = 'accepted' | 'rejected'

type UpdateAction = 'update' | 'add' | 'remove'

interface BulletUpdate {
  action: UpdateAction
  idx?: number // required for update/remove
  text?: string // required for add/update
  reason?: string // optional explanation for pro-users
  confidence?: number // 0-100 can be used to prioritize edits
}

export interface UpdatedResumeDetails {
  summary?: {
    text: string
    reason?: string
    confidence?: number
  }
  experience?: {
    id: number
    responsibilities?: BulletUpdate[]
  }[]
  education?: {
    id: number
    notable_courses?: BulletUpdate[]
  }[]
  projects?: {
    id: number
    highlights?: BulletUpdate[]
  }[]
  skills?: {
    action: UpdateAction
    idx?: number
    name?: string
    type?: 'hard' | 'soft'
    reason?: string
    confidence?: number
  }[]
}

export interface EvaluationResult {
  score: number // Score from 0 to 10
  summary: string // Summary of the evaluation
  strengths: string[] // List of strengths
  gaps: string[] // List of gaps
  improvement_suggestions: string[] // List of improvement suggestions
  recommended_keywords: string[] // List of recommended keywords
  job_fit_analysis: string // Analysis of job fit
  suggested_resume_edits: UpdatedResumeDetails // Actionable resume edits
}

export interface ParsedScoringResume {
  id: string
  basic_info: {
    name: string
    email: string
    phone: string
    linkedin: string
    summary: string
    github?: string
    portfolio?: string
    location?: string
  }
  experience: {
    company: string
    position: string
    location: string
    start_date: string
    end_date: string
    responsibilities: string[]
  }[]
  education: {
    awards?: string[]
    certification: string
    end_date: string
    field_of_study: string
    institution: string
    location: string
    notable_courses?: string[]
    start_date: string
  }[]
  // projects: {}[]
  skills: string[]
}

export interface ParsedEnhancementResume {
  summary: string
  experience: {
    id: string | number
    responsibilities: { idx: number, text: string }[]
  }[]
  education: {
    id: string | number
    notable_courses: { idx: number, text: string }[]
  }[]
  // projects: {}[]
  skills: { name: string, type: 'hard' | 'soft' | 'other' }[]
}
