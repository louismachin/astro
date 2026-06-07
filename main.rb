require_relative './math'
require_relative './zodiac'
require_relative './celestial_body'
require_relative './moon'
require_relative './output'
require_relative './chart'

MERCURY = CelestialBody.new('./VSOP87D.mer')
VENUS   = CelestialBody.new('./VSOP87D.ven')
EARTH   = CelestialBody.new('./VSOP87D.ear')
MARS    = CelestialBody.new('./VSOP87D.mar')
JUPITER = CelestialBody.new('./VSOP87D.jup')
SATURN  = CelestialBody.new('./VSOP87D.sat')
URANUS  = CelestialBody.new('./VSOP87D.ura')
NEPTUNE = CelestialBody.new('./VSOP87D.nep')

PLANETS = {
  "Mercury" => MERCURY,
  "Venus"   => VENUS,
  "Mars"    => MARS,
  "Jupiter" => JUPITER,
  "Saturn"  => SATURN,
  "Uranus"  => URANUS,
  "Neptune" => NEPTUNE,
}

timezone_offset = 0 # GMT
north_indian_chart(50.9039, -1.4043, 1999, 1, 6, 20, 02, timezone_offset)