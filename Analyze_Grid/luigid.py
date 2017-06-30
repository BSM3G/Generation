#!/usr/bin/env python

import sys
import warnings
import luigi.cmdline


def main(argv):
   warnings.warn("'bin/luigid' has moved to console script 'luigid'", DeprecationWarning)
   luigi.cmdline.luigid(argv)


if __name__ == '__main__':
   main(sys.argv[1:])
