export default defineEventHandler((event) => {
  console.log('New Request: ' + getRequestURL(event))
})
