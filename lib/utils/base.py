#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

from os import path
import sys


#===========================================================
if __name__ == '__main__':
  module_path = path.abspath(path.join('..'))
  if module_path not in sys.path:
    sys.path.append(module_path)
#===========================================================

#--------------------------------

class SafeHash(dict):
  def __missing__(self,key):
    return False

#--------------------------------

class UserError(Exception):
  pass


#===========================================================
#sort of like a unit test lol
def unit_test():
	my = SafeHash()
	print(my)

#===========================================================

if __name__ == '__main__':
  status = unit_test()
  sys.exit(status)

#--------------------------------