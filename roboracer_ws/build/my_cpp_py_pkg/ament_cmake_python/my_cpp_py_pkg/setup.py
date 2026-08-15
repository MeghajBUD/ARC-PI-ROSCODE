from setuptools import find_packages
from setuptools import setup

setup(
    name='my_cpp_py_pkg',
    version='0.0.0',
    packages=find_packages(
        include=('my_cpp_py_pkg', 'my_cpp_py_pkg.*')),
)
