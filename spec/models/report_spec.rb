require 'rails_helper'

RSpec.describe Report, type: :model do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(200) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:severity) }
    it { should validate_presence_of(:reported_at) }
  end

  describe "associations" do
    it { should belong_to(:reporter).class_name("User") }
    it { should belong_to(:assignee).class_name("User").optional }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe "enums" do
    it { should define_enum_for(:severity).with_values(low: 0, medium: 1, high: 2, critical: 3) }
    it { should define_enum_for(:status).with_values(open: 0, assigned: 1, in_progress: 2, resolved: 3, closed: 4) }
  end

  describe "scopes" do
    let!(:open_report) { create(:report, status: :open) }
    let!(:assigned_report) { create(:report, :assigned) }
    let!(:resolved_report) { create(:report, :resolved) }

    describe ".open_reports" do
      it "returns open, assigned and in_progress reports" do
        expect(Report.open_reports).to include(open_report, assigned_report)
        expect(Report.open_reports).not_to include(resolved_report)
      end
    end

    describe ".resolved_reports" do
      it "returns resolved and closed reports" do
        expect(Report.resolved_reports).to include(resolved_report)
        expect(Report.resolved_reports).not_to include(open_report)
      end
    end
  end

  describe ".open_count" do
    it "returns the count of open reports" do
      create_list(:report, 3, status: :open)
      create(:report, :resolved)
      expect(Report.open_count).to eq(3)
    end
  end

  describe ".traffic_light" do
    it "returns green when less than 5 open" do
      create_list(:report, 3, status: :open)
      expect(Report.traffic_light).to eq(:green)
    end

    it "returns yellow when 5-10 open" do
      create_list(:report, 7, status: :open)
      expect(Report.traffic_light).to eq(:yellow)
    end

    it "returns red when more than 10 open" do
      create_list(:report, 12, status: :open)
      expect(Report.traffic_light).to eq(:red)
    end
  end

  describe "AASM state machine" do
    let(:report) { create(:report) }
    let(:assignee) { create(:user) }

    describe "assign event" do
      it "transitions from open to assigned when assignee present" do
        report.assignee = assignee
        expect { report.assign! }.to change(report, :status).from("open").to("assigned")
      end

      it "does not transition when assignee is nil" do
        expect { report.assign! }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "start_work event" do
      it "transitions from assigned to in_progress" do
        report = create(:report, :assigned)
        expect { report.start_work! }.to change(report, :status).from("assigned").to("in_progress")
      end
    end

    describe "resolve event" do
      it "transitions from in_progress to resolved" do
        report = create(:report, :in_progress)
        expect { report.resolve! }.to change(report, :status).from("in_progress").to("resolved")
      end

      it "transitions from assigned to resolved" do
        report = create(:report, :assigned)
        expect { report.resolve! }.to change(report, :status).from("assigned").to("resolved")
      end
    end

    describe "close event" do
      it "transitions from resolved to closed" do
        report = create(:report, :resolved)
        expect { report.close! }.to change(report, :status).from("resolved").to("closed")
      end
    end

    describe "reopen event" do
      it "transitions from resolved to open" do
        report = create(:report, :resolved)
        expect { report.reopen! }.to change(report, :status).from("resolved").to("open")
      end

      it "transitions from closed to open" do
        report = create(:report, :closed)
        expect { report.reopen! }.to change(report, :status).from("closed").to("open")
      end

      it "clears assignee on reopen" do
        report = create(:report, :resolved)
        report.reopen!
        expect(report.assignee).to be_nil
      end
    end

    describe "invalid transitions" do
      it "cannot resolve an open report" do
        expect { report.resolve! }.to raise_error(AASM::InvalidTransition)
      end

      it "cannot close an open report" do
        expect { report.close! }.to raise_error(AASM::InvalidTransition)
      end
    end
  end

  describe "#severity_color" do
    it "returns correct Bootstrap color classes" do
      expect(build(:report, severity: :low).severity_color).to eq("success")
      expect(build(:report, severity: :medium).severity_color).to eq("warning")
      expect(build(:report, severity: :high).severity_color).to eq("orange")
      expect(build(:report, severity: :critical).severity_color).to eq("danger")
    end
  end

  describe "#status_color" do
    it "returns correct Bootstrap color classes" do
      expect(build(:report, status: :open).status_color).to eq("primary")
      expect(build(:report, status: :assigned).status_color).to eq("info")
      expect(build(:report, status: :resolved).status_color).to eq("success")
    end
  end
end
