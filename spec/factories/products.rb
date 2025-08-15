FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 1000..100000) }
    sku { Faker::Code.unique.asin }
    stock { rand(50..200) }
    active { true }
    association :administrator

    # Create association with categories after creation
    after(:create) do |product, evaluator|
      if product.categories.empty?
        product.categories << create(:category, name: "Category for #{product.name}")
      end
    end
  end
end
