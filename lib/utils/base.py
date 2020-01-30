#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

#--------------------------------

class SafeHash(dict):
  def __missing__(self,key):
    return False

#--------------------------------

class UserError(Exception):
  pass
