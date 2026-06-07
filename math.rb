CartesianCoordinates = Struct.new(:x, :y, :z) do
    def -(other)
        CartesianCoordinates.new(x - other.x, y - other.y, z - other.z)
    end
end

SphericalCoordinates = Struct.new(:longitude, :latitude, :radius)

def cartesian_to_spherical(cartesian)
    x, y, z = cartesian.x, cartesian.y, cartesian.z
    SphericalCoordinates.new(
        Math.atan2(y, x) % (2 * Math::PI),
        Math.atan2(z, Math.sqrt(x**2 + y**2)),
        Math.sqrt(x**2 + y**2 + z**2),
    )
end

def spherical_to_cartesian(spherical)
    r, lat, lon = spherical.radius, spherical.latitude, spherical.longitude
    CartesianCoordinates.new(
        r * Math.cos(lat) * Math.cos(lon),
        r * Math.cos(lat) * Math.sin(lon),
        r * Math.sin(lat),
    )
end

J2000_JULIAN_DAY    = 2451545.0
DAYS_PER_MILLENNIUM = 365250.0 # 1000 Julian years
DAYS_PER_CENTURY    = 36525.0 # 100 Julian years
DEGREES_PER_CIRCLE = 360.0
RADIANS_PER_DEGREE = Math::PI / 180.0
DEGREES_PER_RADIAN = 180.0 / Math::PI
HALF_CIRCLE = 180.0

def julian_day_to_t(julian_day)
    (julian_day - J2000_JULIAN_DAY) / DAYS_PER_MILLENNIUM
end

def geocentric_spherical(target_body, observer_body, julian_day)
    t = julian_day_to_t(julian_day)
    vector = target_body.cartesian_coordinate(t) - observer_body.cartesian_coordinate(t)
    cartesian_to_spherical(vector)
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
GMST_AT_J2000          = 280.46061837    # GMST in degrees at the epoch
GMST_DEGREES_PER_DAY   = 360.98564736629 # rotation per day relative to the stars
                                         # (slightly more than 360 - that excess is
                                         #  why a sidereal day is ~4 min shorter than a solar day)
GMST_QUADRATIC_TERM    = 0.000387933     # slow drift, per century²
GMST_CUBIC_DIVISOR     = 38_710_000.0    # slow drift, per century³ (as a divisor)

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

# Mean obliquity of the ecliptic (Meeus eq. 22.2).
OBLIQUITY_DEGREES_AT_J2000 = 23.0
OBLIQUITY_ARCMINUTES       = 26.0
OBLIQUITY_ARCSECONDS_BASE  = 21.448   # the seconds part of 23°26'21.448" at J2000
OBLIQUITY_LINEAR_TERM      = 46.8150  # arcseconds the tilt decreases per century
OBLIQUITY_QUADRATIC_TERM   = 0.00059  # arcseconds per century²
OBLIQUITY_CUBIC_TERM       = 0.001813 # arcseconds per century³

def mean_obliquity(julian_day)
    centuries = julian_centuries(julian_day)

    arcseconds = OBLIQUITY_ARCSECONDS_BASE -
        OBLIQUITY_LINEAR_TERM * centuries -
        OBLIQUITY_QUADRATIC_TERM * centuries**2 +
        OBLIQUITY_CUBIC_TERM * centuries**3

    return OBLIQUITY_DEGREES_AT_J2000 +
        OBLIQUITY_ARCMINUTES / ARCMINUTES_PER_DEGREE +
        (arcseconds / ARCSECONDS_PER_DEGREE)
end

# Ecliptic longitude of the ascendant, in degrees [0, 360].
# All three arguments in DEGREES.

def ascendant_longitude(local_sidereal_time, obliquity, latitude) # all degrees
    sidereal_radians  = local_sidereal_time * RADIANS_PER_DEGREE
    obliquity_radians = obliquity * RADIANS_PER_DEGREE
    latitude_radians  = latitude * RADIANS_PER_DEGREE

    longitude_radians = Math.atan2(
        Math.cos(sidereal_radians),
        -(Math.sin(sidereal_radians) * Math.cos(obliquity_radians) +
        Math.tan(latitude_radians) * Math.sin(obliquity_radians))
    )

    return (longitude_radians / RADIANS_PER_DEGREE) % DEGREES_PER_CIRCLE
end

ARCMINUTES_PER_DEGREE = 60.0
ARCSECONDS_PER_DEGREE = 3600.0

# Lahiri ayanamsa in degrees. FIRST APPROXIMATION: linear model anchored at
# J2000, where Lahiri ≈ 23.85°, growing at the rate of precession (~50.29"/yr).
# The rigorous definition pins the sidereal zero point to a reference star and
# the rate is not perfectly constant, so refine this later.

LAHIRI_AT_J2000 = 23.85 # degrees at the epoch
PRECESSION_PER_YEAR  = 50.2876 / ARCSECONDS_PER_DEGREE # degrees per year
DAYS_PER_YEAR = 365.25

def lahiri_ayanamsa(julian_day)
    years_since_j2000 = (julian_day - J2000_JULIAN_DAY) / DAYS_PER_YEAR
    return LAHIRI_AT_J2000 + PRECESSION_PER_YEAR * years_since_j2000
end