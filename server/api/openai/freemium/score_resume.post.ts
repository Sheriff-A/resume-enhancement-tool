import type { ExtResume } from '~/models/ext_resume'
import type { FreemiumReport } from '~/models/server/scoring'

export default defineEventHandler(async (event): Promise<FreemiumReport> => {
  const body = await readBody(event)
  const resume = body?.resume as ExtResume
  if (!resume) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing resume in request body',
    })
  }
  const targetRole = body?.targetRole as string

  const openai = useOpenAI()

  const systemPrompt = `
  You are an AI resume screening assistant.

Your task is to analyze a resume provided as structured JSON against a target job description.
Generate a high-level screening readiness report similar to an ATS-style evaluation.

IMPORTANT CONSTRAINTS:
- Do NOT provide step-by-step fixes or examples.
- Do NOT provide detailed explanations.
- Do NOT overwhelm the user.
- Be concise, neutral, and supportive.
- Output MUST be valid JSON only.
- Do NOT include markdown or prose outside JSON.

This is a FREEMIUM report.
Focus on awareness and clarity, not execution guidance.

  `.trim()

  const userPrompt = `
  INPUT:
- resume_json: ${JSON.stringify(resume, null, 2)}
- job_description: ${targetRole}

TASK:
Analyze the resume against the target job and return a screening readiness report.

OUTPUT REQUIREMENTS:
Return a JSON object with the following structure and constraints:

{
  "meta": {
    "report_type": "freemium",
    "role_targeted": string,
    "seniority_estimate": "junior" | "mid" | "senior" | "unclear"
  },
  "overall_score": {
    "value": number (0-100),
    "label": string
  },
  "subscores": {
    "ats_match": "low" | "medium" | "high",
    "role_alignment": "low" | "medium" | "high",
    "clarity_impact": "low" | "medium" | "high"
  },
  "top_issues": [
    string,
    string,
    string
  ],
  "career_fit_signal": {
    "summary": string
  },
  "confidence_note": string
}

RULES:
- Limit top_issues to a maximum of 3 short items.
- career_fit_signal.summary must be 1 sentence.
- confidence_note must be encouraging and neutral.
- Do not include recommendations, fixes, or instructions.
- All values must be derived from the provided input.

  `.trim()

  const response = await safeOpenAIRequest(() => openai.chat.completions.create({
    model: 'gpt-4.1-mini',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    response_format: {
      type: 'json_object',
    },
    temperature: 0.3,
  }))

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

  return parsed as FreemiumReport
})
