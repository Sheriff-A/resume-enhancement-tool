export type EmploymentType = 'Full-time' | 'Part-time' | 'Contractor' | 'Internship' | 'Volunteer' | null
export type EmploymentTypes = 'FULLTIME' | 'PARTTIME' | 'CONTRACTOR' | 'INTERNSHIP' | 'VOLUNTEER' | null

export interface JSearchJob {
  job_id: string
  job_title: string
  employer_name: string
  employer_logo: string | null
  employer_website: string | null
  job_publisher: string
  job_employment_type: EmploymentType
  job_employment_types: EmploymentTypes[]
  job_apply_link: string
  job_apply_is_direct: boolean
  apply_options: {
    publisher: string
    apply_link: string
    is_direct: boolean
  }[]
  job_description: string
  job_is_remote: boolean
  job_posted_at: string | null // ISO 8601 date string
  job_posted_at_timestamp: number | null // Unix timestamp
  job_posted_at_datetime_utc: string | null // ISO 8601 date string in UTC
  job_location: string
  job_city: string | null
  job_state: string
  job_country: string
  job_latitude: number
  job_longitude: number
  job_benefits: string[] | null
  job_google_link: string
  job_salary?: number | null // Salary in the specified currency
  job_min_salary: number | null // Minimum salary in the specified currency
  job_max_salary: number | null // Maximum salary in the specified currency
  job_salary_period: string | null // e.g., 'yearly', 'monthly', 'hourly'
  job_highlights: {}
  job_onet_soc: string // O*NET SOC code
  job_onet_job_zone: string // O*NET job zone

  // CUSTOM FIELDS
  favourite?: boolean // Indicates if the job is a favourite
}
