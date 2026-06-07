def gregorian_datetime_to_thelemic_datetime(year, month, day, hour, minute, timezone_offset)
    julian_day = gregorian_datetime_to_julian_day(year, month, day, hour, minute, timezone_offset)
    t = julian_day_to_t(julian_day)
    sun_tropical  = sun_geocentric_spherical(t).longitude * DEGREES_PER_RADIAN
    moon_tropical = moon_geocentric_longitude(julian_day)
    return [
        "☉︎ in #{zodiac_position(sun_tropical)}",
        "☽︎ in #{zodiac_position(moon_tropical)}",
    ]
end