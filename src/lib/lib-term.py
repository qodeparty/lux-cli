#!/usr/bin/env python3
# coding: utf-8
# by QODEPARTY

#--------------------------------

import os
import sys
import pprint

stderr = sys.stderr.write


#--------------------------------
pp = pprint.PrettyPrinter(indent=4)
ppe = pprint.PrettyPrinter(indent=4,stream=sys.stderr)

def pretty(text):
  if text: pp.pprint(text)

def epretty(text):
  if text: ppe.pprint(text)
