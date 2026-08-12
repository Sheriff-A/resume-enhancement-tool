import { OpenAI } from 'openai'
import type { JobDescriptionKeywordExtraction } from '~/models/server/resume'

export const useOpenAI = () => {
  const { openaiApiKey } = useRuntimeConfig()
  return new OpenAI({
    apiKey: openaiApiKey,
  })
}

// Optional wrapper for calls
export async function safeOpenAIRequest<T>(fn: () => Promise<T>): Promise<T> {
  try {
    return await fn()
  }
  catch (err: any) {
    console.error('[OpenAI Error]', err?.message || err)

    // Handle common OpenAI API errors
    if (err?.status === 429) {
      throw createError({
        statusCode: 429,
        statusMessage: 'Rate limit exceeded — please try again later',
      })
    }

    if (err?.status === 401 || err?.status === 403) {
      throw createError({
        statusCode: 401,
        statusMessage: 'OpenAI API unauthorized',
      })
    }

    throw createError({
      statusCode: 500,
      statusMessage:
        'An unexpected error occurred while processing your request',
    })
  }
}

export function extractResponseData<T>(content: string): T {
  // Try to parse JSON safely
  const jsonStart = content.indexOf('{')
  const jsonEnd = content.lastIndexOf('}')
  const jsonString = content.slice(jsonStart, jsonEnd + 1)
  let parsed
  try {
    parsed = JSON.parse(jsonString)
  }
  catch (err) {
    console.error('Failed to parse JSON:', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to parse resume',
    })
  }
  // Check if parsed is an object
  if (typeof parsed !== 'object' || parsed === null) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to parse resume',
    })
  }

  return parsed as T
}

export async function extractKeywordsFromJobDescription(
  description: string,
): Promise<JobDescriptionKeywordExtraction> {
  const openai = useOpenAI()

  const systemPrompt = `You extract structured hiring keywords from job descriptions. Return only JSON.`
  const userPrompt = `
Extract the most important keywords from this job description.

Return JSON:
{
  hard_skills: string[]
  soft_skills: string[]
  tools: string[]
  languages: string[]
  technologies: string[]
  keywords: string[]
}

Rules:
- Max 8 per category
- No duplicates
- Keep phrases short (1–3 words)
- Focus on ATS-relevant terms

Job Description:
${description}
       `

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
      temperature: 0.3,
    }),
  )

  const content = response.choices[0].message?.content?.trim() || ''
  console.log(content)

  const result = extractResponseData<JobDescriptionKeywordExtraction>(content)
  console.log(result)

  return result
}
