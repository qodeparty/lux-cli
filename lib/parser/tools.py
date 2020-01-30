#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

from os import path

#===========================================================
if __name__ == '__main__':
  module_path = path.abspath(path.join('..'))
  if module_path not in sys.path:
    sys.path.append(module_path)

  lib_path = path.abspath(path.join(path.dirname(__file__), '..'))
  if lib_path not in sys.path:
    sys.path.append(lib_path)
#===========================================================



#===========================================================
"""

Lexer/Tokenizer Utils

"""
#===========================================================

""" boolean is leading comment """
def ignore_comment(line):
  if line[0] == '#' or line[0] in ' \t\r\n': return True #faster then regex
  return False

#----------
""" strip all strings """
def strip_list(st):
  st = [s.strip() for s in st]
  return st


#===========================================================
"""

utils that requrie a const

"""
#===========================================================

def parse_param(txt, config):
  delim = config.PARAM_DELIM
  if txt[0] == delim:
    d,param = txt.split(delim)
    return param
  return False

#----------

def parse_config(opt,data,config):

  data    = data.split(config.FIELD_DELIM) #faster than regex
  data    = strip_list(data)
  lendata = len(data)

  param   = parse_param(data[0], config) #get eng params first

  if(param and lendata>=2):
    key = data[1]
    val = data[2]
    desc = '' if lendata <= 3 else data[3]

    if param == config.META_PARAM:
      pass #not impl
    elif param == config.CONFIG_PARAM:
      skey = config.CONFIG_KEY
    elif param == config.TOKEN_PARAM:
      skey = config.RULES_KEY
    else:
      pass #not impls

    #print(param,skey,key,val)
    #print(opt)
    if skey:
      if not skey in opt:
        opt[skey] = {}
      opt[ skey ][ key ] = val

  else:
    pass #throw exception

  return opt



#----------

def read_lex_file(filename, config):
  opt = { config.RULES_KEY : {} } #default rules key _r
  with open(filename,'r') as f:
    for line in f:
      if ignore_comment(line): continue
      res = parse_config(opt, line, config)
  return opt

#----------
