import private/errors

proc echoProc*(args: varargs[string]) =
  usage "echo [-n] arg1 arg2 ..."
  
  var newLine = true
  for i, arg in args:
    if arg == "-n" and i == 0:
      newLine = false
      continue
    
    stdout.write arg
    if i < args.high: stdout.write ' '
    
  if newLine: stdout.write '\n'
