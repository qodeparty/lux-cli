#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

import os
import sys
import re

from subprocess import check_output
from shassert import assert_shell_perms, assert_file_exists
from filetools import rem_file, rename_file
from strtools import line_marker, line_comment, date_comment

from term import debug, err, warn, info, ok, silly, rainbow, \
								 term_const, NL, SP, RET

#===========================================================

def sed_esc(st):
  assert_shell_perms('sed')
  pattern=r"s/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n"
  cmd=f'sed -e "{pattern}" <<< "{st}" | tr -d "\n"'
  res=check_output([f'{cmd}'],shell=True)
  return res


def sed_fcmd(cmd, src, **options):
  assert_shell_perms('sed')
  assert_file_exists(src)
  res=check_output([f'{cmd}'],shell=True)
  rem_file(f'{src}.bak')
  return res

def sed_add_block( open_st, close_st, data, src, force=False ):
	assert_shell_perms('sed')
  #add date string to data prior to add block
  out_str=(f"{open_st}{NL}"
           f"{data}{NL}"
           f"{close_st}{NL}")
  found = sed_find_block( open_st, close_st, src )
  if force or not found:
    with open(src, "a") as dest:
      dest.write(out_str)
  else:
    warn('Block already found. Not adding!')

def sed_delete_block(open_st, close_st, src, verify=False):
	assert_shell_perms('sed')
  pattern=f'/{open_st}/,/{close_st}/d'
  cmd=f'sed -i.bak "{pattern}" {src}'
  res=sed_fcmd(cmd,src)
  info(f' Deleting block [{open_st}] on {src} {res}')



def sed_replace_kv(key, new_val, src):
	assert_shell_perms('sed')
  quotes='([\'\\"])?' #tricky use quote if found
  pattern=fr's|^\s*(export )?{key}\={quotes}[^=]*$|\1{key}=\2{new_val}\2|'
  cmd=fr'sed -r -i.bak "{pattern}" {src}'
  res=sed_fcmd(cmd,src)
  info(f' Replacing key[{key}] with value[{new_val}] on {src} {res}')


def sed_find_block(open_st, close_st, src):
	assert_shell_perms('sed')
  pattern=f'/{open_st}/,/{close_st}/p'
  cmd=f'sed -n "{pattern}" {src}'
  res=sed_fcmd(cmd,src)
  if res: ok(f'Found block {open_st}')
  else: err(f'Did not find block {open_st}')
  return True if res else False

'''replace string with entire file contents'''
def sed_insert_file_where(where, insert, src):
	assert_shell_perms('sed')
  pattern=f'/{where}/r {insert}'
  cmd=f'sed -e "{pattern}" -e /{where}/d {src}'
  res=sed_fcmd(cmd,src)
  src_new=f'{src}.new'
  with open(src_new, 'wb') as dest:
    dest.write(res)
  info(f' Attempting insert of [{where}] on {src} {res.decode()}')
  rename_file(src_new,src)


def sed_replace_range(): pass
#sed "${startrow},${endrow}s/.*/Nan/" file.txt

def sed_replace_all():
  pass

def sed_replace_line():
  pass


#res=$( perl -n -e'/^(export)?\s?([[:alnum:]_\.]+)=([^=]*)/ && print "$2 \n"' "$1")


#===========================================================



#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
  	assert_shell_perms('sed')
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

    sed_add_block(*line_marker('hey girl', 'sh'), f'''{date_st}{NL}
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

