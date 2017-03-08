
from distutils.core import setup
import py2exe

setup(  console = ["makeiar.py"],               # main file
        zipfile = None,                         # bundle library (.zip) to exe
        options = {"py2exe":
                       {"compressed": 1,        # compressed
                        "optimize": 2,          # optimize for -02
                        "bundle_files": 1,      # bundle the dll to exe
                        "dist_dir": './',       # ouput directory
                        }
                    },                          #py2exe option
        data_files = [
                    ],                          #extra data files
        )
