class DateParse
  def self.parse_date_to_unix(date_string)
    date_string += " +0000"
    begin
      date = DateTime.strptime(date_string, '%Y-%m-%d %z')
    rescue StandardError
      return nil
    end

    date.to_time.to_i
  end

  def self.parse_unix_to_date(unix_timestamp, format)
    return nil unless unix_timestamp

    Time.at(unix_timestamp).utc.to_date.strftime(format)
  end

  def self.today_utc_date
    Date.today.to_datetime.change(offset: "+0000")
  end

  def self.today_utc_unix
    today_utc_date.to_i
  end

  def self.parse_seconds_to_words(seconds)
    output = ""
    hours = parse_seconds_to_hours(seconds)
    minutes = parse_seconds_to_minutes(seconds) % 60

    output += "#{hours}h " if hours.positive?
    output += "#{minutes}min" if minutes >= 10 && minutes <= 50
    output.strip
  end

  def self.parse_seconds_to_minutes(seconds)
    return nil if seconds.nil? || !seconds.is_a?(Integer)

    seconds / 60
  end

  def self.parse_seconds_to_hours(seconds)
    return nil if seconds.nil? || !seconds.is_a?(Integer)

    minutes = parse_seconds_to_minutes(seconds) % 60
    hours = seconds / 3600

    hours += 1 if minutes > 50
    hours
  end
end
