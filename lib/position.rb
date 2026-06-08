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

def geocentric_spherical(target_body, observer_body, julian_day)
    t = julian_day_to_t(julian_day)
    vector = target_body.cartesian_coordinate(t) - observer_body.cartesian_coordinate(t)
    cartesian_to_spherical(vector)
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

# General precession in ecliptic longitude, J2000 → date (degrees). Approximate
# (good to well under an arcminute per century), reusing ARCSECONDS_PER_DEGREE.
def precession_in_longitude(centuries)
    (5028.796195 * centuries + 1.1054348 * centuries ** 2) / ARCSECONDS_PER_DEGREE
end