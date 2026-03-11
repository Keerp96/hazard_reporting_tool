FactoryBot.define do
  factory :report do
    title { Faker::Lorem.sentence(word_count: 4) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    location { "Office Kitchen" }
    severity { :medium }
    status { :open }
    reported_at { Time.current }
    association :reporter, factory: :user

    trait :low do
      severity { :low }
    end

    trait :high do
      severity { :high }
    end

    trait :critical do
      severity { :critical }
    end

    trait :assigned do
      status { :assigned }
      association :assignee, factory: :user
    end

    trait :in_progress do
      status { :in_progress }
      association :assignee, factory: :user
    end

    trait :resolved do
      status { :resolved }
      association :assignee, factory: :user
    end

    trait :closed do
      status { :closed }
      association :assignee, factory: :user
    end
  end
end
