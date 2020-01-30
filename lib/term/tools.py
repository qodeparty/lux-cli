#!/usr/bin/env python3
# coding: utf-8
# by QODENINJA

#--------------------------------


import sys


#===========================================================
# dont bother importing these just use fx()

NL  = "\x0a"
ESC = "\x1b"
FG  = "38;5;" #256 color
BG  = "48;5;"
END =  "m"
TAB = "\x09"
SP  = "\x20"
RET = "\x0d"
#===========================================================



#===========================================================

def esc(st):
	return ESC + st + END

def esc_cst(st):
  return ESC + '[' + st + END

#TODO:CLEANUP
def esc_attr(i,part=False):
  OPEN  = { True:'', False:ESC+'[' }[part]
  CLOSE = { True:'', False:END }[part]
  return OPEN + str(i) + CLOSE if i is not None else ''

def esc_fg(i,part=False):
  OPEN  = { True:'', False:ESC+'[' }[part] + FG
  CLOSE = { True:'', False:END }[part]
  return OPEN + str(i) + CLOSE if i is not None else ''

def esc_bg(i,part=False):
  OPEN  = { True:'', False:ESC+'[' }[part] + BG
  CLOSE = { True:'', False:END }[part]
  return OPEN + str(i) + CLOSE if i is not None else ''

#shift out
def esc_nl(i=None):
	return NL * i if i is not None else NL
  ##return ATR + str(i) + 'E' if i is not None else ''

def esc_sp(i=None):
	return SPC * i if i is not None else SP

def esc_tab(i=None):
	return TAB * i if i is not None else TAB

def esc_cls():
	return ESC + 'c'

# NOTE: use repr to get literal printable characters

#===========================================================



#===========================================================
""" generate full escape string based on ascii values """

def esc_str(color=None, bgcolor=None, style=None):
  nargs = len(locals())
  part  = (nargs>1)
  st=''
  if part:
    st += ESC+'['
  if color is not None:
    st = "{}{}".format(st,esc_fg(color,part))
  if bgcolor is not None:
    st = "{};{}".format(st,esc_bg(bgcolor,part))
  if style is not None:
    st = "{};{}".format(st,esc_attr(style,part))
  if part:
    st += END
  return st


 #===========================================================
#sort of like a unit test lol
def unit_test():
  try:
  	st_reset = esc_attr(0) #ascii reset
  	st_under = esc_attr(4) #ascii underline
  	st_blink = esc_attr(5) #ascii blink
  	print("{}I am underlined.{}".format(st_under,st_reset))
  	print("{}I am blinking.{}".format(st_blink,st_reset))
  	col_purp = esc_fg(5)
  	col_cyan = esc_fg(6)
  	print("{}I am purple.{}".format(col_purp,st_reset))
  	print("{}I am red.{}".format(col_cyan,st_reset))
  	back_purp = esc_bg(5)
  	back_cyan = esc_bg(6)
  	print("{}I am purple.{}".format(back_purp, st_reset))
  	print("{}I am cyan.{}".format(back_cyan,st_reset))
  	st_nl = esc_nl()
  	print("purp escape:{}".format(repr(back_purp)))
  	print("cls escape:{}".format(repr(esc_cls())))
  	print("nl escape:{}".format(repr(st_nl)))
  	print("{}{}I am on a newline.{}".format(st_nl,st_nl,st_reset))

  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  status = unit_test()
  sys.exit(status)
#--------------------------------


