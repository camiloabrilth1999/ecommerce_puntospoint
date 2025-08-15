# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

puts "🌱 Starting seeds..."

# Create Administrators
puts "Creating administrators..."
admin1 = Administrator.find_or_create_by!(email: 'admin@puntospoint.com') do |admin|
  admin.name = 'César Parra'
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
  admin.role = 'admin'
  admin.active = true
end

admin2 = Administrator.find_or_create_by!(email: 'manager@puntospoint.com') do |admin|
  admin.name = 'Ana García'
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
  admin.role = 'manager'
  admin.active = true
end

admin3 = Administrator.find_or_create_by!(email: 'supervisor@puntospoint.com') do |admin|
  admin.name = 'Carlos Rodríguez'
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
  admin.role = 'manager'
  admin.active = true
end

# Test user for Swagger UI
admin_test = Administrator.find_or_create_by!(email: 'admin@test.com') do |admin|
  admin.name = 'Admin Test'
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
  admin.role = 'admin'
  admin.active = true
end

administrators = [ admin1, admin2, admin3, admin_test ]
puts "✅ Created #{administrators.count} administrators"

# Create Categories
puts "Creating categories..."
categories_data = [
  { name: 'Electrónicos', description: 'Productos electrónicos y tecnología' },
  { name: 'Ropa y Accesorios', description: 'Vestimenta y accesorios de moda' },
  { name: 'Hogar y Jardín', description: 'Productos para el hogar y jardín' },
  { name: 'Deportes', description: 'Artículos deportivos y fitness' },
  { name: 'Libros y Medios', description: 'Libros, música y películas' },
  { name: 'Salud y Belleza', description: 'Productos de salud y cosméticos' },
  { name: 'Automóviles', description: 'Accesorios y repuestos para vehículos' },
  { name: 'Juguetes', description: 'Juguetes y juegos para niños' }
]

categories = []
categories_data.each do |cat_data|
  category = Category.find_or_create_by!(name: cat_data[:name]) do |cat|
    cat.description = cat_data[:description]
    cat.administrator = administrators.sample
    cat.active = true
  end
  categories << category
end

puts "✅ Created #{categories.count} categories"

# Create Clients
puts "Creating clients..."
clients = []
50.times do
  client = Client.find_or_create_by!(email: Faker::Internet.unique.email) do |c|
    c.name = Faker::Name.name
    c.phone = Faker::PhoneNumber.phone_number.gsub(/\D/, '')[0..11]
    c.address = Faker::Address.full_address
    c.active = true
  end
  clients << client
end

puts "✅ Created #{clients.count} clients"

# Create Products
puts "Creating products..."
products = []

# Electrónicos
electronics = categories.find { |c| c.name == 'Electrónicos' }
electronic_products = [
  { name: 'iPhone 15 Pro', description: 'Smartphone Apple de última generación con cámara profesional', price: 1299000 },
  { name: 'MacBook Air M2', description: 'Laptop ultradelgada con chip M2 para máximo rendimiento', price: 1899000 },
  { name: 'Samsung Galaxy S24', description: 'Teléfono Android premium con IA integrada', price: 1199000 },
  { name: 'iPad Pro 12.9"', description: 'Tablet profesional con pantalla Liquid Retina XDR', price: 1499000 },
  { name: 'AirPods Pro 2', description: 'Audífonos inalámbricos con cancelación de ruido', price: 299000 }
]

electronic_products.each do |prod_data|
  product = Product.find_or_create_by!(name: prod_data[:name]) do |p|
    p.description = prod_data[:description]
    p.price = prod_data[:price]
    p.stock = rand(100..500)
    p.administrator = administrators.sample
    p.active = true
  end
  product.categories << electronics if electronics && !product.categories.include?(electronics)
  products << product
end

# Ropa y Accesorios
clothing = categories.find { |c| c.name == 'Ropa y Accesorios' }
clothing_products = [
  { name: 'Jeans Levis 501', description: 'Jeans clásicos de mezclilla azul', price: 89000 },
  { name: 'Camiseta Nike Dri-FIT', description: 'Camiseta deportiva de secado rápido', price: 45000 },
  { name: 'Chaqueta North Face', description: 'Chaqueta impermeable para outdoor', price: 199000 },
  { name: 'Zapatillas Adidas Ultraboost', description: 'Zapatillas running de alto rendimiento', price: 179000 },
  { name: 'Reloj Casio G-Shock', description: 'Reloj resistente a golpes y agua', price: 129000 }
]

clothing_products.each do |prod_data|
  product = Product.find_or_create_by!(name: prod_data[:name]) do |p|
    p.description = prod_data[:description]
    p.price = prod_data[:price]
    p.stock = rand(150..400)
    p.administrator = administrators.sample
    p.active = true
  end
  product.categories << clothing if clothing && !product.categories.include?(clothing)
  products << product
end

# Hogar y Jardín
home = categories.find { |c| c.name == 'Hogar y Jardín' }
home_products = [
  { name: 'Aspiradora Dyson V15', description: 'Aspiradora inalámbrica de alta potencia', price: 699000 },
  { name: 'Cafetera Nespresso', description: 'Máquina de café en cápsulas automática', price: 189000 },
  { name: 'Set Ollas Tefal', description: 'Juego de ollas antiadherentes 6 piezas', price: 159000 },
  { name: 'Microondas LG Smart', description: 'Horno microondas inteligente 25L', price: 249000 },
  { name: 'Juego Sábanas Premium', description: 'Sábanas 100% algodón egipcio', price: 89000 }
]

home_products.each do |prod_data|
  product = Product.find_or_create_by!(name: prod_data[:name]) do |p|
    p.description = prod_data[:description]
    p.price = prod_data[:price]
    p.stock = rand(50..200)
    p.administrator = administrators.sample
    p.active = true
  end
  product.categories << home if home && !product.categories.include?(home)
  products << product
end

# Productos con múltiples categorías
multi_cat_product = Product.find_or_create_by!(name: 'Apple Watch Series 9') do |p|
  p.description = 'Smartwatch con GPS y monitor de salud'
  p.price = 499000
  p.stock = rand(80..300)
  p.administrator = administrators.sample
  p.active = true
end
multi_cat_product.categories << electronics if electronics && !multi_cat_product.categories.include?(electronics)
sports_category = categories.find { |c| c.name == 'Deportes' }
multi_cat_product.categories << sports_category if sports_category && !multi_cat_product.categories.include?(sports_category)
products << multi_cat_product

puts "✅ Created #{products.count} products"

# Create Purchases with realistic data
puts "Creating purchases..."
purchase_count = 0

# Create purchases for the last 30 days
(30.days.ago.to_date..Date.current).each do |date|
  # Random number of purchases per day (0-10)
  daily_purchases = rand(0..10)

  daily_purchases.times do
    product = products.sample
    client = clients.sample

    # Ensure we don't exceed stock - limit quantity to max 10% of current stock
    max_quantity = [ (product.stock * 0.1).to_i, 1 ].max
    quantity = rand(1..max_quantity)

    # Skip if product doesn't have enough stock
    next if product.stock < quantity

    # Create purchase with some time variation during the day
    purchase_time = date.beginning_of_day + rand(24.hours)
    status = [ 'completed', 'completed', 'completed', 'pending' ].sample # 75% completed

    purchase = Purchase.create!(
      product: product,
      client: client,
      quantity: quantity,
      unit_price: product.price,
      total_amount: quantity * product.price,
      purchase_date: purchase_time,
      status: status
    )

    # Reduce stock only if purchase is completed
    if status == 'completed'
      product.update!(stock: product.stock - quantity)
    end

    purchase_count += 1
  end
end

# Create some specific purchases for testing first purchase notifications
test_product = products.first
test_client = clients.first

# Ensure this product has at least one completed purchase
Purchase.create!(
  product: test_product,
  client: test_client,
  quantity: 2,
  unit_price: test_product.price,
  total_amount: 2 * test_product.price,
  purchase_date: 1.day.ago,
  status: 'completed'
)
purchase_count += 1

puts "✅ Created #{purchase_count} purchases"

# Summary
puts "\n📊 Seed Summary:"
puts "=================="
puts "Administrators: #{Administrator.count}"
puts "Categories: #{Category.count}"
puts "Products: #{Product.count}"
puts "Clients: #{Client.count}"
puts "Purchases: #{Purchase.count}"
puts "  - Completed: #{Purchase.completed.count}"
puts "  - Pending: #{Purchase.pending.count}"
puts "Total Revenue: $#{Purchase.completed.sum(:total_amount).to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}"

puts "\n🔐 Login Credentials:"
puts "====================="
puts "Admin: admin@puntospoint.com / password123"
puts "Manager: manager@puntospoint.com / password123"
puts "Supervisor: supervisor@puntospoint.com / password123"
puts "Test (Swagger): admin@test.com / password123"

puts "\n🎉 Seeds completed successfully!"
