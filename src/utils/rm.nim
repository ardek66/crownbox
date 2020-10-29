import posix, posix_utils, os
import parseopt
import private/errors

type
  BitFlag {.size: sizeof(cint).} = enum
    R
  BitFlags = set[BitFlag]

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

proc rmProc*(args: varargs[string]) =
  usage "rm file1 file2..."
  var options: string
  for arg in args: options = options & " " & arg
  
  var
    p = initOptParser(options)
    flags: BitFlags
  
  for kind, key, val in p.getopt():
    case kind:
    of cmdShortOption:
      case key:
      of "r": flags.incl R
    of cmdArgument:
      if key.isDotDot: continue
      try:
        if R in flags: rmRecurse(key)
        else: rmFileOrEmpty(key)
      except OSError:
        cError -1, "Could not remove file or directory"
    else: discard
