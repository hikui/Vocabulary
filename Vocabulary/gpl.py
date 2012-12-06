#coding:utf-8
import os
from os import listdir
from os.path import isfile, join

gplStr = """
/*
 *  This file is part of 记词助手.
 *
 *	记词助手 is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License Version 2 as 
 *  published by the Free Software Foundation.
 *
 *	记词助手 is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with 记词助手.  If not, see <http://www.gnu.org/licenses/>.
 */

"""

HERE = os.path.dirname(os.path.abspath(__file__))
print(HERE)

onlyfiles = [ f for f in listdir(HERE) if isfile(join(HERE,f)) and (f.endswith(".h") or f.endswith(".m"))]

for aFile in onlyfiles:
    fullPath = os.path.join(HERE,aFile)
    print fullPath
    f = open(fullPath,'r+')
    oldContent = f.read()
    f.seek(0)
    f.write(gplStr+oldContent)
    f.close()
