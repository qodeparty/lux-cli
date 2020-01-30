#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

import os
import sys

#===========================================================
if __name__ == '__main__':
  module_path = os.path.abspath(os.path.join('..'))
  if module_path not in sys.path:
      sys.path.append(module_path)
#===========================================================

from term import debug, err, warn, info, ok, silly, rainbow, term_const, NL, SP

from base import UserError
from file import assert_shell_perms, exists_file, rem_file


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

