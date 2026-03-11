require 'rails_helper'

RSpec.describe "Reports", type: :request do
  let(:employee) { create(:user, :employee) }
  let(:supervisor) { create(:user, :supervisor) }

  describe "GET /reports" do
    it "requires authentication" do
      get reports_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns success for authenticated employee" do
      sign_in employee
      create(:report, reporter: employee)
      get reports_path
      expect(response).to have_http_status(:success)
    end

    it "returns success for supervisor" do
      sign_in supervisor
      get reports_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /reports/:id" do
    let!(:report) { create(:report, reporter: employee) }

    it "allows employee to view own report" do
      sign_in employee
      get report_path(report)
      expect(response).to have_http_status(:success)
    end

    it "redirects employee viewing other's report" do
      other_employee = create(:user, :employee)
      sign_in other_employee
      get report_path(report)
      expect(response).to redirect_to(root_path)
    end

    it "allows supervisor to view any report" do
      sign_in supervisor
      get report_path(report)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /reports/new" do
    it "returns success for authenticated user" do
      sign_in employee
      get new_report_path
      expect(response).to have_http_status(:success)
    end

    it "pre-fills location from params" do
      sign_in employee
      get new_report_path(location: "Office Kitchen")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Office Kitchen")
    end
  end

  describe "POST /reports" do
    let(:valid_params) do
      {
        report: {
          title: "Test hazard",
          description: "A test hazard description",
          location: "Office Kitchen",
          severity: "high",
          reported_at: Time.current
        }
      }
    end

    it "creates a report" do
      sign_in employee
      expect {
        post reports_path, params: valid_params
      }.to change(Report, :count).by(1)

      report = Report.last
      expect(report.reporter).to eq(employee)
      expect(report.title).to eq("Test hazard")
    end

    it "rejects invalid params" do
      sign_in employee
      post reports_path, params: { report: { title: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /reports/:id/assign" do
    let!(:report) { create(:report) }

    it "allows supervisor to assign" do
      sign_in supervisor
      patch assign_report_path(report), params: { assignee_id: supervisor.id }
      expect(report.reload.assignee).to eq(supervisor)
      expect(report.status).to eq("assigned")
    end

    it "denies employee from assigning" do
      sign_in employee
      report.update!(reporter: employee)
      patch assign_report_path(report), params: { assignee_id: supervisor.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /reports/:id/resolve" do
    let!(:report) { create(:report, :assigned) }

    it "allows supervisor to resolve" do
      sign_in supervisor
      patch resolve_report_path(report)
      expect(report.reload.status).to eq("resolved")
    end
  end

  describe "GET /reports/export_csv" do
    it "exports CSV for authenticated user" do
      sign_in employee
      create(:report, reporter: employee)
      get export_csv_reports_path
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("text/csv")
    end
  end

  describe "GET /reports/:id/download_pdf" do
    let!(:report) { create(:report, reporter: employee) }

    it "downloads PDF for authorized user" do
      sign_in employee
      get download_pdf_report_path(report)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/pdf")
    end
  end
end
