#!/usr/bin/env python3
# coding: utf-8
# by QODENINJA

#--------------------------------


from os import path

#===========================================================
if __name__ == '__main__':
  module_path = path.abspath(path.join('..'))
  if module_path not in sys.path:
    sys.path.append(module_path)

  lib_path = path.abspath(path.join(path.dirname(__file__), '..'))
  if lib_path not in sys.path:
    sys.path.append(lib_path)
#===========================================================

from const   import const
from colors  import rainbow_const_fg as color
from printer import eprint, stderr, print_bar
from tools   import esc_nl

#===========================================================

def stylize(str, style, reset=True):
    terminator = const.RESET if reset is True else ''
    return "{}{}{}".format(style, str, terminator)

def cprint(str,c):
  stderr( stylize( str, c, True ) + "\n" )


#===========================================================



#===========================================================

def debug(x):
  cprint(x,color.GREY)

def err(x):
  cprint(const.FAIL + ' ' + x,color.ALTRED)

def warn(x):
  cprint(const.DELTA + ' ' +  x,color.YELLOW)

def info(x):
  cprint(const.LAMBDA + ' ' + x,color.BLUE)

def ok(x):
  cprint(const.PASS + ' ' +x,color.GREEN)

def silly(x):
  cprint(const.DOTS + ' ' +x,color.PINK)

def dump(x):
  pass

def prompt(x):
  pass


#===========================================================



#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    print_bar('Console Test')
    debug('try debug')
    info('try info')
    warn('try warn')
    err('try err')
    ok('try ok')
    silly('try silly')
    return 0
  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  import sys
  status = unit_test()
  sys.exit(status)
#--------------------------------


