import parseopt
import utils, utils/[cat, echo]

var utilsTable = newUtilsTable()
utilsTable.registerUtils:
  cat
  echo

var p = initOptParser()
p.next
if p.key.len > 0:
  try: utilsTable[p.key](p.remainingArgs)
  except KeyError: echo "Command '", p.key, "' is not defined."
else:
  echo "Available commands:"
  for key in utilsTable.keys:
    echo key
