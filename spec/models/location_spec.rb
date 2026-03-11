require 'rails_helper'

RSpec.describe Location, type: :model do
  describe "validations" do
    subject { build(:location) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
  end
end
