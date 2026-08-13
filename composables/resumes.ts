import type { ExtResume } from '~/models/ext_resume'
import type {
  ComposableReturn,
  ParsedEnhancementResume,
  ParsedScoringResume,
} from '~/models/general'

export async function loadResume(
  userId: string,
  resumeId: string,
): Promise<ComposableReturn<ExtResume>> {
  const supabase = useSupabaseClient()
  const { data, error } = await supabase
    .from('resumes')
    .select('*, experience(*), education(*), projects(*)')
    .eq('id', resumeId)
    .eq('user_id', userId)
    .order('updated_at', {
      ascending: false,
      nullsFirst: false,
    })
    .single()

  if (error || !data) {
    throw error
  }

  return {
    status: 'success',
    data: data as unknown as ExtResume,
  }
}

export interface ResumeSelectOption {
  id: string
  name: string
  nickname: string
}

export async function listResumesForSelect(
  userId: string,
): Promise<ResumeSelectOption[]> {
  const supabase = useSupabaseClient()
  const { data, error } = await supabase
    .from('resumes')
    .select('id, name, nickname')
    .eq('user_id', userId)
    .order('updated_at', { ascending: false, nullsFirst: false })

  if (error) {
    throw new Error(`Failed to load resumes: ${error.message}`)
  }

  return data || []
}

type UpsertResumeResult = 'upsert' | 'insert'

export async function upsertResume(
  resumeData: Partial<ExtResume>,
): Promise<ComposableReturn<UpsertResumeResult>> {
  const res: UpsertResumeResult = resumeData.id ? 'upsert' : 'insert'

  const supabase = useSupabaseClient()
  const { data, error } = await supabase
    .rpc('upsert_resume_data', {
      resume_data: resumeData as unknown,
    })
    .select('*')

  if (error || !data) {
    throw new Error(`Failed to upsert application: ${error?.message || 'Unknown error'}`)
  }

  return {
    status: 'success',
    data: res,
  }
}

export async function toggleResumeVisibility(
  resumeId: number,
  isPublic: boolean,
): Promise<void> {
  const supabase = useSupabaseClient()
  const { error } = await supabase
    .from('resumes')
    .update({ is_public: isPublic })
    .eq('id', resumeId)
  if (error) {
    throw new Error(`Failed to toggle resume visibility: ${error.message}`)
  }
}

// TODO: Implement deleteResume function
export async function deleteResume() {}

export function parseResumeForScoring(
  resumeData: ExtResume,
): ParsedScoringResume {
  // TODO: Implement me
  // TODO: add projects
  return {
    id: resumeData.id,
    basic_info: {
      name: resumeData.name,
      email: resumeData.email,
      phone: resumeData.phone || '',
      linkedin: resumeData.linkedin || '',
      summary: resumeData.summary || '',
      github: resumeData.github || undefined,
      location: resumeData.location || undefined,
      portfolio: resumeData.portfolio || undefined,
    },
    education: resumeData.education.map(edu => ({
      awards: edu.awards.map(award => award.text) || undefined,
      certification: edu.certification,
      end_date: edu.end_date || 'Present',
      institution: edu.institution,
      field_of_study: edu.field_of_study || '',
      location: edu.location || '',
      start_date: edu.start_date,
      notable_courses: edu.notable_courses.map(nc => nc.text) || undefined,
    })),
    experience: resumeData.experience.map(exp => ({
      start_date: exp.start_date,
      location: exp.location || '',
      company: exp.company,
      end_date: exp.end_date || 'Present',
      position: exp.position,
      responsibilities: exp.responsibilities.map(resp => resp.text) || [],
    })),
    skills: resumeData.skills.map(skill => `${skill.name} (${skill.type})`),
  }
}

export function parseResumeForEnhancement(
  resumeData: ExtResume,
): ParsedEnhancementResume {
  return {
    summary: resumeData.summary || '',
    experience:
      resumeData.experience?.map((exp, idx) => ({
        id: exp.id || idx,
        responsibilities: exp.responsibilities?.map((resp, idx) => ({
          idx: idx,
          text: resp.text,
        })),
      })) || [],
    education:
      resumeData.education?.map((edu, idx) => ({
        id: edu.id || idx,
        notable_courses: edu.notable_courses?.map((nc, ncIdx) => ({
          idx: ncIdx,
          text: nc.text,
        })) || [],
      })) || [],
    skills:
      resumeData.skills?.map(skill => ({
        name: skill.name,
        type: skill.type,
      })) || [],
  }
}
