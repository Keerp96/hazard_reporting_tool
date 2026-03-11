require 'rails_helper'

RSpec.describe HazardMailer, type: :mailer do
  describe "new_report_notification" do
    let!(:supervisor) { create(:user, :supervisor, email: "supervisor@test.com") }
    let(:report) { create(:report) }
    let(:mail) { HazardMailer.new_report_notification(report) }

    it "sends to all supervisors" do
      expect(mail.to).to include(supervisor.email)
    end

    it "has correct subject" do
      expect(mail.subject).to include(report.title)
      expect(mail.subject).to include("[HazardTracker]")
    end

    it "includes report details in body" do
      expect(mail.body.encoded).to include(report.title)
      expect(mail.body.encoded).to include(report.location)
    end
  end

  describe "assignment_notification" do
    let(:assignee) { create(:user) }
    let(:report) { create(:report, :assigned, assignee: assignee) }
    let(:mail) { HazardMailer.assignment_notification(report) }

    it "sends to assignee" do
      expect(mail.to).to include(assignee.email)
    end

    it "has correct subject" do
      expect(mail.subject).to include("assigned")
    end
  end

  describe "resolution_notification" do
    let(:reporter) { create(:user) }
    let(:report) { create(:report, :resolved, reporter: reporter) }
    let(:mail) { HazardMailer.resolution_notification(report) }

    it "sends to reporter" do
      expect(mail.to).to include(reporter.email)
    end

    it "has correct subject" do
      expect(mail.subject).to include("resolved")
    end
  end

  describe "comment_notification" do
    let(:reporter) { create(:user) }
    let(:commenter) { create(:user) }
    let(:report) { create(:report, reporter: reporter) }
    let(:comment) { create(:comment, report: report, user: commenter) }
    let(:mail) { HazardMailer.comment_notification(comment) }

    it "sends to report reporter (not commenter)" do
      expect(mail.to).to include(reporter.email)
      expect(mail.to).not_to include(commenter.email)
    end

    it "includes comment body" do
      expect(mail.body.encoded).to include(comment.body)
    end
  end
end
