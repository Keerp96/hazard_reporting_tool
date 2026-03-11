require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
  end

  describe "associations" do
    it { should have_many(:reported_hazards).class_name("Report").with_foreign_key(:reporter_id) }
    it { should have_many(:assigned_hazards).class_name("Report").with_foreign_key(:assignee_id) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe "role enum" do
    it { should define_enum_for(:role).with_values(employee: 0, supervisor: 1) }
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end
end
