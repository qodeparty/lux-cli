#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

import os
import sys
import re

from datetime import datetime
from subprocess import check_output
from pathlib import Path
from shutil import move


#===========================================================
if __name__ == '__main__':
  module_path = os.path.abspath(os.path.join('..'))
  if module_path not in sys.path:
      sys.path.append(module_path)
#===========================================================

from term import debug, err, warn, info, ok, silly, rainbow, term_const, NL, SP, RET

#from sedtools import sed_find_block
from shassert import assert_shell_perms, assert_file_exists

#===========================================================







#===========================================================

def move_file(src,dest):
  try:
    assert_shell_perms('mv')
  except FileNotFoundError as e:
    pass

def rename_file(src,dest):
  try:
    assert_shell_perms('rename')
    os.rename(src,dest)
  except FileNotFoundError as e:
    pass

def rem_file(src):
  try:
    assert_shell_perms('rm')
    if exists_file(src): os.remove(src)
  except FileNotFoundError as e:
    err(f'File [{src}] does not exist.')


def exists_file(src):
  try:
    ref=Path(src)
    ret=ref.is_file()
  except FileNotFoundError as e:
    ret=False
  return ret


def exists_dir(src):
  try:
    ref=Path(src)
    ret=ref.is_dir()
  except FileNotFoundError as e:
    ret=False
  return ret

def get_homedir():
  return Path('~').expanduser()

#===========================================================






#===========================================================
def grep_cmd(cmd, src, **options):
  assert_shell_perms('grep')

def grep_filetype(): pass

#===========================================================



#===========================================================

def find_cmd(cmd, src, **options):
  assert_shell_perms('find')

def find_filetype(): pass
#   list=($($cmd_find "$LUX_HOME/www/${path}" -type f -name "*.${ftype}" ! -name '_*.*' -printf '%P\n' ))


  # function find_dirs(){
  #   info "Finding repo folders..."
  #   warn "This may take a few seconds..."
  #   this="$cmd_find ${2:-.} -mindepth 1"
  #   [[ $1 =~ "1" ]] && this+=" -maxdepth 2" || :
  #   [[ $1 =~ git ]] && this+=" -name .git"  || :
  #   this+=" -type d ! -path ."
  #   awk_cmd="awk -F'.git' '{ sub (\"^./\", \"\", \$1); print \$1 }'"
  #   cmd="$this | $awk_cmd"
  #   __print "$cmd"
  #   eval "$cmd" #TODO:check if theres a better way to do this
  # }

#===========================================================



#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    file='../.luxrc'
    file2='../.testme'
    sed_delete_block('### test #','### test #',file)
    sed_replace_kv('VAL2','moop',file)
    sed_replace_kv('VAL3','soop',file)
    sed_replace_kv('XY','999', file)

    print(line_comment('hey girl', 'js'))
    print(line_marker('hello', 'sh')[0])
    print(line_marker('hello', 'sh')[1])

    print(sed_find_block(*line_marker('hello', 'sh'),file))

    date_st = date_comment( 'sh', 'Last Updated')

    add_block(*line_marker('hey girl', 'sh'), f'''{date_st}{NL}
      # you know I like that pussy
    ''', file, False)

    sed_insert_file_where('\#include_me',file2,file)

    return 0
  except KeyboardInterrupt:
    info('\nDone')

#===========================================================

if __name__ == '__main__':
  import sys
  status = unit_test()
  sys.exit(status)

#--------------------------------
