export default defineEventHandler((event): string => {

  // Any uncaught errors will return a 500 Internal Server Error HTTP Error.
  // Use this to return other error codes with a custom message.
  // E.g. 400 Bad Request, 401 Unauthorized, etc.
  throw createError({
    statusCode: 400,
    statusMessage: "Failure Test Endpoint: Invalid Request",
  });
})