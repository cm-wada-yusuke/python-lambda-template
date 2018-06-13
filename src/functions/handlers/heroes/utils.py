"""This is python3.6 program."""

from datetime import datetime
import decimal
import json


def epoc_by_second_precision(time: datetime):
    return decimal.Decimal(time.replace(microsecond=0).timestamp())


class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)
