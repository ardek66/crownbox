import tables, macros
export tables

template newUtilsTable*(): untyped =
  newTable[string, proc(args: varargs[string])]()

macro registerUtils*(table: untyped, body: untyped): untyped =
  body.expectKind nnkStmtList
  
  result = newStmtList()
  for node in body:
    let
      id = node.strVal
      procName = ident(id & "Proc")
    
    result.add quote do: `table`[`id`] = `procName`
