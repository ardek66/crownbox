import posix, posix_utils
import parseopt

type
  BitFlag* {.size: sizeof(cint).} = enum
    C
    A
    M
  BitFlags = set[BitFlag]

proc utimensat(fd: int, path: cstring, times: ptr array[2, TimeSpec], flags: cint): cint{.importc, header:"<sys/stat.h>".}

var
  UTIME_OMIT{.importc, header:"<sys/stat.h>".}: cint
  UTIME_NOW{.importc, header:"<sys/stat.h>".}: cint
  AT_FDCWD{.importc, header:"<fcntl.h>".}: cint

proc touch(filename: string, flags: BitFlags) =
  var tStat: Stat
  
  try: tStat = stat(filename)
  except OSError:
    if C in flags:
      stderr.write "File '", filename, "' does not exist.\n"
      return
    
    let fd = open(filename, O_CREAT, S_IRUSR or S_IWUSR or S_IRGRP or S_IROTH)
    discard close(fd)
    if fd < 0:
      stderr.write "Could not create file '", filename, "'.\n"
      return
    
    tStat = stat(filename)

  var t: Time
  discard time(t)
  
  var ts: array[2, TimeSpec]
  ts[0] = TimeSpec(tv_sec: t, tv_nsec: UTIME_NOW)
  ts[1] = ts[0]

  if A in flags or M in flags:
    var sec = tStat.st_atime
    for i, flg in [A, M]:
      if flg notin flags:
        ts[i] = TimeSpec(tv_sec: sec, tv_nsec: UTIME_OMIT)
      sec = tStat.st_mtime
    
  if utimensat(AT_FDCWD, filename, addr ts, 0) < 0:
    stderr.write "Could not stat '", filename, "'.\n"
    return
    
    
proc touchProc*(args: varargs[string]) =
  if args.len < 1:
    echo "Usage: touch [-cam] files..."
    return
  
  var options: string
  for arg in args: options = options & " " & arg
  
  var
    p = initOptParser(options)
    flags: BitFlags
  
  for kind, key, val in p.getopt():
    case kind:
    of cmdShortOption:
      case key:
      of "c": flags.incl C
      of "a": flags.incl A
      of "m": flags.incl M
    of cmdArgument:
      touch(key, flags)
    else: discard
