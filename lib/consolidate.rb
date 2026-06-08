def consolidated_data(latitude, longitude, year, month, day, hour, minute, timezone_offset)
    return {
        :sidereal => sidereal_chart_values(latitude, longitude, year, month, day, hour, minute, timezone_offset),
        :tropical => tropical_chart_values(latitude, longitude, year, month, day, hour, minute, timezone_offset),
    }
end

def consolidated_data_by_datetime(latitude, longitude, datetime)
    return consolidated_data_by_datetime(latitude, longitude, *time_to_gregorian_datetime_values(datetime))
end