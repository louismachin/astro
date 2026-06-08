PlutoTerm = Struct.new(:jupiter, :saturn, :pluto, :longitude_sin, :longitude_cos, :latitude_sin, :latitude_cos, :radius_sin, :radius_cos)

_pluto_arg_jupiter = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3]
_pluto_arg_saturn  = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
_pluto_arg_pluto   = [1, 2, 3, 4, 5, 6, -1, 0, 1, 2, 3, -2, -1, 0, 0, 1, -3, -2, -1, 0, 1, 2, 3, 4, -3, -2, -1, 0, 1, 3, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, -2, -1, 0]
_pluto_longitude_sin = [-19.799805, 0.897144, 0.611149, -0.341243, 0.129287, -0.038164, 0.020442, -0.004063, -0.006016, -0.003956, -0.000667, 0.001276, 0.001152, 0.00063, 0.002571, 0.000899, -0.001016, -0.002343, 0.007042, 0.001199, 0.000418, 0.00012, -6.0e-05, -8.2e-05, -3.6e-05, -4.0e-05, -1.4e-05, 4.0e-06, 5.0e-06, -1.0e-06, 2.0e-06, -4.0e-06, 4.0e-06, 1.4e-05, -4.9e-05, 0.000163, 9.0e-06, -4.0e-06, -3.0e-06, 1.0e-06, -3.0e-06, 5.0e-06, 0.0]
_pluto_longitude_cos = [19.850055, -4.954829, 1.211027, -0.189585, -0.034992, 0.030893, -0.009987, -0.005071, -0.003336, 0.003039, 0.003572, 0.000501, -0.000917, -0.001277, -0.000459, -0.001449, 0.001043, -0.001012, 0.000788, -0.000338, -6.7e-05, -0.000274, -0.000159, -2.9e-05, -2.9e-05, 7.0e-06, 2.2e-05, 1.3e-05, 2.0e-06, 0.0, 0.0, 5.0e-06, -7.0e-06, 2.4e-05, -3.4e-05, -4.8e-05, -2.4e-05, 1.0e-06, 1.0e-06, 3.0e-06, -1.0e-06, -3.0e-06, 0.0]
_pluto_latitude_sin  = [-5.452852, 3.527812, -1.050748, 0.17869, 0.01865, -0.030697, 0.004878, 0.000226, 0.00203, 6.9e-05, -0.000247, -5.7e-05, -0.000122, -4.9e-05, -0.000197, -2.5e-05, 0.000589, -0.000269, 0.000185, 0.000315, -0.00013, 5.0e-06, 2.0e-06, 2.0e-06, 2.0e-06, 3.0e-06, 2.0e-06, 1.0e-06, 0.0, 0.0, 0.0, 2.0e-06, -7.0e-06, 1.0e-05, -3.0e-06, 6.0e-06, 1.4e-05, -2.0e-06, 0.0, 0.0, 0.0, 0.0, 1.0e-06]
_pluto_latitude_cos  = [-14.974862, 1.67279, 0.327647, -0.292153, 0.10034, -0.025823, 0.011248, -6.4e-05, -0.000836, -0.000604, -0.000567, 1.0e-06, 0.000175, -0.000164, 0.000199, 0.000217, -0.000248, 0.000711, 0.000193, 0.000807, -4.3e-05, 3.0e-06, 1.7e-05, 5.0e-06, 3.0e-06, 1.0e-06, -1.0e-06, -1.0e-06, -1.0e-06, 0.0, -2.0e-06, 2.0e-06, 0.0, -8.0e-06, 2.0e-05, 5.0e-06, 1.7e-05, 0.0, 0.0, 0.0, 1.0e-06, 0.0, 0.0]
_pluto_radius_sin    = [6.6865439, -1.1827535, 0.1593179, -0.0018444, -0.0065977, 0.0031174, -0.0005794, 0.0004601, -0.0001729, -4.15e-05, 2.39e-05, 6.7e-06, 0.0001034, -1.29e-05, 4.8e-05, 2.0e-07, -0.0003359, 0.0007856, 3.6e-06, 0.0008663, -8.09e-05, 2.63e-05, -1.26e-05, -3.5e-06, -1.9e-06, -1.5e-06, -4.0e-07, 5.0e-07, 3.0e-07, 6.0e-07, 2.0e-07, -2.0e-07, 1.4e-06, -6.3e-06, 1.36e-05, 2.73e-05, 2.51e-05, -2.5e-06, 9.0e-07, -8.0e-07, 2.0e-07, 1.9e-06, 1.0e-06]
_pluto_radius_cos    = [6.8951812, -0.0332538, -0.143889, 0.048322, -0.0085431, -0.0006032, 0.0022161, 0.0004032, 2.34e-05, 7.02e-05, 7.23e-05, -6.7e-06, -4.51e-05, 5.04e-05, -2.31e-05, -4.41e-05, 2.65e-05, -0.0007832, 0.0045763, 0.0008547, -7.69e-05, -1.44e-05, 3.2e-06, -1.6e-06, -4.0e-07, 8.0e-07, 1.2e-06, 6.0e-07, 1.0e-07, -2.0e-07, 2.0e-07, -2.0e-07, 1.3e-06, 1.3e-06, -2.36e-05, 0.0001065, 1.49e-05, -9.0e-07, -2.0e-07, 7.0e-07, -1.0e-06, 3.5e-06, 3.0e-07]

PLUTO_TERMS = _pluto_arg_jupiter.zip(
    _pluto_arg_saturn, _pluto_arg_pluto, _pluto_longitude_sin, _pluto_longitude_cos,
    _pluto_latitude_sin, _pluto_latitude_cos, _pluto_radius_sin, _pluto_radius_cos
).map { |row| PlutoTerm.new(*row) }.freeze

# Heliocentric J2000 ecliptic coordinates of Pluto: [longitude°, latitude°, radius AU].
# Meeus ch. 37. VALID ONLY ~1885–2099 - diverges badly outside that window.
def pluto_heliocentric_j2000(julian_day)
    centuries = julian_centuries(julian_day)
    jupiter = 34.35  + 3034.9057 * centuries
    saturn  = 50.08  + 1222.1138 * centuries
    pluto   = 238.96 + 144.96    * centuries

    longitude = 0.0; latitude = 0.0; radius = 0.0
    PLUTO_TERMS.each do |term|
        angle = (term.jupiter * jupiter + term.saturn * saturn + term.pluto * pluto) * RADIANS_PER_DEGREE
        sine = Math.sin(angle); cosine = Math.cos(angle)
        longitude += term.longitude_sin * sine + term.longitude_cos * cosine
        latitude  += term.latitude_sin  * sine + term.latitude_cos  * cosine
        radius    += term.radius_sin    * sine + term.radius_cos    * cosine
    end

    longitude += 238.958116 + 144.96 * centuries
    latitude  += -3.908239
    radius    += 40.7241346
    [longitude % DEGREES_PER_CIRCLE, latitude, radius]
end

# Pluto heliocentric position as cartesian in the ecliptic OF DATE (AU), so it
# drops into the same geocentric subtraction as your VSOP planets.
def pluto_heliocentric_cartesian(julian_day)
    longitude, latitude, radius = pluto_heliocentric_j2000(julian_day)
    longitude += precession_in_longitude(julian_centuries(julian_day)) # J2000 → of date
    spherical = SphericalCoordinates.new(
        longitude * RADIANS_PER_DEGREE,
        latitude  * RADIANS_PER_DEGREE,
        radius
    )
    spherical_to_cartesian(spherical)
end