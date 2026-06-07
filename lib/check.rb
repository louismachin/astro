Check = Struct.new(:version, :body, :julian_day, :longitude, :latitude, :radius)

def load_checks(file_path = './datasets/vsop87.chk')
    checks = []
    lines = File.readlines(file_path)
    lines.each_with_index do |line, index|
        next unless line =~ /VSOP87(\w)\s+(\w+)\s+JD([\d.]+)/
        version    = $1
        body       = $2
        julian_day = $3.to_f
        value_line = lines[index + 1]
        next unless value_line =~ /\bl\s/ # only the l/b/r form; skip x/y/z records
        longitude = value_line[/\bl\s+(-?\.?\d+\.?\d*)/, 1].to_f # radians
        latitude  = value_line[/\bb\s+(-?\.?\d+\.?\d*)/, 1].to_f # radians
        radius    = value_line[/\br\s+(-?\.?\d+\.?\d*)/, 1].to_f # astronomical units
        checks << Check.new(version, body, julian_day, longitude, latitude, radius)
    end
    return checks
end

def assert_close(got, want, label, tolerance = 1e-5)
    ok = (got - want).abs < tolerance
    puts "#{ok ? 'PASS' : 'FAIL'}  #{label}: got #{got.round(6)}, want #{want}"
end

__END__

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