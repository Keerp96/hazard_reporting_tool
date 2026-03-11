require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:employee) { create(:user, :employee) }
  let(:supervisor) { create(:user, :supervisor) }
  let!(:report) { create(:report, reporter: employee) }

  describe "POST /reports/:report_id/comments" do
    it "creates a comment" do
      sign_in employee
      expect {
        post report_comments_path(report), params: { comment: { body: "Test comment" } }
      }.to change(Comment, :count).by(1)

      expect(Comment.last.user).to eq(employee)
      expect(Comment.last.body).to eq("Test comment")
    end

    it "rejects blank comment" do
      sign_in employee
      expect {
        post report_comments_path(report), params: { comment: { body: "" } }
      }.not_to change(Comment, :count)
    end
  end

  describe "DELETE /reports/:report_id/comments/:id" do
    let!(:comment) { create(:comment, report: report, user: employee) }

    it "allows user to delete own comment" do
      sign_in employee
      expect {
        delete report_comment_path(report, comment)
      }.to change(Comment, :count).by(-1)
    end

    it "allows supervisor to delete any comment" do
      sign_in supervisor
      expect {
        delete report_comment_path(report, comment)
      }.to change(Comment, :count).by(-1)
    end
  end
end
