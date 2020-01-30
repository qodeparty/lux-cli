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

#===========================================================

class ShellPermissionError(UserError):
  pass

def assert_shell_perms(name):
  perm = environ.get('ENABLE_PYTHON_SHELL_ACCESS')
  if not perm:
    msg=f'{rainbow.RED}Python shell access must be enabled for [{name}] command.{term_const.RESET}'
    raise ShellPermissionError(msg)

#===========================================================