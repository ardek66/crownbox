import private/[errors, helpers]

const MaxBuffLen = 2048

proc cat(filename: string) =
  var f: File
  try:
    f = if filename == "-": stdin
        else: open(filename)
  except IOError:
    cError -1, "Could not open file '" & filename & "'"
    
  var
    buffer: array[MaxBuffLen, char]
    buffLen = buffer.len
  
  while buffLen > 0:
    buffLen = read(f.getOsFileHandle, addr buffer, buffer.len.cint)
    if stdout.writeBuffer(addr buffer, buffLen) < buffLen:
      stderr.write "Could not write buffer.\n"
  
proc catProc*(args: varargs[string]) =
  if args.len < 1:
    cat "-"
    return
  
  for arg in args: cat arg
