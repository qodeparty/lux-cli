#!/usr/bin/env python3
# coding: utf-8
# by QODENINJA

#--------------------------------

import os
import sys
import pprint

from const import const;
from tools import esc_attr, NL

#===========================================================



#===========================================================
stdout = sys.stdout.write
stderr = sys.stderr.write


def is_piped():
  return True if os.fstat(0) != os.fstat(1) else False;

#--------------------------------
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
#===========================================================



#===========================================================
pp  = pprint.PrettyPrinter(indent=4)
ppe = pprint.PrettyPrinter(indent=4,stream=sys.stderr)
#--------------------------------
def pretty(text):
  if text: pp.pprint(text)

def epretty(text):
  if text: ppe.pprint(text)
#===========================================================



#===========================================================
class Printable(object):
    def __str__(self):
        lines = [self.__class__.__name__ + ':']
        for key, val in vars(self).items():
            lines += '{}: {}'.format(key, val).split('\n')
        return '\n    '.join(lines)
#===========================================================



#===========================================================

def print_bar(label,style=None):
  bar='{0:-^80}'.format(label)
  if style is None:
    eprint('{}{}'.format(const.NL,bar))
  else:
    eprint('{}{}{}{}'.format(const.NL,style,bar,const.RESET))

#===========================================================




 #===========================================================
#sort of like a unit test lol
def unit_test():
  try:
  	eprint('Eprint test')
  	stderr('Standard Error\n')
  	print('Print test')
  	stdout('Standard Out\n')
  	print_bar('PrintBar Test')

  except KeyboardInterrupt:
    info('\nDone')


#===========================================================

if __name__ == '__main__':
  import sys
  status = unit_test()
  sys.exit(status)

#--------------------------------