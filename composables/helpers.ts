import { DateTime } from 'luxon'

export function formatDateString(date: string, format = 'DD', returnNullIfInvalid = false): string | null {
  if (!date) {
    return returnNullIfInvalid ? null : '-'
  }

  return DateTime.fromISO(date).toFormat(format)
}

export function sentenceCase(str: string) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function formatBytes(bytes: number, decimals = 2) {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const dm = decimals < 0 ? 0 : decimals
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
}

export async function copyToClipboard(str: string, title = 'Copied to clipboard', description?: string) {
  const toast = useToast()
  if (!navigator.clipboard) {
    alert('Clipboard API not supported')
    return
  }

  await navigator.clipboard.writeText(str).catch(console.error)
  toast.add({
    title,
    description,
    color: 'success',
  })
}
