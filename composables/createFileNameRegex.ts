export function createFileNameRegex(allowedExtensions: string[]) {
  return new RegExp(
    '([a-zA-Z0-9\s_\\.\-:])+(' + allowedExtensions.join('|') + ')$',
  );
}
