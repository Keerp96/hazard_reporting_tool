class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.supervisor?
      @open_count = Report.open_count
      @resolution_rate = Report.resolution_rate_this_month
      @traffic_light = Report.traffic_light
      @reports_by_severity = Report.by_severity.transform_keys { |k| Report.severities.key(k)&.titleize || k }
      @reports_by_location = Report.by_location
      @reports_over_time = Report.where("reported_at >= ?", 30.days.ago).group_by_day(:reported_at).count
      @recent_reports = Report.recent.limit(5).includes(:reporter, :assignee)
      @total_reports = Report.count
      @reports_this_month = Report.this_month.count
    else
      @my_reports = current_user.reported_hazards.recent.limit(5)
      @my_open_count = current_user.reported_hazards.open_reports.count
      @my_total = current_user.reported_hazards.count
      @my_resolved = current_user.reported_hazards.resolved_reports.count
    end
  end
end
