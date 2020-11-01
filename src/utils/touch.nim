from os import fileExists
import posix
import parseopt, times
import private/[errors, helpers]

type
  BitFlag* {.size: sizeof(cint).} = enum
    C
    A
    M
  BitFlags = set[BitFlag]

proc parseTimeToPosix(dateTime: string): posix.Time =
  var tm: Tm
  let parseDt = parse(dateTime, "YYYY-MM-dd/HH:mm:ss")

  tm.tm_sec = parseDt.second.cint
  tm.tm_min = parseDt.minute.cint
  tm.tm_hour = parseDt.hour.cint
  tm.tm_mday = parseDt.monthday.cint
  tm.tm_mon = ord(parseDt.month).cint - 1
  tm.tm_year = parseDt.year.cint - 1900
  
  result = mktime(tm)
  
proc touch(filename: string, flags: BitFlags, dateTime: string) =
  if not fileExists(filename):
    if C in flags:
      cError "File does not exist: '", filename, "'"
    
    let fd = open(filename, O_CREAT, S_IRUSR or S_IWUSR or S_IRGRP or S_IROTH)
    cError fd, "Could not create file '" & filename & "'"
    discard close(fd)

  var
    ns = UTIME_NOW
    ts: array[2, TimeSpec]
  
  if dateTime.len > 0:
    try:
      ts[0].tv_sec = parseTimeToPosix(dateTime)
      ns = 0
    except TimeParseError:
      cError "Invalid date/time. Format is: YYYY-MM-dd/HH:mm:ss"
  
  ts[0].tv_nsec = ns
  ts[1] = ts[0]
  
  if A in flags xor M in flags:
    let amFlagsInt = cast[cint](flags) shr 1
    ts[(amFlagsInt xor 3) - 1].tv_nsec = UTIME_OMIT
  
  cError utimensat(AT_FDCWD, filename, addr ts, 0),
                "Could not touch '" & filename & "'"

proc touchProc*(args: varargs[string]) =
  usage "touch [-cam] [-d YYYY-MM-dd/HH:mm:ss] file1 file2... "
  
  var options: string
  for arg in args: options = options & " " & arg
  
  var
    p = initOptParser(options)
    flags: BitFlags
    dateTime: string
  
  for kind, key, val in p.getopt():
    case kind:
    of cmdShortOption:
      case key:
      of "c": flags.incl C
      of "a": flags.incl A
      of "m": flags.incl M
      of "d": dateTime = val
    of cmdArgument:
      touch(key, flags, dateTime)
    else: discard
