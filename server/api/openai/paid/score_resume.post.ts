import type { PaidReport } from '~/models/server/scoring'
import type { ParsedScoringResume } from '~/models/general'

export default defineEventHandler(async (event): Promise<PaidReport> => {
  const body = await readBody(event)
  const resume = body?.resume as ParsedScoringResume
  if (!resume) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing resume in request body',
    })
  }
  const targetRole = body?.targetRole as string

  const openai = useOpenAI()

  const systemPrompt = `
  You are an advanced AI career coach and resume screening expert.

Your task is to analyze a resume provided as structured JSON against a target job description
and produce a detailed screening readiness and career strategy report.

IMPORTANT CONSTRAINTS:
- Output MUST be valid JSON only.
- No markdown, no prose outside JSON.
- Be precise, actionable, and supportive.
- Avoid vague or generic advice.
- Do NOT reference proprietary ATS vendors.
- Frame results as "screening readiness" and "ATS compatibility".

This is a PAID report.
Provide depth, prioritization, and strategic guidance.
`.trim()

  const userPrompt = `
  INPUT:
- resume_json: ${JSON.stringify(resume, null, 2)}
- job_description: ${targetRole}

TASK:
Analyze the resume against the target job and return a comprehensive screening readiness report.

OUTPUT REQUIREMENTS:
Return a JSON object with the following structure:

{
  "meta": {
    "report_type": "paid",
    "role_targeted": string,
    "seniority_estimate": "junior" | "mid" | "senior" | "unclear",
    "confidence_level": "low" | "medium" | "high"
  },
  "overall_score": {
    "value": number (0-100),
    "label": string,
    "explanation": string
  },
  "subscores": {
    "ats_match": {
      "value": number (0-100),
      "summary": string
    },
    "role_alignment": {
      "value": number (0-100),
      "summary": string
    },
    "clarity_impact": {
      "value": number (0-100),
      "summary": string
    }
  },
  "key_gaps": {
    "missing_skills": [string],
    "experience_gaps": [string]
  },
  "prioritized_improvements": [
    {
      "priority": "low" | "medium" | "high",
      "title": string,
      "impact_score_gain_estimate": number,
      "reason": string
    }
  ],
  "career_strategy": {
    "application_advice": [string],
    "role_targeting_advice": [string],
    "market_readiness": string
  },
  "interview_signals": {
    "strengths": [string],
    "risk_areas": [string]
  },
  "confidence_note": string
}

RESUME_JSON NOTES:
- basic_info: phone, linkedin, github, portfolio, location and summary may be empty strings or excluded if not provided. Do not score these unless they are relevant to the target role and would be impactful based on the resume data.
- education: field_of_study, awards, notable_courses and location may be empty strings or excluded if not provided. Score based on relevance as needed.
- experience: location may be empty strings or excluded if not provided. Score based on relevance as needed. responsibilities should be treated as a high priority for this assessment.

RULES:
- prioritized_improvements must contain 3 to 5 items only.
- impact_score_gain_estimate must be realistic and non-exaggerated.
- career_strategy bullets must be concise and role-specific.
- Avoid generic advice like "network more" unless justified by resume data.
- confidence_note should motivate without inflating expectations.
`.trim()

  // TODO: Consider merging this with the free version's code and switch based on user's subscription as checked with the server
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

  // TODO: Save review at the end to the database for later referencing as needed

  return parsed as PaidReport
})
