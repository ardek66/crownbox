import posix, posix_utils, os

proc utimensat*(fd: int, path: cstring, times: ptr array[2, TimeSpec], flags: cint): cint{.importc, header:"<sys/stat.h>".}
proc read*(fd: cint, buf: pointer, count: cint): cint {.importc.}

var
  UTIME_OMIT*{.importc, header:"<sys/stat.h>".}: cint
  UTIME_NOW*{.importc, header:"<sys/stat.h>".}: cint
  AT_FDCWD*{.importc, header:"<fcntl.h>".}: cint

proc isDotDot*(filename: string): bool =
  let base = filename.extractFileName
  return base == "." or base == ".."

iterator readDir*(dirname: string): string =
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

proc isDir*(filename: string): bool =
  let stat = stat(filename)
  return S_ISDIR(stat.st_mode)
