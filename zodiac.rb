SIGNS = %w[
    Aries Taurus Gemini Cancer Leo Virgo
    Libra Scorpio Sagittarius Capricorn Aquarius Pisces
].freeze

DEGREES_PER_SIGN = 30.0

ZodiacPosition = Struct.new(:sign, :degrees_in_sign, :longitude) do
    def to_s
        whole_degrees = degrees_in_sign.floor
        minutes = ((degrees_in_sign - whole_degrees) * 60).round
        if minutes == 60
            whole_degrees += 1
            minutes = 0
        end
        return format("%d°%02d' %s", whole_degrees, minutes, sign)
    end
end

# tropical_longitude in degrees. ayanamsa in degrees, or 0 for the tropical zodiac.
def zodiac_position(tropical_longitude, ayanamsa = 0.0)
    longitude = (tropical_longitude - ayanamsa) % DEGREES_PER_CIRCLE
    sign_index = (longitude / DEGREES_PER_SIGN).floor
    ZodiacPosition.new(SIGNS[sign_index], longitude % DEGREES_PER_SIGN, longitude)
end