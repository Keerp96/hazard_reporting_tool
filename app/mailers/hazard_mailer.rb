class HazardMailer < ApplicationMailer
  default from: "notifications@hazardtracker.com"

  def new_report_notification(report)
    @report = report
    supervisors = User.where(role: :supervisor).pluck(:email)
    mail(to: supervisors, subject: "[HazardTracker] New Hazard Report: #{report.title}")
  end

  def assignment_notification(report)
    @report = report
    mail(to: @report.assignee.email, subject: "[HazardTracker] You have been assigned: #{report.title}")
  end

  def resolution_notification(report)
    @report = report
    mail(to: @report.reporter.email, subject: "[HazardTracker] Your hazard report has been resolved: #{report.title}")
  end

  def comment_notification(comment)
    @comment = comment
    @report = comment.report
    recipients = ([@report.reporter.email] + [@report.assignee&.email]).compact.uniq - [comment.user.email]
    return if recipients.empty?

    mail(to: recipients, subject: "[HazardTracker] New comment on: #{@report.title}")
  end
end
