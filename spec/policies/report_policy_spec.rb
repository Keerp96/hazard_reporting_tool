require 'rails_helper'

RSpec.describe ReportPolicy, type: :policy do
  let(:employee) { create(:user, :employee) }
  let(:supervisor) { create(:user, :supervisor) }
  let(:own_report) { create(:report, reporter: employee) }
  let(:other_report) { create(:report) }

  describe "index?" do
    it "allows employees" do
      expect(ReportPolicy.new(employee, Report).index?).to be true
    end

    it "allows supervisors" do
      expect(ReportPolicy.new(supervisor, Report).index?).to be true
    end
  end

  describe "show?" do
    it "allows employee to view own report" do
      expect(ReportPolicy.new(employee, own_report).show?).to be true
    end

    it "denies employee viewing other's report" do
      expect(ReportPolicy.new(employee, other_report).show?).to be false
    end

    it "allows supervisor to view any report" do
      expect(ReportPolicy.new(supervisor, other_report).show?).to be true
    end
  end

  describe "create?" do
    it "allows employees" do
      expect(ReportPolicy.new(employee, Report.new).create?).to be true
    end
  end

  describe "update?" do
    it "denies employees" do
      expect(ReportPolicy.new(employee, own_report).update?).to be false
    end

    it "allows supervisors" do
      expect(ReportPolicy.new(supervisor, own_report).update?).to be true
    end
  end

  describe "assign?" do
    it "denies employees" do
      expect(ReportPolicy.new(employee, own_report).assign?).to be false
    end

    it "allows supervisors" do
      expect(ReportPolicy.new(supervisor, own_report).assign?).to be true
    end
  end

  describe "resolve?" do
    it "denies employees" do
      expect(ReportPolicy.new(employee, own_report).resolve?).to be false
    end

    it "allows supervisors" do
      expect(ReportPolicy.new(supervisor, own_report).resolve?).to be true
    end
  end

  describe "Scope" do
    let!(:employee_report) { create(:report, reporter: employee) }
    let!(:other_user_report) { create(:report) }

    it "returns only employee's own reports for employees" do
      scope = ReportPolicy::Scope.new(employee, Report).resolve
      expect(scope).to include(employee_report)
      expect(scope).not_to include(other_user_report)
    end

    it "returns all reports for supervisors" do
      scope = ReportPolicy::Scope.new(supervisor, Report).resolve
      expect(scope).to include(employee_report, other_user_report)
    end
  end
end
