import parseopt, os
import utils, utils/[cat, echo, touch, rm]

var utilsTable = newUtilsTable()
utilsTable.registerUtils:
  cat
  echo
  touch
  rm

setStdioUnbuffered()

proc runCommand(name: string, args: varargs[string]) =
  if name in utilsTable:
    utilsTable[name](args)
  else:
    stderr.writeLine "Command '", name, "' is not defined."
    quit 1

let cmd = paramStr(0).extractFilename
if cmd == "crownbox":
  var p = initOptParser()
  p.next
  if p.key.len > 0:
    runCommand(p.key, p.remainingArgs)
  else:
    echo "Available commands:"
    for key in utilsTable.keys:
      echo key
else:
  runCommand(cmd, commandLineParams())
