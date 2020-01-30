
#!/usr/bin/env python3
# coding: utf-8
# by QODENINJA

#--------------------------------


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

from const     import const
from tools     import esc_str
from printer   import eprint, stderr, print_bar, pretty


#--------------------------------

rainbow_names = {
  'altred'  : 9,
  'red'     : 1,
  'altorg'  : 202,
  'orange'  : 208,
  'yellow'  : 220,
  'green'   : 2,
  'altblue' : 25,
  'blue'    : 33,
  'cyan'    : 6,
  'purple'  : 5,
  'pink'    : 213,
  'grey'    : 240,
  'white'   : 15,
  'black'   : 0
}

rainbow_names =  {k.upper(): v for k, v in rainbow_names.items()}
#--------------------------------


#===========================================================


class Swatch(object):
  def __init__(self,**options):
    self.fg    = options.get('fg')
    self.bg    = options.get('bg')
    self.attr  = options.get('attr')
    self.name  = options.get('name')
    self.code  = None

  def render(self):
    if self.code is None:
      self.code = esc_str(color=self.fg, bgcolor=self.bg, style=self.attr)
    return self.code

  def __str__(self):
    return self.render()

def create_swatch(name, **options):
  return Swatch(name,options)

def swatch_from_code(name,code):
  pass


#--------------------------------

"""print array of term colors"""
def debug_colors(*num):
  args = list(num)
  print_bar('debug colors')
  for i, num in enumerate(args):
    sti=str(num)
    stderr( "{}{:^5}{}".format( Swatch(name=sti, bg=num),sti,const.RESET) )
  stderr(const.RESET)


"""print all term colors (256)"""
def debug_colors256():
  print_bar('256 colors')
  for i in range(0, 16):
    for j in range(0, 16):
      code = str(i * 16 + j)
      stderr( "{}{:^5}".format( Swatch(name=str(code), bg=code),code) )
    eprint(const.RESET)
  stderr(const.RESET)


def debug_styles(styles):
  print_bar('debug styles')
  #print(styles)
  #args = list(styles)
  #print(args)
  for key, val in styles.items():
    stderr( "{}{:^5}{}{}".format( val,key,const.RESET, const.NL) )
  stderr(const.RESET)

#===========================================================




#===========================================================

class ColorConstants():
  def __init__(self):
    pass
  def list(self):
    return vars(self)

def swatch_const(inst,names):
  swatches = { key:Swatch(name=key, fg=val) for (key,val) in names.items() }
  for key,val in swatches.items():
    setattr(inst, key.upper(), str(val))
  return inst

#--------------------------------

rainbow_const_fg = swatch_const(ColorConstants(), rainbow_names)

#===========================================================



#===========================================================
#sort of like a unit test lol
def unit_test():
  try:
    debug_colors256()
    debug_colors(1,2,12,57,167)
    debug_styles(rainbow_const_fg.list())
    #pretty(rainbow_const_fg.list())
    style1 = Swatch(name='coolred',fg=9,bg=0)
    style2 = Swatch(name='banana',fg=None,bg=220,attr=5)
    style3 = Swatch(name='sea',fg=None,bg=6,attr=5)
    print( style1, style1.name, const.RESET, repr(str(style1)))
    print( style2, style2.name, const.RESET, repr(str(style2)))
    print( style3, style3.name, const.RESET, repr(str(style3)))


    print_bar( 'sea bar!', style3 )

  except KeyboardInterrupt:
    info('\nDone')

#===========================================================


if __name__ == '__main__':
  import sys
  status = unit_test()
  sys.exit(status)
#--------------------------------




