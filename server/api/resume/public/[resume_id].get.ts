import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server';
import { ExtResume } from '~/models/ext_resume';

interface GetPublicResumeResponse {
  message: string;
  data: ExtResume | null;
}

export default defineEventHandler(
  async (event): Promise<GetPublicResumeResponse> => {
    const resumeId = String(getRouterParam(event, 'resume_id'));

    if (!resumeId) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Bad Request: resume_id is required',
      });
    }

    const user = await serverSupabaseUser(event);
    const supabase = await serverSupabaseClient(event);
    if (!supabase) {
      throw createError({
        statusCode: 500,
        statusMessage: 'Failed to initialize Supabase client',
      });
    }

    const { data, error } = await supabase
      .from('resumes')
      .select('*, experience(*), education(*), projects(*)')
      .eq('id', resumeId)
      .single();

    if (error || !data) {
      throw createError({
        statusCode: 500,
        statusMessage: `Failed to fetch resume: ${error?.message || 'Unknown error'}`,
      });
    }

    const userId = user?.id;
    if (userId && data.user_id === userId) {
      return {
        message: '',
        data: data as unknown as ExtResume,
      };
    }

    // Check if the résumé is public
    // If not, notify the frontend that it's private
    if (!data.is_public) {
      return {
        message: 'This resume is private.',
        data: null,
      };
    }

    // If it is, fetch the resume data and return it
    return {
      message: '',
      data: data as unknown as ExtResume,
    };
  },
);
