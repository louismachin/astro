# Each ayanamsa as { value at J2000 (degrees), annual rate (degrees/year) }.
AYANAMSA_MODELS = {
    lahiri:        { at_j2000: 23.85,  rate: 50.2876 / ARCSECONDS_PER_DEGREE },
    raman:         { at_j2000: 21.98,  rate: 50.2876 / ARCSECONDS_PER_DEGREE },
    krishnamurti:  { at_j2000: 23.71,  rate: 50.2876 / ARCSECONDS_PER_DEGREE },
    fagan_bradley: { at_j2000: 24.04,  rate: 50.2876 / ARCSECONDS_PER_DEGREE },
}.freeze

def ayanamsa(julian_day, model = :lahiri)
    constants = AYANAMSA_MODELS.fetch(model)
    years_since_j2000 = (julian_day - J2000_JULIAN_DAY) / DAYS_PER_YEAR
    constants[:at_j2000] + constants[:rate] * years_since_j2000
end

__END__

# Lahiri ayanamsa in degrees. FIRST APPROXIMATION: linear model anchored at
# J2000, where Lahiri ≈ 23.85°, growing at the rate of precession (~50.29"/yr).
# The rigorous definition pins the sidereal zero point to a reference star and
# the rate is not perfectly constant, so refine this later.

LAHIRI_AT_J2000 = 23.85 # degrees at the epoch
PRECESSION_PER_YEAR = 50.2876 / ARCSECONDS_PER_DEGREE # degrees per year
DAYS_PER_YEAR = 365.25

def lahiri_ayanamsa(julian_day)
    years_since_j2000 = (julian_day - J2000_JULIAN_DAY) / DAYS_PER_YEAR
    return LAHIRI_AT_J2000 + PRECESSION_PER_YEAR * years_since_j2000
end