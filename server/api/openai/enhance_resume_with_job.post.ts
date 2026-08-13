import type {
  EnhanceResumeResults,
  JobDescriptionKeywordExtraction,
} from '~/models/server/resume'
import type { ParsedEnhancementResume } from '~/models/general'
import {
  extractKeywordsFromJobDescription,
  extractResponseData,
} from '~/server/utils/openai'

export default defineEventHandler(
  async (event): Promise<EnhanceResumeResults> => {
    const body = await readBody(event)
    const resume = body?.resume as ParsedEnhancementResume
    const description = body?.description as string
    if (!resume) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Missing resume in request body',
      })
    }

    if (!description) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Missing job description in request body',
      })
    }

    const openai = useOpenAI()

    // Step 1: hash the job description
    let keywords: JobDescriptionKeywordExtraction
    // Step 2: Try Cache
    // Step 3: If no cache, call OpenAI to extract keywords
    keywords = await extractKeywordsFromJobDescription(description)

    // Step 4*: Store keywords in the database

    // Step 5: Call OpenAI to analyze resume and produce structured improvement suggestions based on the job description and keywords
    const systemPrompt = `
  You are an expert resume editor and ATS optimization specialist.

Your task is to analyze a candidate's resume and a job description, and produce structured improvement suggestions.

STRICT RULES:
- Output ONLY valid JSON
- Do NOT include explanations or text outside JSON
- Do NOT include fields that are unchanged
- Do NOT hallucinate experience or add false information
- Keep bullet points concise (max 1–2 lines)
- Use strong action verbs and quantify impact where possible
- Align suggestions with the job description using relevant keywords

UPDATE RULES:
- Use "action": "update" to modify existing content (requires idx)
- Use "action": "add" to add new content (no idx)
- Use "action": "remove" to remove weak or irrelevant content (requires idx)

FIELD RULES:
- Include "reason" only if the improvement is non-obvious
- Include "confidence" between 0 and 1
- Prefer high-impact, high-confidence suggestions over many low-quality ones

Return JSON matching the provided schema.
  `.trim()

    // TODO: Fill in the blanks
    const userPrompt = `
    Candidate Resume (JSON):
${JSON.stringify(resume, null, 2)}

Job Description:
${description}

Target Keywords:
${JSON.stringify(keywords, null, 2)}

Return updates using this schema:
UpdateAction = 'update' | 'add' | 'remove'

BulletUpdate = {
  action: UpdateAction
  idx?: number // required for update/remove
  text?: string // required for add/update
  reason?: string // optional explanation for pro-users
  confidence?: number // 0-100 can be used to prioritize edits
}

EnhanceResumeResults = {
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

IMPORTANT:
- Only include fields that should change
- Do not rewrite the entire resume
- Focus on relevance to the job description
- Prioritize high-impact improvements
- Do not suggest more than 2 updates per section unless critical
    `.trim()

    const response = await safeOpenAIRequest(() =>
      openai.chat.completions.create({
        model: 'gpt-4.1-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
        response_format: {
          type: 'json_object',
        },
        temperature: 0.2,
      }),
    )

    const content = response.choices[0].message?.content?.trim() || ''
    console.log(content)
    const result = extractResponseData<EnhanceResumeResults>(content)
    console.log(result)

    return result
  },
)
