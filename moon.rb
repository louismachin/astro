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

# Meeus table 47.A, longitude column. PARTIAL — the first rows only, biggest
# first. Replace with the full transcription; these let you check it: the top
# coefficient must be 6288774 for [0,0,1,0].
_lunar_elongation = [0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 1, 0, 2, 0, 0, 4, 0, 4, 2, 2, 1,
  1, 2, 2, 4, 2, 0, 2, 2, 1, 2, 0, 0, 2, 2, 2, 4, 0, 3, 2, 4, 0, 2,
  2, 2, 4, 0, 4, 1, 2, 0, 1, 3, 4, 2, 0, 1, 2]
_solar_anomaly = [0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1,
  0, 1, -1, 0, 0, 0, 1, 0, -1, 0, -2, 1, 2, -2, 0, 0, -1, 0, 0, 1,
  -1, 2, 2, 1, -1, 0, 0, -1, 0, 1, 0, 1, 0, 0, -1, 2, 1, 0]
_lunar_anomaly = [1, -1, 0, 2, 0, 0, -2, -1, 1, 0, -1, 0, 1, 0, 1, 1, -1, 3, -2,
  -1, 0, -1, 0, 1, 2, 0, -3, -2, -1, -2, 1, 0, 2, 0, -1, 1, 0,
  -1, 2, -1, 1, -2, -1, -1, -2, 0, 1, 4, 0, -2, 0, 2, 1, -2, -3,
  2, 1, -1, 3]
_moon_node = [0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0,
  0, 0, -2, 0, 0, 0, 0, -2, -2, 0, 0, 0, 0, 0, 0, 0]
_sine_coeff = [6288774, 1274027, 658314, 213618, -185116, -114332,
  58793, 57066, 53322, 45758, -40923, -34720, -30383,
  15327, -12528, 10980, 10675, 10034, 8548, -7888,
  -6766, -5163, 4987, 4036, 3994, 3861, 3665, -2689,
  -2602, 2390, -2348, 2236, -2120, -2069, 2048, -1773,
  -1595, 1215, -1110, -892, -810, 759, -713, -700, 691,
  596, 549, 537, 520, -487, -399, -381, 351, -340, 330,
  327, -323, 299, 294]

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