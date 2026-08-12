import type { Database } from '~/models/supabase/database.types'

// Custom
export type ProductSlug = 'basic' | 'pro-plan' | 'custom'
export type Message = 'success'
export type Data = {
  message: Message
}

export interface Skill {
  name: string
  type: SkillType
}

export interface NotableCourse {
  text: string
  last_suggestion?: string
}

export interface Responsibility {
  text: string
  last_suggestion?: string
}

export interface Highlight {
  text: string
  last_suggestion?: string
}

// ////////////////////
// Tables
// ////////////////////

// Profile Table
export type Profile = Database['public']['Tables']['profiles']['Row']
export type NewProfile = Database['public']['Tables']['profiles']['Insert']
export type UpdateProfile = Database['public']['Tables']['profiles']['Update']

// Resume Table
export type Resume = Database['public']['Tables']['resumes']['Row'] & {
  skills: Skill[]
}
export type NewResume = Database['public']['Tables']['resumes']['Insert'] & {
  skills?: Skill[]
}
export type UpdateResume = Database['public']['Tables']['resumes']['Update'] & {
  skills?: Skill[]
}

// Experience Table
export type Experience = Database['public']['Tables']['experience']['Row'] & {
  responsibilities: Responsibility[]
}
export type NewExperience
  = Database['public']['Tables']['experience']['Insert'] & {
    responsibilities?: Responsibility[]
  }
export type UpdateExperience
  = Database['public']['Tables']['experience']['Update'] & {
    responsibilities?: Responsibility[]
  }

// Project Table
export type Project = Database['public']['Tables']['projects']['Row'] & {
  highlights: NotableCourse[]
}
export type NewProject = Database['public']['Tables']['projects']['Insert'] & {
  highlights?: NotableCourse[]
}
export type UpdateProject
  = Database['public']['Tables']['projects']['Update'] & {
    highlights?: NotableCourse[]
  }

// Education Table
export type Education = Database['public']['Tables']['education']['Row'] & {
  notable_courses: NotableCourse[]
}
export type NewEducation
  = Database['public']['Tables']['education']['Insert'] & {
    notable_courses?: NotableCourse[]
  }
export type UpdateEducation
  = Database['public']['Tables']['education']['Update'] & {
    notable_courses?: NotableCourse[]
  }

// Review Table
export type Review = Database['public']['Tables']['reviews']['Row']
export type NewReview = Database['public']['Tables']['reviews']['Insert']
export type UpdateReview = Database['public']['Tables']['reviews']['Update']

// ////////////////////
// Views
// ////////////////////

// ////////////////////
// Enums
// ////////////////////
export type SkillType = Database['public']['Enums']['skill_type']
export type ResumeStyle = Database['public']['Enums']['resume_style']

// ////////////////////
// Constants
// ////////////////////
export const SKILL_TYPES = ['hard', 'soft', 'other'] as const
export const RESUME_STYLES = ['modern', 'technical'] as const
