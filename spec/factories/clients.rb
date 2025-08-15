FactoryBot.define do
  factory :client do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number.gsub(/\D/, '')[0..11] }
    address { Faker::Address.full_address }
    active { true }
  end
end
