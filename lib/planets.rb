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