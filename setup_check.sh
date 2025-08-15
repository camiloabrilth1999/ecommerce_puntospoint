#!/bin/bash

# Script para verificar que el entorno esté completamente configurado
# Uso: ./setup_check.sh

set -e

echo "🔍 VERIFICACIÓN DEL ENTORNO - ECOMMERCE PUNTOSPOINT"
echo "================================================="

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función para verificar comandos
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅ $1 instalado${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 no encontrado${NC}"
        return 1
    fi
}

# Función para verificar servicios
check_service() {
    if $1 &> /dev/null; then
        echo -e "${GREEN}✅ $2 funcionando${NC}"
        return 0
    else
        echo -e "${RED}❌ $2 no funcionando${NC}"
        return 1
    fi
}

echo -e "${BLUE}1. Verificando dependencias del sistema...${NC}"
check_command ruby
check_command bundle
check_command psql
check_command redis-cli
check_command jq

echo -e "\n${BLUE}2. Verificando servicios...${NC}"
check_service "redis-cli ping" "Redis"
check_service "psql -c 'SELECT 1' > /dev/null 2>&1" "PostgreSQL" || echo -e "${YELLOW}⚠️  PostgreSQL puede necesitar configuración${NC}"

echo -e "\n${BLUE}3. Verificando archivos del proyecto...${NC}"
files=("Gemfile" "config/database.yml" "README.md" "postman_collection.json" "test_apis.sh")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file existe${NC}"
    else
        echo -e "${RED}❌ $file no encontrado${NC}"
    fi
done

echo -e "\n${BLUE}4. Verificando gemas...${NC}"
if bundle check &> /dev/null; then
    echo -e "${GREEN}✅ Todas las gemas instaladas${NC}"
else
    echo -e "${YELLOW}⚠️  Ejecutar 'bundle install'${NC}"
fi

echo -e "\n${BLUE}5. Verificando base de datos...${NC}"
if bundle exec rails runner "ActiveRecord::Base.connection" &> /dev/null; then
    echo -e "${GREEN}✅ Base de datos conectada${NC}"
    
    # Verificar tablas
    tables=$(bundle exec rails runner "puts ActiveRecord::Base.connection.tables.join(', ')" 2>/dev/null)
    if [[ $tables == *"products"* && $tables == *"purchases"* ]]; then
        echo -e "${GREEN}✅ Tablas principales creadas${NC}"
    else
        echo -e "${YELLOW}⚠️  Ejecutar 'bundle exec rails db:migrate db:seed'${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Configurar base de datos: bundle exec rails db:create db:migrate db:seed${NC}"
fi

echo -e "\n${BLUE}6. Instrucciones de inicio:${NC}"
echo -e "${YELLOW}Para levantar el sistema completo:${NC}"
echo "1. Redis:    redis-server --daemonize yes"
echo "2. Sidekiq:  bundle exec sidekiq -v"
echo "3. Rails:    bundle exec rails server"
echo "4. Probar:   ./test_apis.sh"

echo -e "\n${GREEN}🎉 Verificación completa${NC}"
echo -e "${BLUE}📖 Ver README.md para instrucciones detalladas${NC}"
