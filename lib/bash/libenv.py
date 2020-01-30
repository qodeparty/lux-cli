#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY


import sys

from os import path, environ
from subprocess import Popen, PIPE


#===========================================================
if __name__ == '__main__':
  module_path = path.abspath(path.join('..'))
  if module_path not in sys.path:
    sys.path.append(module_path)

  lib_path = path.abspath(path.join(path.dirname(__file__), '..'))
  if lib_path not in sys.path:
    sys.path.append(lib_path)
#===========================================================


from term import printer, eprint, stderr, debug, err, warn, info, ok, silly, NL, TAB, rainbow, const as term

from libassert import assert_shell_perms
from libstr import line_marker, line_comment, date_comment
from libfile import rem_file, get_homedir, assert_file_exists
from libsed import sed_add_block, sed_delete_block, sed_add_line

test_profile="../../.testrc"

#===========================================================
def source(rcfile, clean=False, update=False):
  assert_shell_perms('source')
  pipe = Popen("env -i sh -c 'set -a && source %s && env'" % rcfile, stdout=PIPE, shell=True)
  data = pipe.communicate()[0]
  env = dict((line.decode().split("=", 1) for line in data.splitlines()))
  cleanup_env(env)
  return env

def update_env(rcfile):
  env = source(rcfile)
  environ.update(env)
  #cleanup_env(env)
  #print_envars(env)
  #print(vars(environ))

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

def save_env(env,src):
  keys = env.keys()
  for key in keys:
    #lines += '{}: {}'.format(key, env.get(key)).split('\n')
    sed_add_line("{}='{}'".format(key, env.get(key)),src)


#===========================================================


#===========================================================
def profile_link(label, rcfile, profile ):
  homedir = get_homedir()
  if not test_profile: profile_path = f'{homedir}/{profile}'
  else: profile_path=test_profile
  mode='sh'
  date_st = date_comment( mode, 'Last Updated')
  out_st  = (
    f'{date_st}{NL}'
    f'if [ -f "{rcfile}" ]; then{NL}'
    f'{TAB}source "{rcfile}"'
    f'{NL}else{NL}'
    f'{TAB}[ -t 1 ] && echo "{rainbow.BLUE} [{rcfile}] is missing, pylux link or unlink to fix {term.RESET}" ||:'
    f'{NL}fi'
  )
  sed_add_block(*line_marker(label, mode), out_st, profile_path, False)
  return 0


def profile_unlink(label, profile):
  homedir = get_homedir()
  if not test_profile: profile_path = f'{homedir}/{profile}'
  else: profile_path=test_profile
  sed_delete_block(*line_marker(label, 'sh'), profile_path)



#===========================================================




#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    file='../../.testrc'
    file2='../../.testme'
    file3='../../.morerc'
    file4='../../.saverc'
    env = source(file)
    environ.update(env)


    update_env(file3)

    print(get_homedir(),test_profile)
    profile_link('linker',file2,'.profile')
    profile_unlink('linker','.profile')

    print_envars(environ)
    rem_file(file4)
    save_env(environ,file4)

    return 0
  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  import sys
  status = unit_test()
  sys.exit(status)
#--------------------------------

