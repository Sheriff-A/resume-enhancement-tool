import type { EvaluationResult } from '~/models/general';

export default defineEventHandler(async (event): Promise<EvaluationResult> => {
  const body = await readBody(event);
  const jobDetails = body?.jobDetails;
  const resumeText = body?.resumeText;

  if (!jobDetails || !resumeText) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing jobDetails or resumeText in request body'
    });
  }

  const jobDetailsStr = typeof jobDetails === 'string' ? jobDetails : JSON.stringify(jobDetails, null, 2);
  const resumeTextStr = typeof resumeText === 'string' ? resumeText : JSON.stringify(resumeText, null, 2);

  console.log('Generating cover letter for job:', jobDetails);
  console.log('Resume:', resumeText);

  const openai = useOpenAI();

  // System Prompt for the resume evaluation
  const systemPrompt = `
  You are an expert career coach and resume analyst. Your job is to compare a user's resume with a given job description and provide structured, actionable feedback including concrete text suggestions.
  `;

  // User Prompt with job details and resume text
  const prompt = `
Using the job details JSON data and resume JSON data provided, compare the resume to the job, and help the candidate become a better applicant.
Identify strengths, weaknesses, missing keywords, and suggest improvements. Provide concrete text rewrites or additions that the user can insert into their resume. Use only information from the resume and job description (do not invent new experience). If there are no suggestions, do not force one. Omit blank optional sections. Your output must strictly follow this JSON schema:

- score (number 0-10)
- summary (string)
- strengths (array of strings)
- gaps (array of strings)
- improvement_suggestions (optional, array of strings)
- recommended_keywords (optional, array of strings)
- job_fit_analysis (string)
- suggested_resume_edits:
  - summary (optional, string, improved or new summary text)
  - experience: optional, array of objects with:
    - id (number, matching the resume experience id)
    - responsibilities: array of objects with:
      - idx (number, matching the responsibility index in the resume. If new suggestion, omit idx)
      - text (string, improved or new responsibility text)
  - education: optional, array of objects with:
    - id (number, matching the resume education id)
    - notable_courses: array of objects with:
      - idx (number, matching the course index in the resume. If new suggestion, omit idx)
      - text (string, improved or new course text)

Make sure your output is valid JSON, with no extra explanations outside the JSON.

Job Details:
"""${jobDetailsStr}"""

Resume Text:
"""${resumeTextStr}"""
`;

  // TODO: Add Skill updates:
  // - skills: optional, array of objects with:
  // - idx (number, matching the skill index in the resume. If new suggestion, omit idx)
  // - name (string, improved or new skill name)
  // - type (string, "hard" or "soft")

  console.log('Evaluation System Prompt:', systemPrompt);
  console.log('Evaluation User Prompt:', prompt);
  return {} as EvaluationResult;

  // const response = await safeOpenAIRequest(() => openai.chat.completions.create({
  //   model: 'gpt-4.1-mini',
  //   messages: [
  //     { role: 'system', content: systemPrompt },
  //     { role: 'user', content: prompt }
  //   ],
  //   response_format: {
  //     type: 'json_object'
  //   },
  //   temperature: 0.7
  // }));
  //
  // const content = response.choices[0].message?.content?.trim() || '';
  // console.log(content);
  //
  // // Try to parse JSON safely
  // const jsonStart = content.indexOf('{');
  // const jsonEnd = content.lastIndexOf('}');
  // const jsonString = content.slice(jsonStart, jsonEnd + 1);
  // let parsed;
  // try {
  //   parsed = JSON.parse(jsonString);
  // } catch (err) {
  //   console.error('Failed to parse JSON:', err);
  //   throw createError({
  //     statusCode: 500,
  //     statusMessage: 'Failed to parse resume'
  //   });
  // }
  // // Check if parsed is an object
  // if (typeof parsed !== 'object' || parsed === null) {
  //   throw createError({
  //     statusCode: 500,
  //     statusMessage: 'Failed to parse resume'
  //   });
  // }
  //
  // return parsed;
});