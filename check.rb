Check = Struct.new(:version, :body, :julian_day, :longitude, :latitude, :radius)

def load_checks(file_path = './vsop87.chk')
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