const MaxBuffLen = 2048

proc read(fd: cint, buf: pointer, count: cint): cint {.importc.}

proc cat(f: File) =
  var
    buffer: array[MaxBuffLen, char]
    buffLen = MaxBuffLen
  while buffLen > 0:
    buffLen = read(f.getOsFileHandle, addr buffer, buffer.len.cint)
    if stdout.writeBuffer(addr buffer, buffLen) < buffLen:
      stderr.write "Could not write buffer.\n"
  
proc catProc*(args: varargs[string]) =
  if args.len < 1:
    cat stdin
    return

  for arg in args:
    var input: File
    if arg == "-": input = stdin
    else:
      try: input = open(arg)
      except IOError:
        stderr.write "Could not open '", arg, "'.\n"
        continue
    cat input
    close(input)
