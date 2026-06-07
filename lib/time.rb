def julian_day_to_t(julian_day)
    (julian_day - J2000_JULIAN_DAY) / DAYS_PER_MILLENNIUM
end

def gregorian_calendar_to_julian_day(year, month, day, ut_hours = 12.0)
    day += ut_hours / 24.0
    if month <= 2
        year  -= 1
        month += 12
    end
    a = (year / 100)
    b = 2 - a + (a / 4) # Gregorian correction
    return (365.25 * (year + 4716)).floor +
        (30.6001 * (month + 1)).floor +
        day + b - 1524.5
end

def gregorian_datetime_to_julian_day(year, month, day, hour, minute, timezone_offset_hours)
    decimal_hours_local = hour + minute / 60.0
    decimal_hours_ut    = decimal_hours_local - timezone_offset_hours
    return gregorian_calendar_to_julian_day(year, month, day, decimal_hours_ut)
end

# Julian centuries since J2000. Note: CENTURIES, not the millennia VSOP uses.
# Sidereal time and obliquity conventionally use this.
def julian_centuries(julian_day)
    (julian_day - J2000_JULIAN_DAY) / DAYS_PER_CENTURY
end

# Greenwich mean sidereal time (Meeus eq. 12.4), degrees [0, 360). julian_day in UT.
# Earth's sidereal rotation, expressed as the GMST polynomial:
GMST_AT_J2000        = 280.46061837    # GMST in degrees at the epoch
GMST_DEGREES_PER_DAY = 360.98564736629 # rotation per day relative to the stars
                                       # (slightly more than 360 - that excess is
                                       #  why a sidereal day is ~4 min shorter than a solar day)
GMST_QUADRATIC_TERM = 0.000387933  # slow drift, per century²
GMST_CUBIC_DIVISOR  = 38_710_000.0 # slow drift, per century³ (as a divisor)

def greenwich_mean_sidereal_time(julian_day)
    days_since_j2000 = julian_day - J2000_JULIAN_DAY
    centuries        = julian_centuries(julian_day)
    degrees = GMST_AT_J2000 +
        GMST_DEGREES_PER_DAY * days_since_j2000 +
        GMST_QUADRATIC_TERM * centuries**2 -
        centuries**3 / GMST_CUBIC_DIVISOR
    return degrees % DEGREES_PER_CIRCLE
end

# Local mean sidereal time, in degrees [0, 360).
# observer_longitude is geographic longitude, EAST positive.
def local_mean_sidereal_time(julian_day, observer_longitude) # longitude east-positive
    (greenwich_mean_sidereal_time(julian_day) + observer_longitude) % DEGREES_PER_CIRCLE
end

def time_to_gregorian_datetime_values(time)
    [
        time.year,
        time.month,
        time.day,
        time.hour,
        time.min,
        time.utc_offset / 3600.0, # seconds → hours
    ]
end