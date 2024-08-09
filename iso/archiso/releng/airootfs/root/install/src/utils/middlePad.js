export default function middlePad(text, totalLength = 50, padChar = "=") {
  if (totalLength <= text.length) {
    return text;
  }

  const textLength = text.length;
  const padLength = totalLength - textLength;
  const padStart = Math.floor(padLength / 2);
  const padEnd = padLength - padStart;

  return padChar.repeat(padStart) + text + padChar.repeat(padEnd);
}
