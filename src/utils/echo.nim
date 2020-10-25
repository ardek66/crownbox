proc echoProc*(args: varargs[string]) =
  var newLine = true
  for i, arg in args:
    if arg == "-n" and i == 0:
      newLine = false
      continue
    
    stdout.write arg
    if i < args.high: stdout.write ' '
    
  if newLine: stdout.write '\n'
