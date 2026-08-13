export const RGX_PHONE_NUMBER = /^(?:\+?(\d{1,3})[-. ]?)?(?:\(?\d{2,4}\)?[-. ]?)?\d{3,4}[-. ]?\d{4}$/

// At least one uppercase letter, one lowercase letter, one digit, one special character, and a minimum eight characters long
export const RGX_PASSWORD = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,64}$/
