import posix, posix_utils, os
import parseopt
import private/errors

var
  recurse, force: bool

proc isDotDot(filename: string): bool =
  let base = filename.extractFileName
  return base == "." or base == ".."

iterator readDir(dirname: string): string =
  let dirptr = opendir(dirname)
  
  var dirent = readdir(dirptr)
  while dirent != nil:
    var filename: string
    for c in dirent.d_name:
      if c == '\0': break
      filename.add c
    if not filename.isDotDot:
      yield filename
    dirent = readdir(dirptr)
  
  discard closedir(dirptr)

proc isDir(filename: string): bool =
  let stat = stat(filename)
  return S_ISDIR(stat.st_mode)

proc rmFileOrEmpty(filename: string) =
  if not force and access(filename, W_OK) < 0:
    stdout.write "Remove write-protected file '", filename, "'? "
    let answer = stdin.readLine
    if answer[0] in ['n', 'N']: return
  
  if filename.isDir:
    cError rmdir(filename), "Could not remove dir"
  else:
    cError unlink(filename), "Could not remove file"
  
proc rmRecurse(dirname: string) =
  var dirPath = dirname
  if dirPath[^1] != '/': dirPath.add '/'
  
  for file in dirname.readDir:
    let filePath = dirPath & file
    if filePath.isDir:
      rmRecurse(filePath)
      continue
    rmFileOrEmpty(filePath)
  rmFileOrEmpty(dirPath)

proc rm(filename: string) =
  if filename.isDotDot: return
  try:
    if recurse: rmRecurse(filename)
    else: rmFileOrEmpty(filename)
  except OSError:
    cError -1, "Could not remove '" & filename & "'"
  
proc rmProc*(args: varargs[string]) =
  usage "rm file1 file2..."
  var options: string
  for arg in args: options = options & " " & arg
  
  var p = initOptParser(options)
  
  for kind, key, val in p.getopt():
    case kind:
    of cmdShortOption:
      case key:
      of "r": recurse = true
      of "f": force = true
    of cmdArgument:
      rm(key)
    else: discard
