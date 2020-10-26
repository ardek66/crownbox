import posix

template cError*(messages: varargs[string]): untyped =
  for msg in messages: stderr.write msg
  stderr.write ".\n"
  return

template cError*(err: int, message: string): untyped =
  if err < 0:
    cError message, ": ", $strerror(errno)
