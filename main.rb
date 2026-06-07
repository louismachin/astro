require_relative './math'
require_relative './zodiac'
require_relative './celestial_body'
require_relative './moon'

mercury = CelestialBody.new('./VSOP87D.mer')
venus   = CelestialBody.new('./VSOP87D.ven')
earth   = CelestialBody.new('./VSOP87D.ear')
mars    = CelestialBody.new('./VSOP87D.mar')
jupiter = CelestialBody.new('./VSOP87D.jup')
saturn  = CelestialBody.new('./VSOP87D.sat')
uranus  = CelestialBody.new('./VSOP87D.ura')
neptune = CelestialBody.new('./VSOP87D.nep')

PLANETS = {
  "Mercury" => mercury,
  "Venus"   => venus,
  "Mars"    => mars,
  "Jupiter" => jupiter,
  "Saturn"  => saturn,
  "Uranus"  => uranus,
  "Neptune" => neptune,
}

BIRTH_LATITUDE  = 50.9039
BIRTH_LONGITUDE = -1.4043 # (west is negative)

timezone_offset = 0 # GMT
julian_day = gregorian_datetime_to_julian_day(1999, 1, 6, 20, 2, timezone_offset)
t          = julian_day_to_t(julian_day)
ayanamsa   = lahiri_ayanamsa(julian_day)

local_sidereal_time = local_mean_sidereal_time(julian_day, BIRTH_LONGITUDE)
obliquity = mean_obliquity(julian_day)
ascendant_tropical = ascendant_longitude(local_sidereal_time, obliquity, BIRTH_LATITUDE)


earth_cartesian = earth.cartesian_coordinate(t)
radians_to_degrees = 180.0 / Math::PI

# Gather every body's tropical longitude in degrees into one hash.
tropical_longitudes = {}

tropical_longitudes["Ascendant"] = ascendant_tropical

tropical_longitudes["Sun"] = sun_geocentric_spherical(earth, t).longitude * radians_to_degrees
tropical_longitudes["Moon"] = moon_geocentric_longitude(julian_day)

centuries = julian_centuries(julian_day)
rahu_tropical = mean_lunar_node(centuries)

tropical_longitudes["Rahu"] = rahu_tropical
tropical_longitudes["Ketu"] = (rahu_tropical + 180) % 360

PLANETS.each do |name, body|
  geocentric = cartesian_to_spherical(body.cartesian_coordinate(t) - earth_cartesian)
  tropical_longitudes[name] = geocentric.longitude * radians_to_degrees
end

# Print the chart: each body's sidereal position.
puts "Chart for JD #{julian_day} (ayanamsa #{ayanamsa.round(4)}°)"
puts

tropical_longitudes.each do |name, tropical_degrees|
  position = zodiac_position(tropical_degrees, ayanamsa)
  puts format("%-8s %s", name, position)
end



__END__

require_relative './check'

earth_checks = load_checks.select { |check| check.version == 'D' && check.body.upcase == 'EARTH' }
earth_checks.sample(5).each do |check|
    t = (check.julian_day - 2451545.0) / 365250.0
    longitude = earth.coordinate(1, t) % (2 * Math::PI)
    latitude  = earth.coordinate(2, t)
    radius    = earth.coordinate(3, t)
    puts "Julian Day: #{check.julian_day}"
    puts "- longitude: computed #{longitude.round(10)}, expected #{check.longitude}"
    puts "- latitude:  computed #{latitude.round(10)}, expected #{check.latitude}"
    puts "- radius:    computed #{radius.round(10)}, expected #{check.radius}"
end