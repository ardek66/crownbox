import posix

proc cError*(messages: varargs[string]) =
  for msg in messages: stderr.write msg
  stderr.write "\n"
  quit 1

proc cError*(err: int, message: string) =
  if err < 0:
    cError message, ": ", $strerror(errno)

template usage*(message: string): untyped =
  if args.len < 1:
    cError "USAGE: ./crownbox ", message
