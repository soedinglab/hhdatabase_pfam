#!/usr/bin/env python

import sys

a3m_file = sys.argv[1]
sto_file = sys.argv[2]

fh = open(sto_file, "r")
identifier = ""
description = ""
accession = ""
for line in fh:
  if line.startswith("#=GF AC"):
    accession = line.split()[2].rstrip()
  elif line.startswith("#=GF DE"):
    description = line[10:].rstrip()
  elif line.startswith("#=GF ID"):
    identifier = line.split()[2].rstrip()
fh.close()

header = "#"+accession+" ; "+identifier+" ; "+description+"\n"


fh = open(a3m_file, "r")
lines = fh.readlines()
fh.close()

fh = open(a3m_file, "w")
fh.write(header)
for line in lines:
  fh.write(line)
fh.close()
    
