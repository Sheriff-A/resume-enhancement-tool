import type { z } from 'zod'
import type { ZodError } from '~/models/general'

/**
 * Check if the data is valid according to the schema
 * @param schema the defined Zod schema
 * @param data the data to check
 *
 * @returns null if the data is valid, an array of error messages if not
 */
export function useZodCheck<T>(schema: z.ZodType, data: T): null | ZodError[] {
  const { success, error } = schema.safeParse(data)
  if (success) {
    return null
  }
  else {
    // If the schema validation fails, return an array of error messages
    console.log(error)
    return error?.issues.map((error: z.core.$ZodIssue) => ({
      message: error.message,
      path: error.path.join('_'),
    }))
  }
}
