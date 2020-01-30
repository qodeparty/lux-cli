#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY


import sys
from os import path, environ


#===========================================================
if __name__ == '__main__':
  module_path = path.abspath(path.join('..'))
  if module_path not in sys.path:
    sys.path.append(module_path)

  lib_path = path.abspath(path.join(path.dirname(__file__), '..'))
  if lib_path not in sys.path:
    sys.path.append(lib_path)
#===========================================================


from utils import UserError
from term import NL, rainbow, const as term
from constants import ENABLE_PYTHON_SHELL_ACCESS

#===========================================================

class ShellPermissionError(UserError):
  pass

def assert_shell_perms(name):
  perm = environ.get(ENABLE_PYTHON_SHELL_ACCESS)
  if not perm:
    msg=f'{rainbow.RED}Python shell access must be enabled for [{name}] command.{term.RESET}'
    raise ShellPermissionError(msg)
  else:
    return True

#===========================================================

class ShellEnvironError(UserError):
  pass

def assert_required_env(key=None):
  if key is not None:
    data = environ.get(key)
    if not data: data = environ.get(key.upper()) #case insen
    if not data:
      msg=f'{rainbow.RED}Required ENV variable [{key}] not defined.{term.RESET}'
      raise ShellEnvironError(msg)
    else:
      return data
  return True

#===========================================================


#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    assert_shell_perms('bash')
    assert_required_env('MOO')
    return 0
  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  status = unit_test()
  sys.exit(status)
#--------------------------------