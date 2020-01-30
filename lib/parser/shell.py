#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY


import sys
from os import path

import json
import termios, tty, time
import argparse

#===========================================================
if __name__ == '__main__':
  module_path = path.abspath(path.join('..'))
  if module_path not in sys.path:
    sys.path.append(module_path)

  lib_path = path.abspath(path.join(path.dirname(__file__), '..'))
  if lib_path not in sys.path:
    sys.path.append(lib_path)
#===========================================================


from term import printer, eprint, stderr, debug, err, warn, info, ok, silly, \
                 rainbow as color, const as term, test_colors, test_printer

#===========================================================



#===========================================================

def print_cmd(x):
  printer(term.DOTS + x,color.ORANGE)

def print_var(x):
  printer(term.DOTS + x,color.GREEN)

def print_mag(x):
  printer(term.DOTS + x,color.PINK)

def print_exe(x):
  printer(term.DOTS + x,color.ALTRED)

#===========================================================



#===========================================================

class CommandPrompt:
  def __init__(self, **options):
    self.prompt_style = color.ORANGE
    self.input_style  = color.BLUE
    self.prompt_icon  = '>'
    self.level        = 0

  def label(self, txt):
    if not txt is None: self.prefix = txt
    return(self.render(self.prefix))

  def render(self, txt=None):
    p = self.prompt_icon
    pc = self.prompt_style
    uc = self.input_style
    label = txt if not txt is None else ''
    return '{}{} {} {}{}\033[?25h'.format(term.RESET,pc, label+p, term.RESET,uc)

  def __str__(self):
    return self.render()

#===========================================================



#===========================================================

class CommandShell:

  @property
  def disp(self):
    return self._dispatch

  @property
  def parser(self):
    return self._parser

  @property
  def args(self):
    return self._args

  @property
  def func(self):
    return self._func

  @property
  def meta(self):
    return self._meta

#--------------------------------

  def __init__(self,**options):
    self._prompt   = CommandPrompt()
    self._counter  = 0
    self._args     = None
    self._cache    = None
    self._parser   = argparse.ArgumentParser()

    self._args = vars(self._parser.parse_args())



  def command( self, cmd=None, args=None ):
    if cmd == 'exit' or cmd == 'x' :
      return

    elif cmd.find('_') is 0:
      print_mag('You entered a magic string!')

    elif cmd.find('$') is 0:
      print_var('You entered a variable string!')

    elif cmd.find('#') is 0:
      print_exe('You entered an execute string!')
      if cmd == '#term':  test_colors()
      if cmd == '#print': test_printer()
      if cmd == '#clear': eprint('\x1bc')
      if cmd == '#count': eprint(self._counter)
    else:
      pass

  def parse_opts(self):
    pass

  def parse_cmds(self):
    pass

  def prompt( self, prompt=None, subprompt=None ):

    if prompt is None: prompt = str(self._prompt)
    data = input(prompt).split()

    self._counter+=1
    #stderr(term.RESET)
    return data


  def interactive(self):
    data = None
    cmd  = None
    while cmd != 'exit' and cmd != 'x':
      data = self.prompt()
      cmd  = data[0] if len(data) > 0 else None
      args = data[1:len(data)] or None
      self.command(cmd, args)

#===========================================================



#===========================================================
def createInstance(**options):
  #eprint('>> creating new Shell Instance')
  return CommandShell(**options)
#===========================================================





#===========================================================
#--------------------------------

def main():
  shell = CommandShell()
  eprint (dir(shell))

if __name__ == '__main__':
  status = main()
  sys.exit(status)

#--------------------------------

