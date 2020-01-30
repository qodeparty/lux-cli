#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

#--------------------------------

import os
import sys
import subprocess
import curses
import itertools
import pprint

stderr = sys.stderr.write

#--------------------------------

class SafeHash(dict):
  def __missing__(self,key):
    return False

