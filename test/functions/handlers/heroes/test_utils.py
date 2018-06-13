"""This is python3.6 program."""

from core.utils import *


def test_epoc_by_second_precision():
    tstr = '2012-12-29T13:49:37+0900'
    tdatetime = datetime.strptime(tstr, '%Y-%m-%dT%H:%M:%S%z')
    sut = epoc_by_second_precision(tdatetime)

    assert int(sut) == 1356756577
