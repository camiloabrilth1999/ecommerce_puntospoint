#!/bin/bash

# Script para generar jobs de prueba y verificar Sidekiq Web
# Uso: ./test_sidekiq_web.sh

echo "🚀 GENERANDO JOBS PARA SIDEKIQ WEB"
echo "=================================="
echo ""

echo "1. Generando job de reporte diario..."
bundle exec rake reports:send_daily_report

echo ""
echo "2. Generando job de notificación de primera compra..."
bundle exec rails runner "
# Crear un producto y compra para generar job
admin = Administrator.first
product = Product.create!(
  name: 'Producto Test Sidekiq Web',
  description: 'Para probar Sidekiq Web UI',
  price: 50000,
  sku: 'SIDEKIQ-WEB-001',
  stock: 100,
  administrator: admin,
  active: true
)

client = Client.first
Purchase.create!(
  product: product,
  client: client,
  quantity: 1,
  unit_price: product.price,
  total_amount: product.price,
  purchase_date: Time.current,
  status: 'completed'
)

puts 'Job de primera compra generado'
"

echo ""
echo "3. Esperando procesamiento de jobs..."
sleep 3

echo ""
echo "4. Verificando estadísticas..."
bundle exec rails runner "
stats = Sidekiq::Stats.new
puts 'Jobs procesados: ' + stats.processed.to_s
puts 'Jobs en cola: ' + stats.enqueued.to_s
puts 'Jobs fallidos: ' + stats.failed.to_s
puts 'Jobs reintentando: ' + stats.retry_size.to_s
"

echo ""
echo "🌐 Ahora puedes ver la actividad en Sidekiq Web:"
echo "   http://localhost:3000/sidekiq"
echo ""
echo "📊 En Sidekiq Web podrás ver:"
echo "   - Estadísticas de jobs procesados"
echo "   - Colas activas"
echo "   - Jobs fallidos (si los hay)"
echo "   - Métricas en tiempo real"
