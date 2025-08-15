#!/bin/bash

# Script de prueba rápida para todas las APIs del sistema
# Uso: ./test_apis.sh

set -e

echo "🚀 ECOMMERCE PUNTOSPOINT - SCRIPT DE PRUEBA COMPLETA"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000"

# Función para mostrar resultados
show_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        exit 1
    fi
}

echo -e "${BLUE}1. Verificando servidor...${NC}"
curl -s "$BASE_URL/health" > /dev/null
show_result $? "Servidor funcionando"

echo -e "${BLUE}2. Obteniendo token JWT...${NC}"
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "administrator": {
      "email": "admin@puntospoint.com",
      "password": "password123"
    }
  }')

TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.token' 2>/dev/null)

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}❌ Error obteniendo token JWT${NC}"
    echo "Respuesta: $TOKEN_RESPONSE"
    exit 1
fi

show_result 0 "Token JWT obtenido"

echo -e "${BLUE}3. Probando API 1: Productos más comprados por categoría${NC}"
API1_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/analytics/most_purchased_by_category" \
  -H "Authorization: Bearer $TOKEN")

API1_SUCCESS=$(echo "$API1_RESPONSE" | jq -r '.success' 2>/dev/null)
if [ "$API1_SUCCESS" == "true" ]; then
    show_result 0 "API 1 funcionando"
else
    show_result 1 "API 1 falló"
fi

echo -e "${BLUE}4. Probando API 2: Top productos por recaudación${NC}"
API2_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/analytics/top_revenue_by_category" \
  -H "Authorization: Bearer $TOKEN")

API2_SUCCESS=$(echo "$API2_RESPONSE" | jq -r '.success' 2>/dev/null)
if [ "$API2_SUCCESS" == "true" ]; then
    show_result 0 "API 2 funcionando"
else
    show_result 1 "API 2 falló"
fi

echo -e "${BLUE}5. Probando API 3: Listado de compras${NC}"
API3_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases?page=1&per_page=5" \
  -H "Authorization: Bearer $TOKEN")

API3_SUCCESS=$(echo "$API3_RESPONSE" | jq -r '.success' 2>/dev/null)
if [ "$API3_SUCCESS" == "true" ]; then
    show_result 0 "API 3 funcionando"
else
    show_result 1 "API 3 falló"
fi

echo -e "${BLUE}6. Probando API 4: Compras por granularidad${NC}"
API4_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/analytics/purchases_by_granularity?granularity=day" \
  -H "Authorization: Bearer $TOKEN")

API4_SUCCESS=$(echo "$API4_RESPONSE" | jq -r '.success' 2>/dev/null)
if [ "$API4_SUCCESS" == "true" ]; then
    show_result 0 "API 4 funcionando"
else
    show_result 1 "API 4 falló"
fi

echo -e "${BLUE}7. Probando autenticación inválida${NC}"
INVALID_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/analytics/most_purchased_by_category" \
  -H "Authorization: Bearer invalid_token")

INVALID_ERROR=$(echo "$INVALID_RESPONSE" | jq -r '.error' 2>/dev/null)
if [ "$INVALID_ERROR" == "Unauthorized" ]; then
    show_result 0 "Autenticación protegiendo APIs correctamente"
else
    show_result 1 "Fallo en protección de APIs"
fi

echo ""
echo -e "${GREEN}🎉 TODAS LAS PRUEBAS EXITOSAS${NC}"
echo -e "${YELLOW}📊 Resumen:${NC}"
echo "   ✅ Servidor funcionando"
echo "   ✅ Autenticación JWT"
echo "   ✅ API 1: Productos más comprados por categoría"
echo "   ✅ API 2: Top productos por recaudación"
echo "   ✅ API 3: Listado de compras"
echo "   ✅ API 4: Compras por granularidad"
echo "   ✅ Protección de autenticación"
echo ""
echo -e "${BLUE}📧 Para probar emails:${NC}"
echo "   bundle exec rake reports:send_daily_report"
echo "   (Se abrirá automáticamente en el navegador)"
echo ""
echo -e "${BLUE}💡 Para más pruebas detalladas, usar el archivo Postman:${NC}"
echo "   postman_collection.json"
