task :run do
    require_relative './lib/main'
end

task :chart do
    require_relative './lib/main'
    gmt_timezone_offset = 0 # GMT
    ist_timezone_offset = 5.5 # GMT
    # north_indian_chart(50.9039, -1.4043, 1999, 1, 6, 20, 02, gmt_timezone_offset)
    north_indian_chart(26.2442, 92.5378, 1996, 1, 7, 16, 43, ist_timezone_offset)
end

task :thelemic_date do
    require_relative './lib/main'
    # time = Time.new('1999-01-06 20:02:00')
    time = Time.now
    time_values = time_to_gregorian_datetime_values(time)
    puts gregorian_datetime_to_thelemic_datetime(*time_values)
end