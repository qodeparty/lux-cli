#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

import os
import sys
import json

#===========================================================
if __name__ == '__main__':
  module_path = os.path.abspath(os.path.join('..'))
  if module_path not in sys.path:
      sys.path.append(module_path)
#===========================================================

import argparse

from toktools import read_lex_file

from term2 import printer, eprint, stderr, debug, err, warn, info,\
                  ok, silly, rainbow as color, term_const as term,\
                  test_colors, test_printer, Printable



#===========================================================
"""
  LexEngine loads language file and generates tokens for input

"""
#===========================================================

class LexEngine(object):

  def __init__(self, **options):
    pass

  def next(self, data):
    pass


#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    print(sys.path)
  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  status = unit_test()
  sys.exit(status)
#--------------------------------
