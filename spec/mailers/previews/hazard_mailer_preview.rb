class HazardMailerPreview < ActionMailer::Preview
  def new_report_notification
    report = Report.first || FactoryBot.create(:report)
    HazardMailer.new_report_notification(report)
  end

  def assignment_notification
    report = Report.where.not(assignee_id: nil).first || FactoryBot.create(:report, :assigned)
    HazardMailer.assignment_notification(report)
  end

  def resolution_notification
    report = Report.first || FactoryBot.create(:report)
    HazardMailer.resolution_notification(report)
  end

  def comment_notification
    comment = Comment.first || FactoryBot.create(:comment)
    HazardMailer.comment_notification(comment)
  end
end
