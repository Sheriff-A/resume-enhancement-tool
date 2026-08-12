import { z } from 'zod'
import type { SchemaFromInterface } from '~/models/utils'
import { RGX_PHONE_NUMBER } from '~/data/regex'
import { formatBytes } from '~/composables/helpers'
import { RESUME_STYLES, SKILL_TYPES } from '~/models/database'
import type { ParsedEnhancementResume } from '~/models/general'

// ////////////////////////
// Job Application Form
// ///////////////////////

export const MAX_EXPERIENCE_NUMBER = 5
export const MAX_EDUCATION_NUMBER = 3
export const MAX_PROJECT_NUMBER = 3
export const MAX_SKILLS_NUMBER = 20

export const MAX_SUMMARY_LENGTH = 750
export const MAX_RESPONSIBILITY_LENGTH = 300
export const MAX_AWARD_LENGTH = 150
export const MAX_NOTABLE_COURSES_LENGTH = 150

export const MAX_JOB_DESCRIPTION_LENGTH = 6000

export const enhanceResumeSchema = z.object({
  job_description: z
    .string({
      message: 'Job Description must be a string',
    })
    .min(150, `Job Description must be at least 150 characters`)
    .max(
      MAX_JOB_DESCRIPTION_LENGTH,
      `Job Description must be at most ${MAX_JOB_DESCRIPTION_LENGTH} characters`,
    ),
  resume: z.object({
    summary: z.string({
      message: 'Resume Summary must be a string',
    }),
    experience: z
      .array(
        z.object({
          id: z
            .number({
              message: 'Experience ID must be a number',
            })
            .min(0, 'Experience ID must be at least 0'),
          responsibilities: z
            .array(
              z.object({
                idx: z
                  .number({
                    message: 'Experience Responsibilities Index must be a number',
                  })
                  .min(0, 'Experience Responsibility Index must be at least 0'),
                text: z
                  .string({
                    message: 'Experience Responsibility Index must be a string',
                  })
                  .min(
                    3,
                    'Experience Responsibility must be at least 3 characters',
                  )
                  .max(
                    MAX_RESPONSIBILITY_LENGTH,
                    `Experience Responsibility must be at most ${MAX_RESPONSIBILITY_LENGTH} characters`,
                  ),
              }),
              {
                message: 'Experience Responsibilities must be an array',
              },
            )
            .min(1, 'Experience Responsibility is required'),
        }),
        {
          message: 'Experience must be an array',
        },
      )
      .min(1, 'Resume must have at least 1 experience to enhance'),
    education: z.array(
      z.object({
        id: z
          .number({
            message: 'Education ID must be a number',
          })
          .min(0, 'Education ID must be at least 0'),
        notable_courses: z.array(
          z.object({
            idx: z
              .number({
                message: 'Education Notable Courses index must be a number',
              })
              .min(0, 'Education Notable Courses index must be at least 0'),
            text: z
              .string({
                message: 'Education Notable Courses text must be a string',
              })
              .min(3, 'Education Notable Courses must be at least 3 characters')
              .max(
                MAX_NOTABLE_COURSES_LENGTH,
                `Education Notable Courses must be at most ${MAX_NOTABLE_COURSES_LENGTH} characters`,
              ),
          }),
          {
            message: 'Education Notable Courses must be an array',
          },
        ),
      }),
      {
        message: 'Education must be an array',
      },
    ),
    skills: z
      .array(
        z.object({
          name: z
            .string({
              message: 'Skills must be a string',
            })
            .min(3, 'Skill Name must be at least 3 characters')
            .max(25, 'Skill Name must be at most 25 characters'),
          type: z
            .enum(SKILL_TYPES, {
              message: `Skill Type must be one of ${SKILL_TYPES.join(', ')}`,
            }),
        }),
        {
          message: 'Skills must be an array',
        },
      )
      .min(1, 'Resume must have at least 1 skill to enhance'),
  }) satisfies SchemaFromInterface<ParsedEnhancementResume>,
})

export const editResumeSchema = z.object({
  nickname: z
    .string({
      message: 'Resume Nickname must be a string',
    })
    .min(3, 'Resume Nickname must be at least 3 characters')
    .max(50, 'Resume Nickname must be at most 50 characters'),

  name: z
    .string({
      message: 'Name must be a string',
    })
    .min(3, 'Name must be at least 3 characters')
    .max(50, 'Name must be at most 50 characters'),

  summary: z
    .string({
      message: 'Summary must be a string',
    })
    .max(
      MAX_SUMMARY_LENGTH,
      `Summary must be at most ${MAX_SUMMARY_LENGTH} characters`,
    )
    .nullable()
    .optional(),

  email: z.string().email('Invalid Email Address'),
  phone: z
    .string({
      message: 'Invalid Phone Number',
    })
    .regex(RGX_PHONE_NUMBER, 'Phone number is not valid')
    .nullable()
    .optional(),

  location: z
    .string({
      message: 'Location must be a string',
    })
    .min(3, 'Location must be at least 3 characters')
    .max(75, 'Location must be at most 75 characters')
    .nullable()
    .optional(),
  portfolio: z
    .union([
      z.string().url({
        message: 'Portfolio Url is not valid',
      }),
      z.literal(''),
    ])
    .nullable()
    .optional(),
  linkedin: z
    .union([
      z.string().url({
        message: 'LinkedIn Url is not valid',
      }),
      z.literal(''),
    ])
    .nullable()
    .optional(),
  github: z
    .union([
      z.string().url({
        message: 'Github Url is not valid',
      }),
      z.literal(''),
    ])
    .nullable()
    .optional(),

  experience: z
    .array(
      z.object({
        position: z
          .string({
            message: 'Experience Position must be a string',
          })
          .min(3, 'Experience Position must be at least 3 characters')
          .max(50, 'Experience Position must be at most 50 characters'),

        company: z
          .string({
            message: 'Experience Company must be a string',
          })
          .min(3, 'Experience Company must be at least 3 characters')
          .max(50, 'Experience Company must be at most 50 characters'),

        location: z
          .string({
            message: 'Experience Location is required',
          })
          .min(3, 'Experience Location must be at least 3 characters')
          .max(50, 'Experience Location must be at most 50 characters'),

        start_date: z.union(
          [
            z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
            z.string().datetime({ offset: true }),
          ],
          {
            message: 'Experience Start Date must be a valid date',
          },
        ),

        end_date: z
          .union(
            [
              z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
              z.string().datetime({ offset: true }),
            ],
            {
              message: 'Experience End Date must be a valid date',
            },
          )
          .nullable()
          .optional(),

        is_current: z
          .boolean({
            message: 'Experience Is Current must be a TRUE or FALSE',
          })
          .optional(),

        responsibilities: z
          .array(
            z.object({
              text: z
                .string({
                  message: 'Experience Responsibility must be a string',
                })
                .min(
                  3,
                  'Experience Responsibility must be at least 3 characters',
                )
                .max(
                  MAX_RESPONSIBILITY_LENGTH,
                  `Experience Responsibility must be at most ${MAX_RESPONSIBILITY_LENGTH} characters`,
                ),
            }),
          )
          .min(1, 'Experience Responsibility is required')
          .max(10, 'Experience Responsibility must be at most 10 items'),
      }),
    )
    .max(
      MAX_EXPERIENCE_NUMBER,
      `Experience must be at most ${MAX_EXPERIENCE_NUMBER} items`,
    ),

  education: z
    .array(
      z.object({
        certification: z
          .string({
            message: 'Education Certification must be a string',
          })
          .min(3, 'Education Certification must be at least 3 characters')
          .max(50, 'Education Certification must be at most 50 characters'),

        institution: z
          .string({
            message: 'Education Institution must be a string',
          })
          .min(3, 'Education Institution must be at least 3 characters')
          .max(50, 'Education Institution must be at most 50 characters'),

        field_of_study: z
          .string({
            message: 'Education Field of Study must be a string',
          })
          .min(3, 'Education Field of Study must be at least 3 characters')
          .max(50, 'Education Field of Study must be at most 50 characters')
          .nullable()
          .optional(),

        location: z
          .string({
            message: 'Education Location must be a string',
          })
          .min(3, 'Education Location must be at least 3 characters')
          .max(50, 'Education Location must be at most 50 characters')
          .nullable()
          .optional(),

        start_date: z.union(
          [
            z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
            z.string().datetime({ offset: true }),
          ],
          {
            message: 'Education Start Date must be a valid date',
          },
        ),

        end_date: z
          .union(
            [
              z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
              z.string().datetime({ offset: true }),
            ],
            {
              message: 'Education End Date must be a valid date',
            },
          )
          .nullable()
          .optional(),

        notable_courses: z
          .array(
            z.object({
              text: z
                .string({
                  message: 'Education Notable Courses must be a string',
                })
                .min(
                  3,
                  'Education Notable Courses must be at least 3 characters',
                )
                .max(
                  MAX_NOTABLE_COURSES_LENGTH,
                  `Education Notable Courses must be at most ${MAX_NOTABLE_COURSES_LENGTH} characters`,
                ),
            }),
          )
          .max(10, 'Education Notable Courses must be at most 10 items'),

        awards: z
          .array(
            z
              .string({
                message: 'Awards must be a string',
              })
              .min(3, 'Education Awards must be at least 3 characters')
              .max(
                MAX_AWARD_LENGTH,
                `Education Awards must be at most ${MAX_AWARD_LENGTH} characters`,
              ),
          )
          .max(10, 'Awards must be at most 10 items'),
      }),
    )
    .max(
      MAX_EDUCATION_NUMBER,
      `Education must be at most ${MAX_EDUCATION_NUMBER} items`,
    ),

  skills: z
    .array(
      z.object({
        name: z
          .string({
            message: 'Skill Name must be a string',
          })
          .min(3, 'Skill Name must be at least 3 characters')
          .max(25, 'Skill Name must be at most 25 characters'),

        type: z
          .enum(SKILL_TYPES, {
            message: `Skill Type must be one of ${SKILL_TYPES.join(', ')}`,
          })
          .default('hard'),
      }),
      {
        message: 'Skills must be an array',
      },
    )
    .min(1, 'At least one skill is required')
    .max(
      MAX_SKILLS_NUMBER,
      `Skills must be at most ${MAX_SKILLS_NUMBER} items`,
    ),
  is_public: z
    .boolean({
      message: 'Is Public must be a TRUE or FALSE',
    })
    .optional(),
  score: z
    .number({
      message: 'Score must be a number',
    })
    .nullable()
    .optional(),
  style: z
    .enum(RESUME_STYLES, {
      message: `Resume Style must be one of ${RESUME_STYLES.join(', ')}`,
    })
    .default('modern'),
})

// ////////////////////////
// Profile Settings Form
// ///////////////////////

export const profileSettingsSchema = z.object({
  name: z
    .string({
      message: 'Name must be a string',
    })
    .min(2, 'Name must be at least 2 characters')
    .max(50, 'Name must be at most 50 characters'),

  email: z.string().email('Invalid Email Address'),

  phone: z
    .union([
      z.string().regex(RGX_PHONE_NUMBER, 'Phone number is not valid'),
      z.literal(''),
    ])
    .nullable()
    .optional(),

  location: z
    .union([
      z
        .string()
        .min(3, 'Location must be at least 3 characters')
        .max(75, 'Location must be at most 75 characters'),
      z.literal(''),
    ])
    .nullable()
    .optional(),

  portfolio: z
    .union([
      z.string().url({
        message: 'Portfolio Url is not valid',
      }),
      z.literal(''),
    ])
    .nullable()
    .optional(),

  linkedin: z
    .union([
      z.string().url({
        message: 'LinkedIn Url is not valid',
      }),
      z.literal(''),
    ])
    .nullable()
    .optional(),

  github: z
    .union([
      z.string().url({
        message: 'Github Url is not valid',
      }),
      z.literal(''),
    ])
    .nullable()
    .optional(),
})

// ////////////////////
// Resume Upload Form
// ///////////////////

export const MAX_RESUME_UPLOAD_FILE_SIZE = 5 * 1024 * 1024 // 5MB
export const ACCEPTED_RESUME_UPLOAD_FILE_STRINGS = ['.pdf', '.doc', '.docx']
export const ACCEPTED_RESUME_UPLOAD_FILE_TYPES = [
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
]

export const uploadResumeSchema = z.object({
  file: z
    .instanceof(File, { message: 'Please select a file.' })
    .refine(file => file.size <= MAX_RESUME_UPLOAD_FILE_SIZE, {
      message: `Max file size is ${formatBytes(MAX_RESUME_UPLOAD_FILE_SIZE)}MB`,
    })
    .refine(file => ACCEPTED_RESUME_UPLOAD_FILE_TYPES.includes(file.type), {
      message: `Only ${ACCEPTED_RESUME_UPLOAD_FILE_STRINGS.join(', ')} files are accepted`,
    }),
})
