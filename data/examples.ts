import type { EnhanceResumeResults } from '~/models/server/resume';

export const sampleEnhancements: EnhanceResumeResults = {
  summary: {
    text: 'Experienced full-stack developer skilled in JavaScript, TypeScript, Vue.js, Node.js, and SQL databases. Proven ability to lead agile teams, deliver scalable software solutions, and collaborate effectively in remote environments. Passionate about continuous learning, ownership, and improving development practices.',
    confidence: 95,
  },
  experience: [
    {
      id: 20,
      responsibilities: [
        {
          action: 'update',
          idx: 1,
          text: 'Implemented custom data collection systems using Node.js and Directus, doubling company prospects by streamlining customer onboarding.',
          confidence: 90,
        },
        {
          action: 'update',
          idx: 2,
          text: 'Led QA coordination using Jira and Playwright for testing, bug tracking, and client UAT, ensuring reliable version releases.',
          confidence: 85,
        },
      ],
    },
    {
      id: 21,
      responsibilities: [
        {
          action: 'update',
          idx: 0,
          text: 'Developed internal software with Nuxt3 and TailwindCSS improving sales workflow, invoice generation, and quoting accuracy by 90%, reducing workload by 50%.',
          confidence: 90,
        },
        {
          action: 'update',
          idx: 1,
          text: 'Conducted code reviews as team lead on Vue 3 and TypeScript via Jira, ensuring adherence to coding standards and best practices.',
          confidence: 90,
        },
        {
          action: 'update',
          idx: 3,
          text: 'Built Node.js ETL pipelines migrating offline processes online for enhanced data collection and trend analysis.',
          confidence: 85,
        },
        {
          action: 'add',
          text: 'Built Node.js ETL pipelines migrating offline processes online for enhanced data collection and trend analysis.',
          confidence: 85,
        },
      ],
    },
    {
      id: 22,
      responsibilities: [
        {
          action: 'remove',
          idx: 0,
          reason:
            'Technical training on MS Active Directory is less relevant to the software developer role focused on full-stack development.',
          confidence: 80,
        },
      ],
    },
  ],
  skills: [
    {
      action: 'add',
      name: 'C#',
      type: 'hard',
      reason: 'Required skill for the job, currently missing from resume.',
      confidence: 100,
    },
    {
      action: 'add',
      name: '.NET Core',
      type: 'hard',
      reason:
        'Key technology in job description, not listed in current skills.',
      confidence: 100,
    },
    {
      action: 'add',
      name: 'PostgreSQL',
      type: 'hard',
      reason:
        'Important database technology mentioned in job description but missing from skills.',
      confidence: 95,
    },
    {
      action: 'add',
      name: 'SQL Server',
      type: 'hard',
      reason: 'Relevant relational database technology for the role.',
      confidence: 90,
    },
    {
      action: 'add',
      name: 'DevOps',
      type: 'hard',
      reason:
        'Job description emphasizes DevOps workflows and CI/CD pipelines.',
      confidence: 85,
    },
    {
      action: 'add',
      name: 'CI/CD pipelines',
      type: 'hard',
      reason: 'Relevant toolset for the role, aligns with job requirements.',
      confidence: 85,
    },
    {
      action: 'add',
      name: 'infrastructure-as-code',
      type: 'hard',
      reason:
        'Mentioned in job responsibilities, important for role alignment.',
      confidence: 80,
    },
    {
      action: 'add',
      name: 'test automation',
      type: 'hard',
      reason: 'Relevant to job duties and improves ATS keyword match.',
      confidence: 80,
    },
    {
      action: 'add',
      name: 'AWS',
      type: 'hard',
      reason: 'Cloud platform mentioned as a plus in job description.',
      confidence: 75,
    },
    {
      action: 'add',
      name: 'agile',
      type: 'soft',
      reason:
        'Agile development is emphasized in job description and demonstrated in experience.',
      confidence: 95,
    },
    {
      action: 'add',
      name: 'ownership',
      type: 'soft',
      reason: 'Core value and soft skill emphasized by employer.',
      confidence: 90,
    },
    {
      action: 'add',
      name: 'collaboration',
      type: 'soft',
      reason: 'Key soft skill required for the role and company culture.',
      confidence: 95,
    },
    {
      action: 'add',
      name: 'mentoring',
      type: 'soft',
      reason: 'Job description mentions mentoring peers as a responsibility.',
      confidence: 80,
    },
  ],
};
