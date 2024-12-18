#!/usr/bin/env python3
"""A simple Python script to print my current age."""

from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta


def current_age(birth: datetime, now: datetime) -> float:
    """Return the current age of the person given the time of their birth and the current time."""
    years = relativedelta(now, birth).years

    year_prev = birth + relativedelta(years=years)
    year_next = birth + relativedelta(years=years + 1)

    usecs_in_this_year = (now - year_prev) / timedelta(microseconds=1)
    usecs_in_whole_year = (year_next - year_prev) / timedelta(microseconds=1)

    return years + (usecs_in_this_year / usecs_in_whole_year)


if __name__ == "__main__":
    # This is where you can specify your exact date and
    # time of birth (currently assumed to be UTC)
    age = current_age(
        datetime.strptime("2005-03-19T03:01:00", "%Y-%m-%dT%H:%M:%S"),
        datetime.now(),
    )

    # And here you can change the decimal precision
    print(f"{age:.7f}")
