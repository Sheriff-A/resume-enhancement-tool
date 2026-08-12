export const useRapidAPI = (host: string) => {
  const {rapidApiKey} = useRuntimeConfig()
  return {
    headers: {
      'X-RapidAPI-Key': rapidApiKey,
      'X-RapidAPI-Host': host
    }
  }
}

export async function safeRapidAPIRequest<T>(url: string, query: object, params: object, host: string): Promise<T> {
  const config = useRapidAPI(host)
  try {
    return await $fetch<T>(url, {
      method: 'GET',
      ...config,
      query,
      params
    })
  } catch (err: any) {
    console.error('[RapidAPI Error]', err?.message || err)
    if (err?.response?.status === 429) {
      throw createError({
        statusCode: 429,
        statusMessage: 'Rate limit exceeded — please try again later'
      })
    }
    if (err?.response?.status === 401 || err?.response?.status === 403) {
      throw createError({
        statusCode: 401,
        statusMessage: 'RapidAPI unauthorized'
      })
    }
    throw createError({
      statusCode: 500,
      statusMessage: 'An unexpected error occurred while processing your request'
    })
  }
}
