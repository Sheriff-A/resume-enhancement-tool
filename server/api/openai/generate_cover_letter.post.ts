export default defineEventHandler(async (event): Promise<string> => {
  const body = await readBody(event)
  const jobDetails = body?.jobDetails
  const resumeText = body?.resumeText

  if (!jobDetails || !resumeText) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing jobDetails or resumeText in request body'
    })
  }

  const jobDetailsStr = typeof jobDetails === 'string' ? jobDetails : JSON.stringify(jobDetails, null, 2)
  const resumeTextStr = typeof resumeText === 'string' ? resumeText : JSON.stringify(resumeText, null, 2)

  console.log('Generating cover letter for job:', jobDetails)
  console.log('Resume:', resumeText)

  const openai = useOpenAI();

  const prompt = `
You are a cover letter writing assistant.
Using the job details JSON data and resume JSON data provided, write a personalized cover letter that highlights the most relevant skills and experiences for the job.
Make sure to address the hiring manager, mention the company name, and explain why you are a great fit for the role.
Keep the tone professional yet engaging, and limit the letter to around 3 - 5 paragraphs and about 2000 words.
Use the following structure:
1. Introduction: State the position you are applying for and where you found the job listing.
2. Body: Highlight your relevant skills, experiences, and achievements that align with the job requirements.
3. Conclusion: Express enthusiasm for the role, mention any attachments (like your resume), and provide your contact information.

Job Details:
"""${jobDetailsStr}"""

Resume Text:
"""${resumeTextStr}"""
`

  console.log('Cover Letter Prompt:', prompt)
  return ''

  // const response = await safeOpenAIRequest(() => openai.chat.completions.create({
  //   model: 'gpt-4.1-mini',
  //   messages: [{role: 'user', content: prompt,}],
  //   temperature: 0.7,
  // }))
  //
  // const content = response.choices[0].message?.content?.trim() || ''
  // console.log(content)
  // return content
})