require_relative './constants'
require_relative './zodiac'
require_relative './celestial_body'
require_relative './moon'
require_relative './output'
require_relative './chart'
require_relative './thelema'
require_relative './ayanamsa'
require_relative './position'
require_relative './time'

MERCURY = CelestialBody.new('./datasets/VSOP87D.mer')
VENUS   = CelestialBody.new('./datasets/VSOP87D.ven')
EARTH   = CelestialBody.new('./datasets/VSOP87D.ear')
MARS    = CelestialBody.new('./datasets/VSOP87D.mar')
JUPITER = CelestialBody.new('./datasets/VSOP87D.jup')
SATURN  = CelestialBody.new('./datasets/VSOP87D.sat')
URANUS  = CelestialBody.new('./datasets/VSOP87D.ura')
NEPTUNE = CelestialBody.new('./datasets/VSOP87D.nep')

PLANETS = {
    "Mercury" => MERCURY,
    "Venus"   => VENUS,
    "Mars"    => MARS,
    "Jupiter" => JUPITER,
    "Saturn"  => SATURN,
    "Uranus"  => URANUS,
    "Neptune" => NEPTUNE,
}


# puts gregorian_datetime_to_thelemic_datetime(*time_to_gregorian_datetime_values(Time.now))
time = Time.new('1999-01-06 20:02:00')
puts "time=#{time}"
puts gregorian_datetime_to_thelemic_datetime(*time_to_gregorian_datetime_values(time))

exit

gmt_timezone_offset = 0 # GMT
ist_timezone_offset = 5.5 # GMT
# north_indian_chart(50.9039, -1.4043, 1999, 1, 6, 20, 02, gmt_timezone_offset)
north_indian_chart(26.2442, 92.5378, 1996, 1, 7, 16, 43, ist_timezone_offset)