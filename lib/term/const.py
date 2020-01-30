#!/usr/bin/env python3
# coding: utf-8
# by QODENINJA

#--------------------------------
import sys

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

from tools import esc_attr, esc_cls, esc_nl

#===========================================================

class TermConstants(object):
  def __init__(self):
    self.CLR   = esc_cls()
    self.RESET = esc_attr(0)
    self.BOLD  = esc_attr(1)
    self.UNDER = esc_attr(4)
    self.BLINK = esc_attr(5)
    self.REV   = esc_attr(7)
    self.CROSS = esc_attr(9)
    self.NL    = esc_nl()
    self.RETURN= esc_attr(13)
    self.PASS  = '\u2713'
    self.FAIL  = '\u2718'
    self.DELTA = '\u0394'
    self.ARROW = '\u00BB'
    self.LAMBDA = '\u03BB'
    self.DOTS   = '\u2026'
  def by(self,name):
    pass
  def list(self):
    return vars(self)


#--------------------------------
const  = TermConstants()

#===========================================================


if __name__ == '__main__':
  print(vars(const))
  sys.exit(0)
#--------------------------------
