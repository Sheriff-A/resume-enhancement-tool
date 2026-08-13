import formidable from 'formidable'
import fs from 'fs/promises'
import pdfParse from 'pdf-parse'
import mammoth from 'mammoth'

// Disables body parser to handle raw file stream
// This is important for file uploads
// Formidable will need to read the stream directly
export const config = {
  api: {
    bodyParser: false
  }
}

export default defineEventHandler(async (event): Promise<string> => {
  const form = formidable({keepExtensions: true})

  // Parse the form to extract files
  // @ts-ignore
  const [_, files] = await new Promise((resolve, reject) =>
    form.parse(event.req, (err, fields, files) =>
      err ? reject(err) : resolve([fields, files])
    )
  )

  const file = Array.isArray(files.resume) ? files.resume[0] : files.resume
  if (!file) throw createError({statusCode: 400, statusMessage: 'No file uploaded'})

  const fileBuffer = await fs.readFile(file.filepath)
  const mimetype = file.mimetype || ''

  let extractedText = ''

  if (mimetype === 'application/pdf') {
    const parsed = await pdfParse(fileBuffer)
    extractedText = parsed.text
  } else if (
    mimetype === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ) {
    const result = await mammoth.extractRawText({buffer: fileBuffer})
    extractedText = result.value
  } else if (mimetype === 'text/plain') {
    extractedText = fileBuffer.toString('utf-8')
  } else {
    throw createError({statusCode: 415, statusMessage: 'Unsupported file type'})
  }

  return extractedText.trim()
})
