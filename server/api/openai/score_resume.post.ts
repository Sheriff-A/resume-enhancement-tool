import {ExtResume, type ScoredResume} from "~/models/ext_resume";

interface ScoreResumeResponse {
  message: string;
  data: ScoredResume;
}

export default defineEventHandler(async (event): Promise<ScoreResumeResponse> => {
  const body = await readBody(event);
  const resume = body?.resume as ExtResume;
  if (!resume) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing resume in request body'
    });
  }
  const industy = body?.industry as string;
  const targetRole = body?.targetRole as string;

  const openai = useOpenAI();
  const prompt = `
  You are a professional resume reviewer and career coach.

Below is a candidate's structured resume. Assume the candidate is looking for a role as a ${targetRole}. Please:
1. Give a score from 1–10 based on content, formatting, and language in relevance to the ${targetRole}
2. Write short comments on each of those 3 dimensions
3. Suggest ways to improve the resume
4. Suggest 3 jobs or roles this person may be a good fit for

Respond in the following JSON format:
{
  "score": number (1–10),
  "comments": {
    "content": "...",
    "format": "...",
    "wording": "..."
  },
  "suggestions": [ "...", "..." ],
  "job_matches": [ "...", "...", "..." ]
}

Resume:
${JSON.stringify(resume, null, 2)}
  `.trim()

  const response = await safeOpenAIRequest(() => openai.chat.completions.create({
    model: 'gpt-4.1-mini',
    messages: [{role: 'user', content: prompt}],
    temperature: 0.3,
  }))

  const score = response.choices[0].message?.content

  try {
    const parsed = JSON.parse(score || '{}');
    return {
      message: 'Parsed scored results',
      data: parsed as ScoredResume,
    }
  } catch (err) {
    return {
      message: 'RAW: Failed to parse scored results',
      data: score as any,
    }
  }


})