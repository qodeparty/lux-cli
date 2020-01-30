#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

from os import path
from datetime import datetime

#===========================================================
if __name__ == '__main__':
  module_path = path.abspath(path.join('..'))
  if module_path not in sys.path:
    sys.path.append(module_path)

  lib_path = path.abspath(path.join(path.dirname(__file__), '..'))
  if lib_path not in sys.path:
    sys.path.append(lib_path)
#===========================================================

from term import debug, err, warn, info, ok, silly, SP, NL


#===========================================================

def line_marker( label, mode='sh'):
  delim  = { 'js':['\\*','*\\'], 'sh':['#','#'], 'html':['<!-- ',' -->'] }[mode]
  str_st = f"{delim[0]} ----{label}:str---- {delim[1]}"
  end_st = f"{delim[0]} ----{label}:end---- {delim[1]}"
  return [ str_st, end_st ]

def line_comment( label, mode='sh' ):
  delim  = { 'js':'//%s', 'sh':'#%s', 'html':'<!-- %s -->' }[mode]
  return delim % (label)

def date_comment( mode, label=None ):
  now = datetime.now()
  label = label + SP if label is not None else ''
  date_st = line_comment( f'{label}{now.strftime("%a %m-%d-%Y at %I:%M:%S %p")}', mode )
  return date_st


#===========================================================
