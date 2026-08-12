import type { Review } from '~/models/database'
import type { FreemiumReport, PaidReport } from '~/models/server/scoring'

export type ReviewType = 'freemium' | 'paid'

export async function loadLatestReview(
  userId: string,
  resumeId: string,
  type: ReviewType,
): Promise<Review | null> {
  const supabase = useSupabaseClient()
  const { data, error } = await supabase
    .from('reviews')
    .select('*')
    .eq('user_id', userId)
    .eq('resume_id', resumeId)
    .eq('type', type)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle()

  if (error) {
    throw error
  }

  return data
}

interface SaveReviewParams {
  userId: string
  resumeId: string
  type: ReviewType
  score: number
  analysis: FreemiumReport | PaidReport
}

export async function saveReview({
  userId,
  resumeId,
  type,
  score,
  analysis,
}: SaveReviewParams): Promise<Review> {
  const supabase = useSupabaseClient()
  const { data, error } = await supabase
    .from('reviews')
    .insert({
      user_id: userId,
      resume_id: resumeId,
      type,
      score,
      analysis: analysis as unknown as Review['analysis'],
    })
    .select('*')
    .single()

  if (error || !data) {
    throw new Error(`Failed to save review: ${error?.message || 'Unknown error'}`)
  }

  return data
}
