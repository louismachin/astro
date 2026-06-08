# All Moon methods use Julian CENTURIES (/36525), the same time variable as
# sidereal time and obliquity — NOT VSOP's millennia (/365250). The parameter
# is named `centuries` everywhere to keep that distinct from the planet `t`.

# Evaluate a polynomial given coefficients in ASCENDING powers:
# [a0, a1, a2, ...] -> a0 + a1*x + a2*x**2 + ...
def evaluate_polynomial(coefficients, x)
    coefficients.each_with_index.sum { |coefficient, power| coefficient * x**power }
end

# --- The Moon's mean longitude and the four Delaunay arguments (Meeus ch. 47) ---
# Each is degrees, wrapped to [0, 360). The coefficient lists are the published
# polynomials; the small high-order terms are written as 1.0/divisor.

def moon_mean_longitude(centuries) # L'
    evaluate_polynomial(
        [218.3164477, 481267.88123421, -0.0015786, 1.0 / 538841, -1.0 / 65194000],
        centuries
    ) % DEGREES_PER_CIRCLE
end

def moon_mean_elongation(centuries) # D, Moon from Sun
    evaluate_polynomial(
        [297.8501921, 445267.1114034, -0.0018819, 1.0 / 545868, -1.0 / 113065000],
        centuries
    ) % DEGREES_PER_CIRCLE
end

def sun_mean_anomaly(centuries) # M
    evaluate_polynomial(
        [357.5291092, 35999.0502909, -0.0001536, 1.0 / 24490000],
        centuries
    ) % DEGREES_PER_CIRCLE
end

def moon_mean_anomaly(centuries) # M'
    evaluate_polynomial(
        [134.9633964, 477198.8675055, 0.0087414, 1.0 / 69699, -1.0 / 14712000],
        centuries
    ) % DEGREES_PER_CIRCLE
end

def moon_argument_of_latitude(centuries) # F
    evaluate_polynomial(
        [93.2720950, 483202.0175233, -0.0036539, -1.0 / 3526000, 1.0 / 863310000],
        centuries
    ) % DEGREES_PER_CIRCLE
end

def lunar_additive_a1(centuries)
    (119.75 + 131.849 * centuries) % DEGREES_PER_CIRCLE
end

def lunar_additive_a2(centuries)
    (53.09 + 479264.290 * centuries) % DEGREES_PER_CIRCLE
end

def lunar_additive_a3(centuries)
    (313.45 + 481266.484 * centuries) % DEGREES_PER_CIRCLE
end

def lunar_longitude_additive(mean_longitude, argument_of_latitude, a1, a2)
    to_radians = RADIANS_PER_DEGREE
    return 3958 * Math.sin(a1 * to_radians) +
        1962 * Math.sin((mean_longitude - argument_of_latitude) * to_radians) +
        318 * Math.sin(a2 * to_radians)
end

# Eccentricity correction E. Terms involving the Sun's anomaly M are scaled by
# E (for |M coefficient| = 1) or E**2 (= 2), because the Sun's orbital
# eccentricity changes slowly. This is the one scaling VSOP didn't have.
def eccentricity_correction(centuries)
    evaluate_polynomial([1.0, -0.002516, -0.0000074], centuries)
end

# One row of the longitude table: the four integer multipliers and the
# sine coefficient (in 0.000001 degrees).
LunarTerm = Struct.new(:elongation, :sun_anomaly, :moon_anomaly, :latitude_arg, :coefficient)

# Meeus table 47.A, longitude column.
_lunar_elongation = [0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 1, 0, 2, 0, 0, 4, 0, 4, 2, 2, 1, 1, 2, 2, 4, 2, 0, 2, 2, 1, 2, 0, 0, 2, 2, 2, 4, 0, 3, 2, 4, 0, 2, 2, 2, 4, 0, 4, 1, 2, 0, 1, 3, 4, 2, 0, 1, 2]
_solar_anomaly = [0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, -1, 0, 0, 0, 1, 0, -1, 0, -2, 1, 2, -2, 0, 0, -1, 0, 0, 1, -1, 2, 2, 1, -1, 0, 0, -1, 0, 1, 0, 1, 0, 0, -1, 2, 1, 0]
_lunar_anomaly = [1, -1, 0, 2, 0, 0, -2, -1, 1, 0, -1, 0, 1, 0, 1, 1, -1, 3, -2, -1, 0, -1, 0, 1, 2, 0, -3, -2, -1, -2, 1, 0, 2, 0, -1, 1, 0, -1, 2, -1, 1, -2, -1, -1, -2, 0, 1, 4, 0, -2, 0, 2, 1, -2, -3, 2, 1, -1, 3]
_moon_node = [0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0, 0, 0, -2, 0, 0, 0, 0, -2, -2, 0, 0, 0, 0, 0, 0, 0]
_sine_coeff = [6288774, 1274027, 658314, 213618, -185116, -114332, 58793, 57066, 53322, 45758, -40923, -34720, -30383, 15327, -12528, 10980, 10675, 10034, 8548, -7888, -6766, -5163, 4987, 4036, 3994, 3861, 3665, -2689, -2602, 2390, -2348, 2236, -2120, -2069, 2048, -1773, -1595, 1215, -1110, -892, -810, 759, -713, -700, 691, 596, 549, 537, 520, -487, -399, -381, 351, -340, 330, 327, -323, 299, 294]

MOON_LONGITUDE_TERMS = _lunar_elongation
    .zip(_solar_anomaly, _lunar_anomaly, _moon_node, _sine_coeff)
    .map { |row| LunarTerm.new(*row) }
    .freeze

MILLIONTHS_PER_DEGREE = 1_000_000.0

# Sum the longitude terms at a given time. arguments is a hash of the four
# Delaunay values in degrees; E is the eccentricity correction.
def sum_lunar_longitude(terms, arguments, eccentricity)
    terms.sum do |term|
        angle_degrees = term.elongation   * arguments[:elongation]   +
            term.sun_anomaly  * arguments[:sun_anomaly]  +
            term.moon_anomaly * arguments[:moon_anomaly] +
            term.latitude_arg * arguments[:latitude_arg]

        # Scale by E once per power of the Sun's anomaly in this term.
        scale = eccentricity ** term.sun_anomaly.abs
        term.coefficient * scale * Math.sin(angle_degrees * RADIANS_PER_DEGREE)
  end
end

def moon_geocentric_longitude(julian_day)
    centuries = julian_centuries(julian_day)
    mean_longitude = moon_mean_longitude(centuries)
    arguments = {
        elongation:   moon_mean_elongation(centuries),
        sun_anomaly:  sun_mean_anomaly(centuries),
        moon_anomaly: moon_mean_anomaly(centuries),
        latitude_arg: moon_argument_of_latitude(centuries),
    }
    eccentricity = eccentricity_correction(centuries)
    table_sum = sum_lunar_longitude(MOON_LONGITUDE_TERMS, arguments, eccentricity)
    additive_sum = lunar_longitude_additive(
        mean_longitude,
        arguments[:latitude_arg],
        lunar_additive_a1(centuries),
        lunar_additive_a2(centuries),
    )
    return (mean_longitude + (table_sum + additive_sum) / MILLIONTHS_PER_DEGREE) % DEGREES_PER_CIRCLE
end

# Mean longitude of the Moon's ascending node = Rahu. Degrees [0, 360).
# Meeus eq. 47.7. centuries = Julian centuries from J2000 (the /36525 variable,
# same as the Moon - NOT the VSOP millennia t).
def mean_lunar_node(centuries)
    evaluate_polynomial(
        [125.0445479, -1934.1362891, 0.0020754, 1.0 / 467441, -1.0 / 60616000],
        centuries
    ) % DEGREES_PER_CIRCLE
end

LunarLatitudeTerm = Struct.new(:elongation, :sun_anomaly, :moon_anomaly, :latitude_arg, :coefficient)

# Meeus table 47.B (latitude). Coefficient in millionths of a degree, sine terms.
_latitude_elongation = [0, 0, 0, 2, 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 0, 4, 0, 0, 0, 1, 0, 0, 0, 1, 0, 4, 4, 0, 4, 2, 2, 2, 2, 0, 2, 2, 2, 2, 4, 2, 2, 0, 2, 1, 1, 0, 2, 1, 2, 0, 4, 4, 1, 4, 1, 4, 2]
_latitude_sun_anomaly = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1, -1, -1, -1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 1, 0, -1, -2, 0, 1, 1, 1, 1, 1, 0, -1, 1, 0, -1, 0, 0, 0, -1, -2]
_latitude_moon_anomaly = [0, 1, 1, 0, -1, -1, 0, 2, 1, 2, 0, -2, 1, 0, -1, 0, -1, -1, -1, 0, 0, -1, 0, 1, 1, 0, 0, 3, 0, -1, 1, -2, 0, 2, 1, -2, 3, 2, -3, -1, 0, 0, 1, 0, 1, 1, 0, 0, -2, -1, 1, -2, 2, -2, -1, 1, 1, -1, 0, 0]
_latitude_latitude_arg = [1, 1, -1, -1, 1, -1, 1, 1, -1, -1, -1, -1, 1, -1, 1, 1, -1, -1, -1, 1, 3, 1, 1, 1, -1, -1, -1, 1, -1, 1, -3, 1, -3, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1, -1, 3, -1, -1, 1, -1, -1, 1, -1, 1, -1, -1, -1, -1, -1, -1, 1]
_latitude_coeff = [5128122, 280602, 277693, 173237, 55413, 46271, 32573, 17198, 9266, 8822, 8216, 4324, 4200, -3359, 2463, 2211, 2065, -1870, 1828, -1794, -1749, -1565, -1491, -1475, -1410, -1344, -1335, 1107, 1021, 833, 777, 671, 607, 596, 491, -451, 439, 422, 421, -366, -351, 331, 315, 302, -283, -229, 223, 223, -220, -220, -185, 181, -177, 176, 166, -164, 132, -119, 115, 107]

lengths = [_latitude_elongation, _latitude_sun_anomaly, _latitude_moon_anomaly,
           _latitude_latitude_arg, _latitude_coeff].map(&:length)
raise "latitude term lists misaligned: #{lengths}" unless lengths.uniq.length == 1

MOON_LATITUDE_TERMS = _latitude_elongation
  .zip(_latitude_sun_anomaly, _latitude_moon_anomaly, _latitude_latitude_arg, _latitude_coeff)
  .map { |row| LunarLatitudeTerm.new(*row) }
  .freeze

def sum_lunar_latitude(terms, arguments, eccentricity)
    terms.sum do |term|
        angle_degrees = term.elongation   * arguments[:elongation]   +
            term.sun_anomaly  * arguments[:sun_anomaly]  +
            term.moon_anomaly * arguments[:moon_anomaly] +
            term.latitude_arg * arguments[:latitude_arg]
        scale = eccentricity ** term.sun_anomaly.abs
        term.coefficient * scale * Math.sin(angle_degrees * RADIANS_PER_DEGREE)
    end
end

# Geocentric ecliptic latitude of the Moon, degrees.
# Note: latitude has NO mean term, it's purely the sum.
def moon_geocentric_latitude(julian_day)
    centuries = julian_centuries(julian_day)
    arguments = {
        elongation:   moon_mean_elongation(centuries),
        sun_anomaly:  sun_mean_anomaly(centuries),
        moon_anomaly: moon_mean_anomaly(centuries),
        latitude_arg: moon_argument_of_latitude(centuries),
    }
    eccentricity = eccentricity_correction(centuries)
    table_sum = sum_lunar_latitude(MOON_LATITUDE_TERMS, arguments, eccentricity)

    mean_longitude = moon_mean_longitude(centuries)
    additive = -2235 * Math.sin(mean_longitude * RADIANS_PER_DEGREE) +
        382 * Math.sin(lunar_additive_a3(centuries) * RADIANS_PER_DEGREE) +
        175 * Math.sin((lunar_additive_a1(centuries) - arguments[:latitude_arg]) * RADIANS_PER_DEGREE) +
        175 * Math.sin((lunar_additive_a1(centuries) + arguments[:latitude_arg]) * RADIANS_PER_DEGREE) +
        127 * Math.sin((mean_longitude - arguments[:moon_anomaly]) * RADIANS_PER_DEGREE) -
        115 * Math.sin((mean_longitude + arguments[:moon_anomaly]) * RADIANS_PER_DEGREE)
    (table_sum + additive) / MILLIONTHS_PER_DEGREE
end

# Moon's right ascension and declination (degrees) at a Julian Day.
def moon_equatorial(julian_day)
    longitude = moon_geocentric_longitude(julian_day) * RADIANS_PER_DEGREE
    latitude  = moon_geocentric_latitude(julian_day) * RADIANS_PER_DEGREE
    obliquity = mean_obliquity(julian_day) * RADIANS_PER_DEGREE
    right_ascension = Math.atan2(
        Math.sin(longitude) * Math.cos(obliquity) - Math.tan(latitude) * Math.sin(obliquity),
        Math.cos(longitude)
    )
    declination = Math.asin(
        Math.sin(latitude) * Math.cos(obliquity) +
        Math.cos(latitude) * Math.sin(obliquity) * Math.sin(longitude)
    )
    [(right_ascension * DEGREES_PER_RADIAN) % DEGREES_PER_CIRCLE, declination * DEGREES_PER_RADIAN]
end

# Julian Day (UT) of the Moon's meridian transit nearest the given day.
def moon_transit_julian_day(year, month, day, observer_longitude)
    julian_day = gregorian_datetime_to_julian_day(year, month, day, 12, 0, 0) -
        observer_longitude / DEGREES_PER_CIRCLE
    4.times do
        right_ascension, _declination = moon_equatorial(julian_day)
        sidereal_time = local_mean_sidereal_time(julian_day, observer_longitude)
        hour_angle = ((sidereal_time - right_ascension + HALF_CIRCLE) % DEGREES_PER_CIRCLE) - HALF_CIRCLE
        # Moon's hour angle gains ~347.8°/day (360 minus the Moon's own eastward drift).
        julian_day -= (hour_angle / 347.8)
    end
    return julian_day
end

LunarDistanceTerm = Struct.new(:elongation, :sun_anomaly, :moon_anomaly, :latitude_arg, :coefficient)

MOON_BASE_DISTANCE_KM = 385000.56
THOUSANDTHS_PER_KM = 1000.0

# Meeus 47.A, the cosine/distance column. Coefficients in 0.001 km.
_distance_elongation   = [0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 1, 0, 2, 0, 0, 4, 0, 4, 2, 2, 1, 1, 2, 2, 4, 2, 0, 2, 2, 1, 2, 0, 0, 2, 2, 2, 4, 0, 3, 2, 4, 0, 2, 2, 2, 4, 0, 4, 1, 2, 0, 1, 3, 4, 2, 0, 1, 2]
_distance_sun_anomaly  = [0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, -1, 0, 0, 0, 1, 0, -1, 0, -2, 1, 2, -2, 0, 0, -1, 0, 0, 1, -1, 2, 2, 1, -1, 0, 0, -1, 0, 1, 0, 1, 0, 0, -1, 2, 1, 0]
_distance_moon_anomaly = [1, -1, 0, 2, 0, 0, -2, -1, 1, 0, -1, 0, 1, 0, 1, 1, -1, 3, -2, -1, 0, -1, 0, 1, 2, 0, -3, -2, -1, -2, 1, 0, 2, 0, -1, 1, 0, -1, 2, -1, 1, -2, -1, -1, -2, 0, 1, 4, 0, -2, 0, 2, 1, -2, -3, 2, 1, -1, 3]
_distance_latitude_arg = [0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0, 0, 0, -2, 0, 0, 0, 0, -2, -2, 0, 0, 0, 0, 0, 0, 0]
_distance_coeff        = [-20905355, -3699111, -2955968, -569925, 48888, -3149, 246158, -152138, -170733, -204586, -129620, 108743, 104755, 10321, 0, 79661, -34782, -23210, -21636, 24208, 30824, -8379, -16675, -12831, -10445, -11650, 14403, -7003, 0, 10056, 6322, -9884, 5751, 0, -4950, 4130, 0, -3958, 0, 3258, 2616, -1897, -2117, 2354, 0, 0, -1423, -1117, -1571, -1739, 0, -4421, 0, 0, 0, 0, 1165, 0, 0]

lengths = [_distance_elongation, _distance_sun_anomaly, _distance_moon_anomaly,
           _distance_latitude_arg, _distance_coeff].map(&:length)
raise "distance term lists misaligned: #{lengths}" unless lengths.uniq.length == 1

MOON_DISTANCE_TERMS = _distance_elongation
    .zip(_distance_sun_anomaly, _distance_moon_anomaly, _distance_latitude_arg, _distance_coeff)
    .map { |row| LunarDistanceTerm.new(*row) }
    .freeze

def sum_lunar_distance(terms, arguments, eccentricity)
    terms.sum do |term|
        angle_degrees = term.elongation   * arguments[:elongation]   +
            term.sun_anomaly  * arguments[:sun_anomaly]  +
            term.moon_anomaly * arguments[:moon_anomaly] +
            term.latitude_arg * arguments[:latitude_arg]
        scale = eccentricity ** term.sun_anomaly.abs
        term.coefficient * scale * Math.cos(angle_degrees * RADIANS_PER_DEGREE)   # cosine
    end
end

# Earth–Moon distance in km.
def moon_distance(julian_day)
    centuries = julian_centuries(julian_day)
    arguments = {
        elongation:   moon_mean_elongation(centuries),
        sun_anomaly:  sun_mean_anomaly(centuries),
        moon_anomaly: moon_mean_anomaly(centuries),
        latitude_arg: moon_argument_of_latitude(centuries),
    }
    eccentricity = eccentricity_correction(centuries)
    MOON_BASE_DISTANCE_KM + sum_lunar_distance(MOON_DISTANCE_TERMS, arguments, eccentricity) / THOUSANDTHS_PER_KM
end

EARTH_RADIUS_KM = 6378.14
MOON_REFRACTION_AND_SEMIDIAMETER = 0.5667 # degrees, the standard horizon allowance
MOON_HORIZON_ALTITUDE = 0.125 # degrees: mean parallax minus refraction & semidiameter

def moon_horizon_altitude(julian_day)
  distance = moon_distance(julian_day) # km
  parallax = Math.asin(EARTH_RADIUS_KM / distance) * DEGREES_PER_RADIAN
  0.7275 * parallax - MOON_REFRACTION_AND_SEMIDIAMETER # degrees
end

# Returns [moonrise_jd, moonset_jd] in UT, or nil entries if no rise/set that day.
def moonrise_moonset_julian_day(year, month, day, observer_latitude, observer_longitude)
    transit = moon_transit_julian_day(year, month, day, observer_longitude)
    latitude = observer_latitude * RADIANS_PER_DEGREE
  
    rise = transit
    set  = transit
    5.times do
        _ra_r, declination_rise = moon_equatorial(rise)
        _ra_s, declination_set  = moon_equatorial(set)

        altitude_rise = moon_horizon_altitude(rise) * RADIANS_PER_DEGREE
        altitude_set  = moon_horizon_altitude(set)  * RADIANS_PER_DEGREE

        hour_angle_rise = hour_angle_at_altitude(latitude, declination_rise * RADIANS_PER_DEGREE, altitude_rise)
        hour_angle_set  = hour_angle_at_altitude(latitude, declination_set  * RADIANS_PER_DEGREE, altitude_set)
        break if hour_angle_rise.nil? || hour_angle_set.nil?

        rise = transit - hour_angle_rise / 347.8
        set  = transit + hour_angle_set  / 347.8
    end
  
    altitude_transit = moon_horizon_altitude(transit) * RADIANS_PER_DEGREE
    hour_angle_check = hour_angle_at_altitude(latitude, moon_equatorial(transit)[1] * RADIANS_PER_DEGREE, altitude_transit)
    return [nil, nil] if hour_angle_check.nil?
    [rise, set]
end

# Elongation of the Moon from the Sun, degrees [0, 360). 0 = new, 180 = full.
def moon_phase_angle(julian_day)
    t = julian_day_to_t(julian_day)
    sun_longitude  = sun_geocentric_spherical(t).longitude * DEGREES_PER_RADIAN
    moon_longitude = moon_geocentric_longitude(julian_day)
    (moon_longitude - sun_longitude) % DEGREES_PER_CIRCLE
end

# Fraction of the Moon's disc illuminated, 0.0 (new) to 1.0 (full).
def moon_illuminated_fraction(julian_day)
    phase_angle = moon_phase_angle(julian_day) * RADIANS_PER_DEGREE
    (1 - Math.cos(phase_angle)) / 2.0
end

MOON_PHASE_NAMES = ["New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent",].freeze

def moon_phase_name(julian_day)
    angle = moon_phase_angle(julian_day)
    # Eight 45°-wide buckets, centred on the four exact phases.
    index = (((angle + 22.5) % DEGREES_PER_CIRCLE) / 45.0).floor
    MOON_PHASE_NAMES[index]
end