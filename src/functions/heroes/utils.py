"""This is python3.6 program."""

from datetime import datetime
import decimal


def epoc_by_second_precision(time: datetime):
    return decimal.Decimal(time.replace(microsecond=0).timestamp())
