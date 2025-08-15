#!/bin/bash

# Ecommerce PuntosPoint - Scripts de prueba para APIs
# ===================================================

BASE_URL="http://localhost:3000"
JWT_TOKEN=""

echo "🚀 Iniciando pruebas de APIs - Ecommerce PuntosPoint"
echo "=================================================="

# Función para mostrar respuestas de forma legible
show_response() {
    echo "📡 $1"
    echo "---"
    echo "$2" | jq '.' 2>/dev/null || echo "$2"
    echo ""
}

# 1. AUTENTICACIÓN
echo "🔐 1. AUTENTICACIÓN"
echo "=================="

# Login como Admin
echo "Autenticando como Admin..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "administrator": {
      "email": "admin@puntospoint.com",
      "password": "password123"
    }
  }')

show_response "Login Response:" "$LOGIN_RESPONSE"

# Extraer JWT token
JWT_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty' 2>/dev/null)

if [ -z "$JWT_TOKEN" ]; then
    echo "❌ Error: No se pudo obtener el JWT token"
    exit 1
fi

echo "✅ JWT Token obtenido: ${JWT_TOKEN:0:50}..."
echo ""

# 2. ANALYTICS APIs
echo "📊 2. ANALYTICS APIs"
echo "==================="

# API 1: Productos más comprados por categoría
echo "📈 API 1: Productos más comprados por categoría"
RESPONSE_1=$(curl -s -X GET "$BASE_URL/api/v1/analytics/most_purchased_by_category" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Most Purchased by Category:" "$RESPONSE_1"

# API 2: Top 3 productos con mayor recaudación por categoría
echo "💰 API 2: Top 3 productos con mayor recaudación por categoría"
RESPONSE_2=$(curl -s -X GET "$BASE_URL/api/v1/analytics/top_revenue_by_category" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Top Revenue by Category:" "$RESPONSE_2"

# API 3: Listado de compras (sin filtros)
echo "📋 API 3: Listado de compras (sin filtros)"
RESPONSE_3=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Purchases List:" "$RESPONSE_3"

# API 3: Listado de compras con filtro de fecha
echo "📅 API 3: Listado de compras con filtro de fecha"
RESPONSE_3B=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases?start_date=2025-01-01&end_date=2025-01-31" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Purchases with Date Filter:" "$RESPONSE_3B"

# API 3: Listado de compras con filtro de categoría
echo "🏷️  API 3: Listado de compras con filtro de categoría"
RESPONSE_3C=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases?category_id=1" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Purchases with Category Filter:" "$RESPONSE_3C"

# API 4: Compras por granularidad - Día
echo "📊 API 4: Compras por granularidad - Día"
RESPONSE_4A=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases_by_granularity?granularity=day&start_date=2025-01-01&end_date=2025-01-31" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Purchases by Day:" "$RESPONSE_4A"

# API 4: Compras por granularidad - Hora
echo "⏰ API 4: Compras por granularidad - Hora"
RESPONSE_4B=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases_by_granularity?granularity=hour&start_date=2025-01-15&end_date=2025-01-15" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Purchases by Hour:" "$RESPONSE_4B"

# API 4: Compras por granularidad - Semana
echo "📅 API 4: Compras por granularidad - Semana"
RESPONSE_4C=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases_by_granularity?granularity=week&start_date=2025-01-01&end_date=2025-03-31" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Purchases by Week:" "$RESPONSE_4C"

# 3. PRUEBAS DE AUTENTICACIÓN
echo "🔒 3. PRUEBAS DE AUTENTICACIÓN"
echo "=============================="

# Prueba sin token
echo "❌ Prueba sin token de autenticación:"
NO_AUTH_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/analytics/most_purchased_by_category")

show_response "Response without Authentication:" "$NO_AUTH_RESPONSE"

# Prueba con token inválido
echo "❌ Prueba con token inválido:"
INVALID_AUTH_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/analytics/most_purchased_by_category" \
  -H "Authorization: Bearer invalid_token_here")

show_response "Response with Invalid Token:" "$INVALID_AUTH_RESPONSE"

# Logout
echo "👋 Logout:"
LOGOUT_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/v1/auth/logout" \
  -H "Authorization: Bearer $JWT_TOKEN")

show_response "Logout Response:" "$LOGOUT_RESPONSE"

echo "🎉 Pruebas completadas!"
echo "======================"
echo ""
echo "📝 Notas:"
echo "- Asegúrate de que el servidor Rails esté ejecutándose en $BASE_URL"
echo "- Los datos de prueba deben estar cargados (rails db:seed)"
echo "- Para mejores resultados, instala 'jq' para formateo JSON: brew install jq"
echo ""
echo "🔧 Uso:"
echo "chmod +x api_test_scripts.sh"
echo "./api_test_scripts.sh"
