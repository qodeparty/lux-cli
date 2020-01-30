#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

import os
import sys
import re

from base import UserError

#===========================================================

class ShellPermissionError(UserError):
  pass

def assert_shell_perms(name):
  perm = os.environ.get('ENABLE_PYTHON_SHELL_ACCESS')
  if not perm:
    msg=f'{rainbow.RED}Python shell access must be enabled for [{name}] command.{term_const.RESET}'
    raise ShellPermissionError(msg)

def assert_file_exists(file):
  if not exists_file(file):
    msg=f'{rainbow.RED}Required file {file} not found. Command not run.{term_const.RESET}'
    raise FileNotFoundError(msg)

#===========================================================