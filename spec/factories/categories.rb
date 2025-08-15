FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department }
    description { Faker::Lorem.sentence }
    active { true }
    association :administrator
  end
end
