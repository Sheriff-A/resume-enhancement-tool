import type {
  Education,
  Experience,
  NewEducation,
  NewExperience,
  NewProject,
  Project,
  Resume,
  Skill,
} from '~/models/database';

type Exp = NewExperience | Experience;
type Edu = NewEducation | Education;
type Proj = NewProject | Project;

export interface ExtResume extends Omit<Resume, 'skills'> {
  experience: (Omit<Exp, 'responsibilities'> & {
    responsibilities: {
      text: string
      last_suggestion?: string
    }[]
  })[]
  education: (Omit<Edu, 'notable_courses' | 'awards'> & {
    notable_courses: {
      text: string
      last_suggestion?: string
    }[]
    awards: {
      text: string
      last_suggestion?: string
    }[]
  })[]
  projects: (Omit<Proj, 'highlights'> & {
    highlights: {
      text: string
      last_suggestion?: string
    }[]
  })[]
  skills: Skill[]
}

export interface SampleResume extends Omit<
  ExtResume,
  | 'id'
  | 'updated_at'
  | 'created_at'
  | 'user_id'
  | 'experience'
  | 'education'
  | 'projects'
> {
  experience: (Omit<Exp, 'user_id' | 'resume_id' | 'responsibilities'> & {
    responsibilities: {
      text: string
      last_suggestion?: string
    }[]
  })[]
  education: (Omit<Edu, 'user_id' | 'resume_id' | 'notable_courses' | 'awards'> & {
    notable_courses: {
      text: string
      last_suggestion?: string
    }[]
    awards: {
      text: string
      last_suggestion?: string
    }[]
  })[]
  projects: (Omit<Proj, 'user_id' | 'resume_id' | 'highlights'> & {
    highlights: {
      text: string
      last_suggestion?: string
    }[]
  })[]
  skills: Skill[]
}

export interface ScoredResume {
  score: number
  comments: {
    content: string
    format: string
    wording: string
  }
  suggestions: string[]
  job_matches: string[]
}
