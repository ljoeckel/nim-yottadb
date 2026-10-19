import std/strutils

func bufferToString(p: ptr UncheckedArray[char], len: int): string =
  result = newString(len)
  if len > 0:
    copyMem(addr result[0], p, len)

func parseFastInt*(p: ptr UncheckedArray[char], len: int): int =
  # Fast path for plain base-10 integers read directly from a YottaDB buffer
  # (no string allocation). Falls back to strutils.parseInt for anything else.
  if len == 0:
    return parseInt("")
  var i = 0
  var neg = false
  if p[0] == '-': neg = true; inc i
  elif p[0] == '+': inc i
  if i == len:
    return parseInt(bufferToString(p, len))     # just "-" / "+"
  var r = 0
  while i < len:
    let c = p[i]
    if c < '0' or c > '9':
      return parseInt(bufferToString(p, len))   # non-digit -> fallback
    let d = ord(c) - ord('0')
    if r > (high(int) - d) div 10:
      return parseInt(bufferToString(p, len))   # overflow -> fallback
    r = r * 10 + d
    inc i
  if neg: -r else: r

func parseFastInt*(s: string): int =
  # Same as above for strings; delegates so both paths stay in sync.
  if s.len == 0:
    return parseInt(s)
  parseFastInt(cast[ptr UncheckedArray[char]](unsafeAddr s[0]), s.len)



func parseFastFloat*(s: string): float =
  # Fast path for plain decimals: [sign] digits [. digits]  (no exponent).
  # Falls back to strutils.parseFloat for anything unusual (e/E, inf, nan, ...).
  let L = s.len
  if L == 0: return parseFloat(s)
  var i = 0
  var neg = false
  if s[0] == '-': neg = true; inc i
  elif s[0] == '+': inc i

  var ip = 0.0
  var digits = 0
  while i < L and s[i] >= '0' and s[i] <= '9':
    if digits >= 14: return parseFloat(s)   # precision guard
    ip = ip * 10.0 + float(ord(s[i]) - ord('0'))
    inc i; inc digits

  var frac = 0.0
  var scale = 1.0
  if i < L and s[i] == '.':
    inc i
    while i < L and s[i] >= '0' and s[i] <= '9':
      if digits >= 14: return parseFloat(s) # precision guard
      frac = frac * 10.0 + float(ord(s[i]) - ord('0'))
      scale *= 10.0
      inc i; inc digits

  if digits == 0 or i != L:
    return parseFloat(s)                    # no digits / trailing junk / exponent

  let r = ip + frac / scale
  if neg: -r else: r


func parseFastBool*(s: string): bool =
  # case-insensitive "1", "T", "TRUE" without allocating an upper-case copy
  if s.len == 1:
    return s[0] == '1' or s[0] == 'T' or s[0] == 't'
  if s.len == 4:
    return (s[0] == 't' or s[0] == 'T') and
           (s[1] == 'r' or s[1] == 'R') and
           (s[2] == 'u' or s[2] == 'U') and
           (s[3] == 'e' or s[3] == 'E')
  false

