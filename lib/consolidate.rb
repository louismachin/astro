def consolidated_data(latitude, longitude, year, month, day, hour, minute, timezone_offset)
    return {
        :sidereal => sidereal_chart_values(latitude, longitude, year, month, day, hour, minute, timezone_offset),
        :tropical => tropical_chart_values(latitude, longitude, year, month, day, hour, minute, timezone_offset),
    }
end

def consolidated_data_and_charts(latitude, longitude, year, month, day, hour, minute, timezone_offset, uuid = nil, dir = './')
    output_path = uuid ? dir + 'north_indian_chart_' + uuid + '.svg' : nil
    north_indian_chart(latitude, longitude, year, month, day, hour, minute, timezone_offset, :lahiri, output_path)
    output_path = uuid ? dir + 'western_chart_' + uuid + '.svg' : nil
    western_chart(latitude, longitude, year, month, day, hour, minute, timezone_offset, output_path)
    return consolidated_data(latitude, longitude, year, month, day, hour, minute, timezone_offset)
end

def consolidated_data_by_datetime(latitude, longitude, datetime)
    return consolidated_data(latitude, longitude, *time_to_gregorian_datetime_values(datetime))
end