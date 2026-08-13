import { formatDateString } from '~/composables/helpers'
import type { ExtResume } from '~/models/ext_resume'
  
function parseDate(dateStr?: string | null, format = 'MMMM, yyyy'): string | null {
  if (!dateStr) return null
  return formatDateString(dateStr, format)
}

export function renderResumeHtml(resume: ExtResume): string {
  return `
    <div class="p-4">
      <div class="grid grid-cols-3 gap-8 items-end">
        <h3>
          ${resume.name}
        </h3>
        <p>
          ${resume.experience?.[0]?.position || 'Career Position'}
        </p>
        <p>
          ${resume.portfolio || resume.linkedin || resume.email || 'example@gmail.com'}
        </p>
      </div>
      <div class="grid grid-cols-3 gap-8">
        <div>
          <div class="mb-4">
            <h5>About</h5>
            <div class="border mt-1 mb-1"></div>
            <p>
              ${resume.summary}
            </p>
          </div>
  
          <div class="mb-4">
            <h5 class="">Education</h5>
            <div class="border mt-1 mb-1"></div>
            ${resume.education.map((edu: any) => `
              <div>
                <p>
                  ${parseDate(edu.start_date, 'yyyy')} - ${parseDate(edu.end_date, 'yyyy') || 'Present'}
                </p>
                <div class=" font-bold">
                  ${edu.institution || 'Institution Name'}
                </div>
                <p>
                  ${edu.certification || 'Degree Name'}
                </p>
                <p>
                  ${edu.location || 'Location'}
                </p>
                <ul>
                  ${edu.notable_courses.map((detail: any) => `
                    <li class="mt-1 mb-1">
                      <p class="!text-xs">
                        ${detail || 'Key achievement or responsibility.'}
                      </p>
                    </li>
                  `).join('')}
                </ul>
              </div>
            `).join('')}
          </div>
  
          <div class="mb-4">
            <h5 class="">Skills</h5>
            <div class="border mt-1 mb-1"></div>
            ${resume.skills.map((skill: any) => `
              <div>
                <p class="font-bold">
                  ${skill.name || 'Skill Name'}
                </p>
              </div>
            `).join('')}
          </div>
        </div>
        <div class="col-span-2">
          <h5 class="">
            Work Experience
          </h5>
          <div class="border mt-1 mb-1"></div>
          ${resume.experience.map((job: any) => `
            <div class="grid grid-cols-2 gap-4">
              <div>
  
                <div class=" font-bold">
                  ${job.company || 'Company Name'}
                </div>
                <p>
                  ${parseDate(job.start_date) || 'Start Date'} -
                  ${parseDate(job.end_date) || 'Present'}
                </p>
                <p>
                  ${job.location || 'Location'}
                </p>
              </div>
              <div>
                <h5 class="!font-normal">
                  ${job.position || 'Job Title'}
                </h5>
                <ul class="">
                  ${job.responsibilities.map((responsibility: any) => `
                  <li class="mb-1 mt-1">
                    <p class="!text-xs">
                      ${responsibility.text || 'Key achievement or responsibility.'}
                    </p>
                  </li>
                  `).join('')}
                </ul>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    </div>
  `
}

export function RNDRTechnicalResumeHtml(resume: ExtResume): string {
  return `
  <div class="p-12 ff-font-serif">
      <h4 class="text-center">
        ${resume.name}
      </h4>
      <div class="flex gap-6 justify-center">
        <p class="">${resume.phone} | ${resume.email} ${resume.portfolio ? `| <span class="">${resume.portfolio}</span>` : ''} ${resume.linkedin ? `| <span class="">${resume.linkedin}</span>` : ''} ${resume.github ? `| <span class="">${resume.github}</span>` : ''}
      </div>

      <div>
        <h5 class="uppercase">Education</h5>
        <div class="border-b my-1"></div>
        ${resume.education.map((edu: any) => `
        <div class="mb-2">
            <div class="flex gap-2 justify-between">
              <div>
                <h5>${edu.institution} | ${edu.location || ''}</h5>
                <p class="italic">${edu.certification}</p>
              </div>
              <div>
                <p>
                  ${parseDate(edu.start_date)} -
                  ${edu.end_date ? parseDate(edu.end_date) : 'Present'}
                </p>
              </div>
            </div>
            <ul class="pl-4 list-outside list-disc">
              ${edu.notable_courses.length
                ? `
              <li>
                <span class="font-bold">Notable Courses:</span>
                ${edu.notable_courses.join(', ')}
              </li>
              `
                : ''}
              ${edu.awards.length
                ? `
              <li>
                <span class="font-bold">Awards:</span>
                ${edu.awards.join(', ')}
              </li>
              `
                : ''}
            </ul>
          </div>
        `).join('')}
      </div>
      <div class="mt-6">
        <h5 class="uppercase">Skills</h5>
        <div class="border-b my-1"></div>
        <p>${resume.skills.map(skill => skill.name).join(', ')}</p>
      </div>

      <div class="mt-6">
        <h5 class="uppercase">Relevant Experience</h5>
        <div class="border-b my-1"></div>
        ${resume.experience.map((exp: any) => `
        
        <div class="mb-2">
            <div class="flex gap-2 justify-between">
              <div>
                <h5>${exp.company} | ${exp.location}</h5>
                <p class="italic">${exp.position}</p>
              </div>
              <div>
                <p>
                  ${parseDate(exp.start_date)} -
                  ${exp.end_date ? parseDate(exp.end_date) : 'Present'}
                </p>
              </div>
            </div>
            <ul class="pl-4 list-outside list-disc">
              ${exp.responsibilities.map((resp: any) => `
              <li>${resp.text}</li>
              `).join('')}
            </ul>
          </div>
        `).join('')}
      </div>
    </div>
  `
}
