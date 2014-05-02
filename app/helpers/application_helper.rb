module ApplicationHelper
  def format_time (hour, min)
    if min < 10
      min_str = "0#{min.to_s}"
    else
      min_str = min.to_s
    end
    "#{hour}:#{min_str}"
  end
end
