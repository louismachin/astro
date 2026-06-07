def sun_geocentric_spherical(t)
    earth_helio = EARTH.heliocentric_spherical(t)
    return SphericalCoordinates.new(
        (earth_helio.longitude + Math::PI) % (2 * Math::PI), # opposite side
        -earth_helio.latitude,                               # mirrored across the plane
        earth_helio.radius,                                  # Earth–Sun distance
    )
end