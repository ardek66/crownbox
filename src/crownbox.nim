import parseopt, tables, macros
import utils/cat

macro registerUtils(t: var TableRef[string, proc(args: varargs[string])],
                    body: untyped): untyped =
  body.expectKind nnkStmtList
  for node in body:
    let
      id = node.strVal
      procName = ident(id & "Proc")
    
    result = quote do:
      `t`[`id`] = `procName`

var utilsTable = newTable[string, proc(args: varargs[string])]()
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
