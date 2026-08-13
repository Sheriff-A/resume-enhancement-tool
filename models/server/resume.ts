export type UpdateAction = 'update' | 'add' | 'remove'

interface BulletUpdate {
  action: UpdateAction
  idx?: number // required for update/remove
  text?: string // required for add/update
  reason?: string // optional explanation for pro-users
  confidence?: number // 0-100 can be used to prioritize edits
}

export interface JobDescriptionKeywordExtraction {
  hard_skills: string[]
  soft_skills: string[]
  tools: string[]
  languages: string[]
  technologies: string[]
  keywords: string[]
}

export interface EnhanceResumeResults {
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
