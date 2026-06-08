WESTERN_GLYPHS = {
  "Sun" => "\u2609", "Moon" => "\u263D", "Mercury" => "\u263F",
  "Venus" => "\u2640", "Mars" => "\u2642", "Jupiter" => "\u2643",
  "Saturn" => "\u2644", "Uranus" => "\u2645", "Neptune" => "\u2646",
  "Pluto" => "\u2647",
}.freeze

# Aries … Pisces, in zodiac order.
SIGN_GLYPHS = ["\u2648","\u2649","\u264A","\u264B","\u264C","\u264D",
               "\u264E","\u264F","\u2650","\u2651","\u2652","\u2653"].freeze

# [exact angle, orb] for the five Ptolemaic aspects.
WESTERN_ASPECTS = [[0, 8], [60, 6], [90, 8], [120, 8], [180, 8]].freeze

def render_western_chart(tropical_longitudes, output_path)
    size = 640
    center = size / 2.0
    r_outer, r_sign_inner, r_sign_glyph = 300.0, 255.0, 277.0
    r_planet, r_aspect = 215.0, 120.0
    ink = "#1A1A1A"

    ascendant = tropical_longitudes.fetch("Ascendant")

    # Screen polar angle: ascendant at the left (180°), longitude increasing
    # counterclockwise - the standard Western horizon orientation.
    to_theta = ->(lon) { 180.0 + (lon - ascendant) }
    point = ->(lon, radius) {
        th = to_theta.call(lon) * RADIANS_PER_DEGREE
        [center + radius * Math.cos(th), center - radius * Math.sin(th)]
    }
    fmt = ->(v) { v.round(2) }

    svg = []
    svg << %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{size} #{size}" width="#{size}" height="#{size}" font-family="'DejaVu Sans','Segoe UI Symbol',sans-serif">)
    svg << %(<rect width="#{size}" height="#{size}" fill="#F4F1E9"/>)

    [r_outer, r_sign_inner, r_aspect].each do |radius|
        svg << %(<circle cx="#{center}" cy="#{center}" r="#{radius}" fill="none" stroke="#{ink}" stroke-width="0.75"/>)
    end

    # sign divisions (every 30°) and sign glyphs centred in each sector
    12.times do |s|
        b = s * 30.0
        ix, iy = point.call(b, r_sign_inner); bx, by = point.call(b, r_outer)
        svg << %(<line x1="#{fmt.(ix)}" y1="#{fmt.(iy)}" x2="#{fmt.(bx)}" y2="#{fmt.(by)}" stroke="#{ink}" stroke-width="0.75"/>)
        gx, gy = point.call(b + 15.0, r_sign_glyph)
        svg << %(<text x="#{fmt.(gx)}" y="#{fmt.(gy)}" font-size="20" fill="#{ink}" text-anchor="middle" dominant-baseline="central">#{SIGN_GLYPHS[s]}</text>)
    end

    # degree ticks, longer every 10°
    (0...360).step(5) do |d|
        inner = d % 10 == 0 ? r_sign_inner - 8 : r_sign_inner - 4
        x1, y1 = point.call(d.to_f, r_sign_inner); x2, y2 = point.call(d.to_f, inner)
        svg << %(<line x1="#{fmt.(x1)}" y1="#{fmt.(y1)}" x2="#{fmt.(x2)}" y2="#{fmt.(y2)}" stroke="#{ink}" stroke-width="0.5"/>)
    end

    # horizon axis (Ascendant–Descendant), slightly heavier
    ax, ay = point.call(ascendant, r_outer); dx, dy = point.call((ascendant + 180) % 360, r_outer)
    svg << %(<line x1="#{fmt.(ax)}" y1="#{fmt.(ay)}" x2="#{fmt.(dx)}" y2="#{fmt.(dy)}" stroke="#{ink}" stroke-width="1.25"/>)
    svg << %(<text x="#{fmt.(ax - 16)}" y="#{fmt.(ay)}" font-size="11" fill="#{ink}" text-anchor="middle" dominant-baseline="central">ASC</text>)

    planets = tropical_longitudes.reject { |n, _| n == "Ascendant" }

    # aspect web (drawn first, behind glyphs)
    names = planets.keys
    names.each_with_index do |a, i|
        names[(i + 1)..].each do |b|
            sep = (planets[a] - planets[b]).abs % 360
            sep = 360 - sep if sep > 180
            WESTERN_ASPECTS.each do |exact, orb|
                if (sep - exact).abs <= orb
                    x1, y1 = point.call(planets[a], r_aspect); x2, y2 = point.call(planets[b], r_aspect)
                    svg << %(<line x1="#{fmt.(x1)}" y1="#{fmt.(y1)}" x2="#{fmt.(x2)}" y2="#{fmt.(y2)}" stroke="#{ink}" stroke-width="0.5" opacity="0.55"/>)
                    break
                end
            end
        end
    end

    # planet glyphs, radial tick to the exact degree, dot on the aspect circle
    planets.each do |name, lon|
        glyph = WESTERN_GLYPHS.fetch(name, name[0])
        t1x, t1y = point.call(lon, r_sign_inner); t2x, t2y = point.call(lon, r_planet + 12)
        svg << %(<line x1="#{fmt.(t1x)}" y1="#{fmt.(t1y)}" x2="#{fmt.(t2x)}" y2="#{fmt.(t2y)}" stroke="#{ink}" stroke-width="0.5"/>)
        px, py = point.call(lon, r_planet)
        svg << %(<text x="#{fmt.(px)}" y="#{fmt.(py)}" font-size="18" fill="#{ink}" text-anchor="middle" dominant-baseline="central">#{glyph}</text>)
        ox, oy = point.call(lon, r_aspect)
        svg << %(<circle cx="#{fmt.(ox)}" cy="#{fmt.(oy)}" r="1.5" fill="#{ink}"/>)
    end

    svg << %(</svg>)
    File.write(output_path, svg.join("\n"))
    output_path
end