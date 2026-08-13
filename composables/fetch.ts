import { appendResponseHeader } from 'h3'
import type { H3Event } from 'h3'
import type { NitroFetchOptions } from 'nitropack/types'

export const fetchWithCookie = async <T>(event: H3Event, url: string, opts?: NitroFetchOptions<string,
  'head'
  | 'delete'
  | 'get'
  | 'patch'
  | 'post'
  | 'put'
  | 'connect'
  | 'options'
  | 'trace'
> | undefined): Promise<T> => {
  /* Get the response from the server endpoint */
  const res = await $fetch.raw(url, opts)
  /* Get the cookies from the response */
  const cookies = res.headers.getSetCookie()
  /* Attach each cookie to our incoming Request */
  for (const cookie of cookies) {
    appendResponseHeader(event, 'set-cookie', cookie)
  }
  /* Return the data of the response */
  return res._data as T
}
