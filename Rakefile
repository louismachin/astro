task :run do
    require_relative './lib/main'
end

task :clear_charts do
    `rm ./*.svg`
end

task :north_indian_chart do
    require_relative './lib/main'
    gmt_timezone_offset = 0 # GMT
    ist_timezone_offset = 5.5 # GMT
    north_indian_chart(50.9039, -1.4043, 1999, 1, 6, 20, 02, gmt_timezone_offset)
    # north_indian_chart(26.2442, 92.5378, 1996, 1, 7, 16, 43, ist_timezone_offset)
end

task :western_chart do
    require_relative './lib/main'
    gmt_timezone_offset = 0 # GMT
    ist_timezone_offset = 5.5 # GMT
    western_chart(50.9039, -1.4043, 1999, 1, 6, 20, 02, gmt_timezone_offset)
    # western_chart(26.2442, 92.5378, 1996, 1, 7, 16, 43, ist_timezone_offset)
end

task :thelemic_date do
    require_relative './lib/main'
    # time = Time.new('1999-01-06 20:02:00')
    time = Time.now
    time_values = time_to_gregorian_datetime_values(time)
    puts gregorian_datetime_to_thelemic_datetime(*time_values)
end

task :sun do
    require_relative './lib/main'
    time = Time.now
    year, month, day, _hour, _minute, timezone_offset = time_to_gregorian_datetime_values(time)
    observer_latitude, observer_longitude = 50.9097, -1.4044 # Southampton
    # Solar Noon
    solar_noon_julian_day = solar_noon_julian_day(year, month, day, observer_longitude)
    solar_noon = julian_day_to_local_time(solar_noon_julian_day, timezone_offset)
    puts "Solar noon: #{solar_noon}"
    # Sunrise & sunset
    sunrise_julian_day, sunset_julian_day = sunrise_sunset_julian_day(year, month, day, observer_latitude, observer_longitude)
    sunrise, sunset = julian_day_to_local_time(sunrise_julian_day, timezone_offset), julian_day_to_local_time(sunset_julian_day, timezone_offset)
    puts "Sunrise: #{sunrise}"
    puts "Sunset: #{sunset}"
end

task :moon do
    require_relative './lib/main'
    time = Time.now
    year, month, day, _hour, _minute, timezone_offset = time_to_gregorian_datetime_values(time)
    observer_latitude, observer_longitude = 50.9097, -1.4044 # Southampton
    # Lunar Transit
    transit_julian_day = moon_transit_julian_day(year, month, day, observer_longitude)
    puts "Lunar transit: #{julian_day_to_local_time(transit_julian_day, timezone_offset)}"
    # Moonrise & Moonset
    moonrise_julian_day, moonset_julian_day = moonrise_moonset_julian_day(year, month, day, observer_latitude, observer_longitude)
    moonrise, moonset = julian_day_to_local_time(moonrise_julian_day, timezone_offset), julian_day_to_local_time(moonset_julian_day, timezone_offset)
    puts "Moonrise: #{moonrise}"
    puts "Moonset: #{moonset}"
    # Moon phase
    moon_phase = moon_phase_name(transit_julian_day)
    puts "Moon phase: #{moon_phase}"
end