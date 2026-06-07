# Layout: change the square and everything inside scales with it.
# (The decorative frame/lotus are fixed to the 760×820 canvas.)
CHART_CANVAS_WIDTH    = 760
CHART_CANVAS_HEIGHT   = 820
CHART_SQUARE_ORIGIN_X = 130
CHART_SQUARE_ORIGIN_Y = 200
CHART_SQUARE_SIDE     = 500

# Where each house's label sits, as a fraction of the square (0..1).
HOUSE_CENTROIDS = {
    1  => [0.500, 0.250], 2  => [0.250, 0.083], 3  => [0.083, 0.250],
    4  => [0.250, 0.500], 5  => [0.083, 0.750], 6  => [0.250, 0.917],
    7  => [0.500, 0.750], 8  => [0.750, 0.917], 9  => [0.917, 0.750],
    10 => [0.750, 0.500], 11 => [0.917, 0.250], 12 => [0.750, 0.083],
}.freeze

GRAHA_ABBREVIATIONS = {
    "Ascendant" => "Asc", "Sun" => "Su", "Moon" => "Mo", "Mars" => "Ma",
    "Mercury" => "Me", "Jupiter" => "Ju", "Venus" => "Ve", "Saturn" => "Sa",
    "Rahu" => "Ra", "Ketu" => "Ke",
}.freeze

GRAHA_ORDER = [
    "Ascendant", "Sun", "Moon", "Mars", "Mercury",
    "Jupiter", "Venus", "Saturn", "Rahu", "Ketu",
].freeze

def render_north_indian_chart(tropical_longitudes, ayanamsa, output_path)
    # Sidereal position for every body, reusing your zodiac layer.
    positions = {}
    tropical_longitudes.each do |name, tropical_degrees|
        positions[name] = zodiac_position(tropical_degrees, ayanamsa)
    end

    ascendant = positions.fetch("Ascendant")
    ascendant_sign = sign_index(ascendant)

    # Group grahas by house (Uranus/Neptune fall out — not in the abbreviation map).
    grahas_by_house = Hash.new { |hash, house| hash[house] = [] }
    positions.each do |name, position|
        next unless GRAHA_ABBREVIATIONS.key?(name)
        grahas_by_house[whole_sign_house(position, ascendant)] << name
    end

    to_x = ->(fraction) { CHART_SQUARE_ORIGIN_X + fraction * CHART_SQUARE_SIDE }
    to_y = ->(fraction) { CHART_SQUARE_ORIGIN_Y + fraction * CHART_SQUARE_SIDE }

    left   = CHART_SQUARE_ORIGIN_X
    right  = CHART_SQUARE_ORIGIN_X + CHART_SQUARE_SIDE
    top    = CHART_SQUARE_ORIGIN_Y
    bottom = CHART_SQUARE_ORIGIN_Y + CHART_SQUARE_SIDE
    mid_x  = to_x.call(0.5)
    mid_y  = to_y.call(0.5)

    line_height = 20
    degree_symbol = "\u00B0"

    house_elements = (1..12).map do |house|
        fraction_x, fraction_y = HOUSE_CENTROIDS.fetch(house)
        center_x = to_x.call(fraction_x)
        center_y = to_y.call(fraction_y)

        sign_number = ((ascendant_sign + (house - 1)) % SIGNS.length) + 1

        grahas = grahas_by_house[house].sort_by { |name| GRAHA_ORDER.index(name) }
        labels = grahas.map do |name|
            degrees = positions[name].degrees_in_sign.floor
            "#{GRAHA_ABBREVIATIONS[name]} #{degrees}#{degree_symbol}"
        end

        # Sign number on top, grahas below, the block centred on the anchor.
        total_lines = 1 + labels.length
        first_line_y = center_y - (total_lines - 1) * line_height / 2.0

        lines = ["<text x=\"#{center_x}\" y=\"#{first_line_y.round(1)}\" font-size=\"13\" fill=\"#9A5B2E\">#{sign_number}</text>"]
        labels.each_with_index do |label, index|
            line_y = first_line_y + (index + 1) * line_height
            lines << "<text x=\"#{center_x}\" y=\"#{line_y.round(1)}\" font-size=\"15\" fill=\"#3D2B1A\">#{label}</text>"
        end
        lines.join("\n      ")
    end

    ascendant_kite = "#{mid_x},#{top} #{to_x.call(0.75)},#{to_y.call(0.25)} " \
        "#{mid_x},#{mid_y} #{to_x.call(0.25)},#{to_y.call(0.25)}"

    petal = "M0,0 C-11,-14 -11,-34 0,-46 C11,-34 11,-14 0,0 Z"

    svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{CHART_CANVAS_WIDTH} #{CHART_CANVAS_HEIGHT}" width="#{CHART_CANVAS_WIDTH}" height="#{CHART_CANVAS_HEIGHT}" font-family="Georgia, 'Times New Roman', serif">
            <rect width="#{CHART_CANVAS_WIDTH}" height="#{CHART_CANVAS_HEIGHT}" fill="#FBF5E7"/>
            <rect x="24" y="24" width="712" height="772" rx="20" fill="none" stroke="#B5532A" stroke-width="3"/>
            <rect x="36" y="36" width="688" height="748" rx="14" fill="none" stroke="#D89A4E" stroke-width="1.5"/>
            <g transform="translate(#{mid_x},150)" fill="#EBB36A" stroke="#C36A2D" stroke-width="1">
                <path d="#{petal}" transform="rotate(-52)"/>
                <path d="#{petal}" transform="rotate(-26)"/>
                <path d="#{petal}"/>
                <path d="#{petal}" transform="rotate(26)"/>
                <path d="#{petal}" transform="rotate(52)"/>
            </g>
            <circle cx="#{mid_x}" cy="150" r="6" fill="#C2452B"/>
            <text x="#{mid_x}" y="184" text-anchor="middle" font-size="30" fill="#7A2E1E">R&#257;&#347;i Chart</text>
            <polygon points="#{ascendant_kite}" fill="#F2C879" fill-opacity="0.35"/>
            <rect x="#{left}" y="#{top}" width="#{CHART_SQUARE_SIDE}" height="#{CHART_SQUARE_SIDE}" fill="none" stroke="#4A3320" stroke-width="2"/>
            <polygon points="#{mid_x},#{top} #{right},#{mid_y} #{mid_x},#{bottom} #{left},#{mid_y}" fill="none" stroke="#4A3320" stroke-width="2"/>
            <line x1="#{left}" y1="#{top}" x2="#{right}" y2="#{bottom}" stroke="#4A3320" stroke-width="2"/>
            <line x1="#{right}" y1="#{top}" x2="#{left}" y2="#{bottom}" stroke="#4A3320" stroke-width="2"/>
            <g text-anchor="middle">
                #{house_elements.join("\n      ")}
            </g>
            <text x="#{mid_x}" y="748" text-anchor="middle" font-size="14" fill="#8A6A4A">North Indian &#183; Sidereal &#183; Lahiri ayanamsa</text>
        </svg>
    SVG
    File.write(output_path, svg)
    return output_path
end