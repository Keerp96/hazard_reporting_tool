FactoryBot.define do
  factory :location do
    name { Faker::Commerce.department }
    code { Faker::Internet.slug }
  end
end
