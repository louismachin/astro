class CelestialBody
    # NOTE: t is the number of thousands of Julian years since the J2000 epoch

    Term = Struct.new(:amplitude, :phase, :frequency) do
        def value(t)
            return amplitude * Math.cos(phase + frequency * t)
        end
    end

    def initialize(file_path = './VSOP87D.ear')
        base_name = File.basename(file_path).split('.')[0]
        # puts @data.sample(5)
        if base_name == 'VSOP87D'
            @series = Hash.new { |h, v| h[v] = Hash.new { |g, p| g[p] = [] } }
            File.readlines(file_path).each do |line|
                parsed = parse_vsop87d_line(line) or next
                variable, power, term = parsed
                @series[variable][power] << term
            end
        end
    end

    LONGITUDE = 1 # matches code[-2] == 1 in the VSOP file
    LATITUDE  = 2 # matches code[-2] == 2
    RADIUS    = 3 # matches code[-2] == 3

    def coordinate(component, t)
        unless [LONGITUDE, LATITUDE, RADIUS].include?(component)
            raise ArgumentError, "component must be LONGITUDE, LATITUDE, or RADIUS"
        end
        (0..5).sum do |power|
            t**power * @series[component][power].sum { |term| term.value(t) }
        end
    end

    def heliocentric_spherical(t)
        Struct.new(:longitude, :latitude, :radius).new(
            coordinate(LONGITUDE, t),
            coordinate(LATITUDE, t),
            coordinate(RADIUS, t),
        )
    end

    def cartesian_coordinate(t)
        return spherical_to_cartesian(heliocentric_spherical(t))
    end

    private

    def parse_vsop87d_line(line)
        tokens = line.split
        return nil unless tokens.first =~ /\A\d+\z/
        code = tokens.first
        variable = code[-2].to_i
        power    = code[-1].to_i
        amplitude, phase, frequency = tokens.last(3).map(&:to_f)
        return [variable, power, Term.new(amplitude, phase, frequency)]
    end
end

def sun_geocentric_spherical(earth, t)
    earth_helio = earth.heliocentric_spherical(t)
    return SphericalCoordinates.new(
        (earth_helio.longitude + Math::PI) % (2 * Math::PI),  # opposite side
        -earth_helio.latitude,                                 # mirrored across the plane
        earth_helio.radius,                                    # Earth–Sun distance
    )
end