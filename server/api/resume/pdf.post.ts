import puppeteer from 'puppeteer'
import { defineEventHandler, readBody, setHeader } from 'h3'
import fs from 'fs'
import path from 'path'
import { renderResumeHtml, RNDRTechnicalResumeHtml } from '~/composables/resumeTemplates'
import type { ExtResume } from '~/models/ext_resume'
import type { ResumeStyle } from '~/models/database'

export default defineEventHandler(async (event) => {
  const body = await readBody(event) // client POSTs JSON resume data

  const { resumeData, type } = body as { resumeData: ExtResume, type: ResumeStyle }

  console.log(type)

  if (!resumeData || Object.keys(resumeData).length === 0) {
    console.log('resumeData', resumeData)
    throw createError({
      statusCode: 400,
      statusMessage: 'No resume data provided',
    })
  }

  // Prepare Compiled Tailwind CSS
  const cssPath = path.join(process.cwd(), 'public', 'tailwind-pdf.css')
  const tailwindCss = fs.readFileSync(cssPath, 'utf-8')

  let renderedHtml = ''
  switch (type) {
    case 'technical':
      console.log('Generating tech resume')
      renderedHtml = RNDRTechnicalResumeHtml(resumeData)
      break
    default:
      console.log('Generating standard resume')
      renderedHtml = renderResumeHtml(resumeData)
  }

  const html = `
    <html lang="en">
    <head><style>${tailwindCss}</style></head>
    <body>${renderedHtml}</body>
    </html>
  `

  try {
    // 🔹 Launch Puppeteer
    const browser = await puppeteer.launch({
      headless: true, // prevents old deprecation warning
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    })
    const page = await browser.newPage()
    await page.setContent(html, { waitUntil: 'networkidle0' })

    const pdfBuffer = await page.pdf({ format: 'A4' })
    await browser.close()

    // 🔹 Stream PDF back to a client
    setHeader(event, 'Content-Type', 'application/pdf')
    setHeader(event, 'Content-Disposition', 'attachment; filename=resume.pdf')

    return pdfBuffer
    // return sendStream(event, Readable.from(pdfBuffer));
  }
  catch (err) {
    console.error('PDF generation error:', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to generate PDF',
    })
  }
})
