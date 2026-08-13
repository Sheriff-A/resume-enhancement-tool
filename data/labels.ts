import type { ApplicationStatus, JobType, SkillType } from '~/models/database'

export const ApplicationStatusLabels: Record<ApplicationStatus, string> = {
  accepted: 'Accepted',
  rejected: 'Rejection',
  withdrawn: 'Withdrawn',
  applied: 'Applied',
  interview: 'Interviewing',
  offered: 'Offered',
}

export const SkillTypeLabels: Record<SkillType, string> = {
  other: 'Other',
  soft: 'Inter-personal/Soft Skills',
  hard: 'Technical/Hard Skills',
}

export const JobTypeLabels: Record<JobType, string> = {
  full_time: 'Full-Time',
  part_time: 'Part-Time',
  contract: 'Contract',
  internship: 'Internship',
  volunteer: 'Volunteer',
  other: 'Other',
}
