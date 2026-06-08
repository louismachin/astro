def north_indian_chart(latitude, longitude, year, month, day, hour, minute, timezone_offset)
    julian_day = gregorian_datetime_to_julian_day(year, month, day, hour, minute, timezone_offset)
    t = julian_day_to_t(julian_day)
    ayanamsa = ayanamsa(julian_day, :lahiri)
    local_sidereal_time = local_mean_sidereal_time(julian_day, longitude)
    obliquity = mean_obliquity(julian_day)
    ascendant_tropical = ascendant_longitude(local_sidereal_time, obliquity, latitude)
    earth_cartesian = EARTH.cartesian_coordinate(t)
    centuries = julian_centuries(julian_day)
    rahu_tropical = mean_lunar_node(centuries)

    tropical_longitudes = {}
    tropical_longitudes["Ascendant"] = ascendant_tropical
    tropical_longitudes["Sun"] = sun_geocentric_spherical(t).longitude * DEGREES_PER_RADIAN
    tropical_longitudes["Moon"] = moon_geocentric_longitude(julian_day)
    tropical_longitudes["Rahu"] = rahu_tropical
    tropical_longitudes["Ketu"] = (rahu_tropical + 180) % 360

    PLANETS.each do |name, body|
        geocentric = cartesian_to_spherical(body.cartesian_coordinate(t) - earth_cartesian)
        tropical_longitudes[name] = geocentric.longitude * DEGREES_PER_RADIAN
    end

    # pluto_geocentric = cartesian_to_spherical(pluto_heliocentric_cartesian(julian_day) - earth_cartesian)
    # tropical_longitudes["Pluto"] = pluto_geocentric.longitude * DEGREES_PER_RADIAN

    puts "Chart for JD #{julian_day} (ayanamsa #{ayanamsa.round(4)}°)"

    tropical_longitudes.each do |name, tropical_degrees|
        position = zodiac_position(tropical_degrees, ayanamsa)
        puts format("%-8s %s", name, position)
    end

    result = render_north_indian_chart(tropical_longitudes, ayanamsa, "./#{julian_day}.svg")
    puts "Created chart: #{result}"
    return result
end

def western_chart(latitude, longitude, year, month, day, hour, minute, timezone_offset)
    julian_day = gregorian_datetime_to_julian_day(year, month, day, hour, minute, timezone_offset)
    t = julian_day_to_t(julian_day)
    local_sidereal_time = local_mean_sidereal_time(julian_day, longitude)
    obliquity = mean_obliquity(julian_day)
    ascendant_tropical = ascendant_longitude(local_sidereal_time, obliquity, latitude)
    earth_cartesian = EARTH.cartesian_coordinate(t)
  
    tropical_longitudes = {}
    tropical_longitudes["Ascendant"] = ascendant_tropical
    tropical_longitudes["Sun"] = sun_geocentric_spherical(t).longitude * DEGREES_PER_RADIAN
    tropical_longitudes["Moon"] = moon_geocentric_longitude(julian_day)
  
    PLANETS.each do |name, body|
      geocentric = cartesian_to_spherical(body.cartesian_coordinate(t) - earth_cartesian)
      tropical_longitudes[name] = geocentric.longitude * DEGREES_PER_RADIAN
    end
  
    pluto_geocentric = cartesian_to_spherical(pluto_heliocentric_cartesian(julian_day) - earth_cartesian)
    tropical_longitudes["Pluto"] = pluto_geocentric.longitude * DEGREES_PER_RADIAN
  
    puts "Western (tropical) chart for JD #{julian_day}"
    tropical_longitudes.each do |name, tropical_degrees|
        position = zodiac_position(tropical_degrees) # no ayanamsa → tropical
        puts format("%-10s %s", name, position)
    end
  
    return tropical_longitudes
end