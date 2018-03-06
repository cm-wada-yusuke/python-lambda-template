"""This is python3.6 program."""

import pytest
import datetime
from src.functions.heroes.utils import *

def test_epoc_by_second_precision():
    tstr = '2012-12-29 13:49:37'
    tdatetime = datetime.strptime(tstr, '%Y-%m-%d %H:%M:%S')
    sut = epoc_by_second_precision(tdatetime)

    assert sut == 1356756577
