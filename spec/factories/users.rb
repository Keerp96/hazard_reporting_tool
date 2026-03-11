FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { :employee }
    confirmed_at { Time.current }

    trait :supervisor do
      role { :supervisor }
    end

    trait :employee do
      role { :employee }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
