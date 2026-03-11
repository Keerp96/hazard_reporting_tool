FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence(word_count: 8) }
    association :report
    association :user
  end
end
