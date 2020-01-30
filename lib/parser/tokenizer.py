#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

import os
import sys
import re

#===========================================================
if __name__ == '__main__':
  module_path = os.path.abspath(os.path.join('..'))
  if module_path not in sys.path:
      sys.path.append(module_path)
#===========================================================

from utils import SafeHash
from tools import read_lex_file


from term  import printer, eprint, stderr, debug, err, warn, info,\
                  ok, silly, Printable, create_swatch

#===========================================================
"""


"""
#===========================================================
#potential external config properties loaded before lexer

PROMPT_LABEL  = '>>'
PARAM_DELIM   = '$'
COMMENT_DELIM = '#'
FIELD_DELIM   = '|'
META_PARAM    = 'ENGINE'
CONFIG_PARAM  = 'CONF'
TOKEN_PARAM   = 'TOK'
RULES_KEY     = 'rules'
CONFIG_KEY    = 'config'

#===========================================================
"""


"""
#===========================================================

class TokenizerConfig(Printable):
  def __init__(self):
    self.META_PARAM    = META_PARAM
    self.CONFIG_PARAM  = CONFIG_PARAM
    self.TOKEN_PARAM   = TOKEN_PARAM
    self.PROMPT_TEXT   = PROMPT_LABEL
    self.PARAM_DELIM   = PARAM_DELIM
    self.COMMENT_DELIM = COMMENT_DELIM
    self.FIELD_DELIM   = FIELD_DELIM
    self.RULES_KEY     = RULES_KEY
    self.CONFIG_KEY    = CONFIG_KEY
  def by(self,name):
    pass
  def list(self):
    return vars(self)

# for key,val in config.items():
#   setattr(TokenizerConfig, key.upper(), val)



#===========================================================
"""


"""
#===========================================================


class TokenizerFactory(Printable):
  def __init__(self, **options):
    filename    = options.get('filename')
    self.config = TokenizerConfig()
    self.meta   = read_lex_file(filename, self.config) if filename else None
    #if no auto lexer then build one manually


#===========================================================
"""


"""
#===========================================================

class Rule(Printable):

  __count=1000

  @property
  def id(self):
    return self._id

  @property
  def pattern(self):
    return self._pattern

  @pattern.setter
  def pattern(self,pattern):
    self.regex = pattern
    self._pattern = pattern

  @property
  def regex(self):
    return self._regex

  @regex.setter
  def regex(self,pattern):
    self._regex = re.compile(pattern)

  @property
  def style(self):
    return self._style

  @style.setter
  def style(self,swatch):
    self._swatch=swatch
    self._style=str(swatch)


  def __init__(self, **options):
    if pattern:
      Rule.__count +=1
      self._id      = Rule.__count
      self._name    = options.get('name')
      self._weight  = options.get('weight')

      pattern = options.get('pattern')
      self.pattern = pattern
      self.style   = options.get('style')

  def __repr__(self):
    return '{}:{}\n'.format(self.id,self.pattern)


#===========================================================
"""


"""
#===========================================================

class Tokenizer(object):


  @property
  def rules(self):
    return self._rules

  def add_rule(self,name,pattern,desc=None):
    #could have invalid params so check for those maybe
    self._rules.append(create_rule(name,pattern,desc))

  @property
  def tokens(self):
    return self._tokens

  def add_token(self):
    pass

  def __init__(self, **options):
    self._options = options or SafeHash()
    self._rules   = []
    self._tokens  = []

  def reset(self):
    self._tokens[:] = []

  def tokenize(self, data):
    line  = data.strip()
    rules = self.rules

    while len(line) > 0:
      for rule in rules:
        if(rule):
          reg = rule.regex
          matched = reg.match(line)
          if matched:
            print('Match', matched, rule.name )
          else:
            pass


#===========================================================

def create_rule(name,pattern,desc=None):
  return Rule(name=name,pattern=pattern)

def createInstance(**options):
  pass



#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    factory = TokenizerFactory(filename='../../cli.lex')
    print(factory.config)
    print(factory.meta)

  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  status = unit_test()
  sys.exit(status)
#--------------------------------
