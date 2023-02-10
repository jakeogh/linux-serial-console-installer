# -*- coding: utf-8 -*-
import sys

from setuptools import find_packages
from setuptools import setup

if not sys.version_info[0] == 3:
    sys.exit("Python 3 is required. Use: 'python3 setup.py install'")

dependencies = ["click"]

config = {
    "version": "0.1",
    "name": "linux_serial_console_installer",
    "url": "https://github.com/jakeogh/linux-serial-console-installer",
    "license": "Unlicense",
    "author": "Justin Keogh",
    "author_email": "github.com@v6y.net",
    "description": "setup a login console on a serial device",
    "long_description": __doc__,
    "packages": find_packages(exclude=["tests"]),
    "include_package_data": True,
    "zip_safe": False,
    "platforms": "any",
    "install_requires": dependencies,
    "entry_points": {
        "console_scripts": [
            "linux-serial-console-installer=linux_serial_console_installer.linux_serial_console_installer:cli",
        ],
    },
}

setup(**config)
