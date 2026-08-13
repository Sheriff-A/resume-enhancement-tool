interface JSearchSuccess<T> {
  status: 'OK',
  request_id: string;
  data: T;
}

interface JSearchFail {
  status: 'ERROR',
  request_id: string;
  error: {
    code: number;
    message: string;
  };
}

export type JSearchResponse<T> = JSearchSuccess<T> | JSearchFail;

export function isJSearchSuccess<T>(response: JSearchResponse<T>): response is JSearchSuccess<T> {
  return response.status === 'OK';
}