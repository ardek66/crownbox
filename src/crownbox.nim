import parseopt
import utils, utils/cat

var utilsTable = newUtilsTable()
utilsTable.registerUtils:
  cat

var p = initOptParser()
p.next
if p.key.len > 0:
  try: utilsTable[p.key](p.remainingArgs)
  except KeyError: echo "Command '", p.key, "' is not defined."
else:
  echo "Available commands:"
  for key in utilsTable.keys:
    echo key
