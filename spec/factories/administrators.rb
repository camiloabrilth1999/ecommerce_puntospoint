FactoryBot.define do
  factory :administrator do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'admin' }
    active { true }

    trait :manager do
      role { 'manager' }
    end

    trait :inactive do
      active { false }
    end
  end
end
