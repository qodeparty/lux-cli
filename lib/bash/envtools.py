#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

import os
import sys


from subprocess import Popen, PIPE


#===========================================================
if __name__ == '__main__':
  module_path = os.path.abspath(os.path.join('..'))
  if module_path not in sys.path:
      sys.path.append(module_path)
#===========================================================

from term import printer, eprint, stderr, debug, err, warn, info, ok, silly, NL, TAB, rainbow, term_const

from filetools import get_homedir
from strtools import line_marker
from shassert import assert_shell_perms, assert_file_exists
from sedtools import sed_add_block, sed_delete_block

#===========================================================
def source(rcfile, clean=False, update=False):
  assert_shell_perms('source')
  pipe = Popen("env -i sh -c 'set -a && source %s && env'" % rcfile, stdout=PIPE, shell=True)
  data = pipe.communicate()[0]
  env = dict((line.decode().split("=", 1) for line in data.splitlines()))
  cleanup_env(env)
  return env

def update_env(rcfile):
  environ = os.environ
  env = source(rcfile)
  environ.update(env)
  cleanup_env(environ)

def print_envars(env):
  keys = env.keys()
  lines = [' env :']
  for key in keys:
      lines += '{}: {}'.format(key, env.get(key)).split('\n')
  print('\n    '.join(lines))

def cleanup_env(env):
  try:
    del env['PWD']
    del env['_']
  except KeyError:
    pass

#===========================================================


#===========================================================
def profile_link(label, rcfile, profile ):
  homedir = get_homedir()
  profile_path = f'{homedir}/{profile}'
  mode='sh'
  date_st = date_comment( mode, 'Last Updated')
  out_st  = (
    f'{date_st}{NL}'
    f'if [ -f "{rcfile}" ] ; then{NL}'
    f'{TAB}source "{rcfile}"'
    f'else'
    f'{TAB}[ -t 1 ] && echo "{rainbow.blue}{rcfile} is missing, pylux link or unlink to fix {term_const.RESET}" ||:'
    f'fi'
  )
  add_block(*line_marker(label, mode), out_st, profile_path, False)
  return 0


def profile_unlink(label, profile):
  homedir = get_homedir()
  profile_path = f'{homedir}/{profile}'
  sed_delete_block(*line_marker(label, 'sh'), profile_path)



#===========================================================




#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    file='../.luxrc'
    file2='../.testme'
    env = source(file)
    print_envars(env)
    print(get_homedir())
    return 0
  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  import sys
  status = unit_test()
  sys.exit(status)
#--------------------------------

