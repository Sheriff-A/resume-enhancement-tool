import type { ClassNameValue } from 'tailwind-merge'

export interface LVFormFieldWrapperProps {
  label: string
  name?: string
  required?: boolean
  help?: string
  hint?: string
  description?: string
  loading?: boolean
  ffUi?: {
    root?: ClassNameValue
    wrapper?: ClassNameValue
    labelWrapper?: ClassNameValue
    label?: ClassNameValue
    container?: ClassNameValue
    description?: ClassNameValue
    error?: ClassNameValue
    hint?: ClassNameValue
    help?: ClassNameValue
  }
}

export interface UBadgeProps {
  label: string
  color?:
    | 'success'
    | 'error'
    | 'primary'
    | 'secondary'
    | 'warning'
    | 'info'
    | 'neutral'
  variant?: 'outline' | 'solid' | 'soft' | 'subtle'
}
