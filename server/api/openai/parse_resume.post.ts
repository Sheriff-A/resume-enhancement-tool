import {ExtResume} from "~/models/ext_resume";

export default defineEventHandler(async (event): Promise<ExtResume> => {
  const body = await readBody(event)
  const rawText = body?.text

  if (!rawText) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing resume text in request body'
    })
  }

  const openai = useOpenAI();

  // TODO: Add Projects Section
  const prompt = `
You are a resume parsing assistant.
Take the resume text below and convert it into structured JSON with these keys:

- name
- email
- phone
- location if available
- portfolio if available
- linkedin if available
- github if available
- summary
- experience: array of jobs with:
  - company
  - position
  - location
  - start_date 
  - end_date (if no date or present, set to null)
  - is_current (boolean)
  - responsibilities: array of responsibilities with:
    - text: details of responsibility
- education: array of degrees with:
  - institution
  - field_of_study
  - certification
  - start_date
  - end_date (if no date or present, set to null)
  - notable_courses: array of notable courses with:
    - text: name of course
  - awards (as array of strings if available)
- skills: array of skills with:
  - name
  - type (hard or soft)

For start and end dates, use the format YYYY-MM-DD. If the day is not available, set it 01. If the date is not available, set it to null.
Only respond with a valid JSON object, and omit any commentary.

Resume:
"""${rawText}"""
`

  const response = await safeOpenAIRequest(() => openai.chat.completions.create({
    model: 'gpt-4.1-mini',
    messages: [{role: 'user', content: prompt,}],
    temperature: 0.3,
  }))

  const content = response.choices[0].message?.content?.trim() || ''

  // Try to parse JSON safely
  const jsonStart = content.indexOf('{')
  const jsonEnd = content.lastIndexOf('}')
  const jsonString = content.slice(jsonStart, jsonEnd + 1)
  let parsed
  try {
    parsed = JSON.parse(jsonString)
  } catch (err) {
    console.error('Failed to parse JSON:', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to parse resume'
    })
  }
  // Check if parsed is an object
  if (typeof parsed !== 'object' || parsed === null) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to parse resume'
    })
  }

  return parsed
})
