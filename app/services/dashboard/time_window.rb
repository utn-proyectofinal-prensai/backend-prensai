# frozen_string_literal: true

module Dashboard
  module TimeWindow
    module_function

    def last_days(days, now = Time.zone.now)
      (now - (days - 1).days).beginning_of_day..now.end_of_day
    end

    def dates_for(range)
      range.begin.to_date.upto(range.end.to_date)
    end
  end
end
