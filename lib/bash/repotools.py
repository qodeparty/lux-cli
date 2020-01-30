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

from term import debug, err, warn, info, ok, silly, rainbow, const, NL
from utils import UserError
from shassert import assert_shell_perms
from filetools import assert_file_exists, exists_file, rem_file


#===========================================================

def git_build_id( cwd ): pass
#cd $src;git rev-list HEAD --count)

def git_branch_name( cwd ): pass
#cd $src;git rev-parse --abbrev-ref HEAD)

def git_vers( cwd ): pass
#cd $src;git describe --abbrev=0 --tags

def git_find_repos(): pass
#buf=($(find_dirs "git" "${this}/")); ret=$?

#===========================================================

