FactoryBot.define do
  factory :purchase do
    association :product
    association :client
    quantity { rand(1..3) }
    unit_price { product&.price || 1000 }
    total_amount { quantity * unit_price }
    purchase_date { Faker::Time.between(from: 30.days.ago, to: Time.current) }
    status { 'completed' }

    trait :pending do
      status { 'pending' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
