#!/bin/bash

# Script para probar la documentación Swagger
echo "🔧 DOCUMENTACIÓN SWAGGER - ECOMMERCE PUNTOSPOINT"
echo "================================================"
echo ""

# Verificar que el servidor esté corriendo
if ! curl -s http://localhost:3000/health > /dev/null; then
    echo "❌ ERROR: El servidor Rails no está corriendo en localhost:3000"
    echo ""
    echo "Para iniciar el servidor:"
    echo "  bundle exec rails server -p 3000"
    echo ""
    exit 1
fi

echo "✅ Servidor Rails detectado en localhost:3000"
echo ""

echo "📖 ACCESO A DOCUMENTACIÓN SWAGGER:"
echo "=================================="
echo ""
echo "🌐 Interfaz Web Swagger UI:"
echo "   http://localhost:3000/api-docs"
echo ""
echo "📄 Archivo YAML OpenAPI:"
echo "   http://localhost:3000/api-docs/v1/swagger.yaml"
echo ""
echo "📁 Archivo local:"
echo "   ./swagger/v1/swagger.yaml"
echo ""

echo "🔑 ENDPOINTS DOCUMENTADOS:"
echo "========================="
echo ""
echo "🔐 AUTENTICACIÓN:"
echo "   POST /api/v1/auth/login      - Iniciar sesión"
echo "   GET  /api/v1/auth/validate   - Validar token JWT"
echo ""
echo "📊 ANALYTICS:"
echo "   GET /api/v1/analytics/most_purchased_by_category  - Productos más comprados por categoría"
echo "   GET /api/v1/analytics/top_revenue_by_category     - Productos con mayor facturación por categoría"
echo "   GET /api/v1/analytics/purchases                   - Lista de compras con filtros"
echo "   GET /api/v1/analytics/purchases_by_granularity    - Compras agrupadas por tiempo"
echo ""

echo "🧪 PRUEBAS RÁPIDAS:"
echo "=================="
echo ""
echo "1️⃣ Abrir Swagger UI en el navegador:"
echo "   open http://localhost:3000/api-docs"
echo ""
echo "2️⃣ Regenerar documentación (si cambias algo):"
echo "   bundle exec rake rswag:specs:swaggerize"
echo ""
echo "3️⃣ Ejecutar tests de Swagger:"
echo "   bundle exec rspec spec/requests/api/v1/*swagger*"
echo ""

# Intentar abrir Swagger UI automáticamente
if command -v open &> /dev/null; then
    echo "🚀 Abriendo Swagger UI en el navegador..."
    open http://localhost:3000/api-docs
elif command -v xdg-open &> /dev/null; then
    echo "🚀 Abriendo Swagger UI en el navegador..."
    xdg-open http://localhost:3000/api-docs
else
    echo "💡 Abre manualmente: http://localhost:3000/api-docs"
fi

echo ""
echo "✨ ¡Documentación Swagger lista para usar!"
