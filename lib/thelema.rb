def gregorian_datetime_to_thelemic_datetime(year, month, day, hour, minute, timezone_offset)
    julian_day = gregorian_datetime_to_julian_day(year, month, day, hour, minute, timezone_offset)
    t = julian_day_to_t(julian_day)
    sun_tropical  = sun_geocentric_spherical(t).longitude * DEGREES_PER_RADIAN
    moon_tropical = moon_geocentric_longitude(julian_day)
    return [
        "☉︎ in #{zodiac_position(sun_tropical)}",
        "☽︎ in #{zodiac_position(moon_tropical)}",
        thelemic_year(year, month, day, hour, minute, timezone_offset)
    ]
end

THELEMIC_EPOCH_YEAR = 1904
YEARS_PER_DOCOSADE  = 22

ROMAN_NUMERALS = [
    [1000, "M"], [900, "CM"], [500, "D"], [400, "CD"],
    [100, "C"], [90, "XC"], [50, "L"], [40, "XL"],
    [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"],
].freeze

def to_roman(number)
    return "0" if number.zero?
    remaining = number
    ROMAN_NUMERALS.each_with_object(+"") do |(value, symbol), result|
        while remaining >= value
            result << symbol
            remaining -= value
        end
    end
end

# Julian Day of the spring equinox (Sun crossing 0° Aries) for a Gregorian year.
# Solves sun_longitude(julian_day) == 0 by Newton-style stepping.
def spring_equinox_julian_day(year)
    # Initial guess: noon on March 20, always within ~a day of the true equinox.
    julian_day = gregorian_datetime_to_julian_day(year, 3, 20, 12, 0, 0)

    # The Sun's average speed: ~0.9856°/day. Converts an error in degrees
    # into a correction in days (the slope for Newton's method).
    degrees_per_day = DEGREES_PER_CIRCLE / DAYS_PER_YEAR

    4.times do
        t = julian_day_to_t(julian_day)
        longitude = sun_geocentric_spherical(t).longitude * DEGREES_PER_RADIAN    
        # How far the Sun is from 0° Aries, as a signed value in -180..180.
        # Remaps so 359.6° reads as -0.4° (not yet crossed) and 0.4° stays +0.4°
        # i.e. the short way to the equinox.
        offset = ((longitude + HALF_CIRCLE) % DEGREES_PER_CIRCLE) - HALF_CIRCLE   
        # Step the guess by (angular error ÷ speed) = time error in days.
        # offset > 0 (past the equinox) moves the guess earlier; offset < 0 later.
        julian_day -= offset / degrees_per_day
    end

    return julian_day
end

def thelemic_year(year, month, day, hour, minute, timezone_offset, roll_over = :spring_equinox)
    julian_day = gregorian_datetime_to_julian_day(year, month, day, hour, minute, timezone_offset)
    count = year - THELEMIC_EPOCH_YEAR
    if roll_over == :spring_equinox
        # The year rolls over at the spring equinox.
        count -= 1 if julian_day < spring_equinox_julian_day(year)
    elsif (roll_over == :april_8th)
        # The Writing of Liber AL began 8 April 1904.
        count -= 1 if julian_day < gregorian_datetime_to_julian_day(year, 4, 8, hour, minute, timezone_offset)
    elsif (roll_over == :april_10th)
        # The Writing of Liber AL ended 10 April 1904.
        count -= 1 if julian_day < gregorian_datetime_to_julian_day(year, 4, 10, hour, minute, timezone_offset)
    end
    return "" if count < 0
    docosade         = count / YEARS_PER_DOCOSADE
    year_in_docosade = count % YEARS_PER_DOCOSADE
    return "#{to_roman(docosade)}:#{to_roman(year_in_docosade).downcase}"
end