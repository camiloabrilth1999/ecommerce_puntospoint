# Ecommerce PuntosPoint - Desafío Técnico Backend

Sistema de ecommerce desarrollado en Ruby on Rails con API JSON, autenticación JWT, procesamiento en segundo plano con Sidekiq y notificaciones por email.

## 📋 Índice

- [🚀 Características Principales](#-características-principales)
- [⚙️ Instalación y Configuración](#️-instalación-y-configuración)
- [🔐 Autenticación](#-autenticación)
- [📡 APIs Disponibles](#-apis-disponibles)
- [📖 Documentación de API con Swagger](#-documentación-de-api-con-swagger)
- [🧪 Testing](#-testing)
- [📈 Monitoreo](#-monitoreo)
- [🛠️ Solución de Problemas](#️-solución-de-problemas)

## 🚀 Características Principales

- **API REST** con autenticación JWT
- **Gestión de productos** con múltiples categorías e imágenes
- **Sistema de compras** con notificaciones automáticas
- **Reportes diarios** automatizados con Sidekiq
- **Auditoría completa** de cambios realizados por administradores
- **Optimización de consultas** SQL y sistema de caché
- **Tests completos** con RSpec
- **Preview de emails** en desarrollo con Letter Opener
- **Documentación API** con Swagger/OpenAPI 3.0

## 📋 Requerimientos del Sistema

- Ruby 3.3+
- Rails 7.2+
- PostgreSQL 12+
- Redis (para Sidekiq)
- Bundler 2.5+

### Instalación de Dependencias del Sistema

**macOS:**
```bash
# Instalar Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar dependencias
brew install postgresql redis
brew services start postgresql
brew services start redis
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib redis-server
sudo systemctl start postgresql
sudo systemctl start redis-server
```

## ⚙️ Instalación y Configuración

### 0. Verificación rápida del entorno
```bash
# Verificar que todo esté listo
./setup_check.sh
```

### 1. Clonar el repositorio
```bash
git clone [<repository-url>](https://github.com/camiloabrilth1999/ecommerce_puntospoint.git)
cd ecommerce_puntospoint
```

### 2. Instalar dependencias
```bash
bundle install
```

### 3. Configurar base de datos
```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

### 4. Verificar que Redis esté funcionando
```bash
redis-cli ping
# Debe responder: PONG

# Si no está corriendo, iniciarlo:
redis-server --daemonize yes
```

### 5. Iniciar el servidor Rails
```bash
bundle exec rails server -p 3000
```

### 6. Iniciar Sidekiq (en otra terminal)
```bash
bundle exec sidekiq -v
```

### 7. Verificar que todo funciona
```bash
# Verificar el health check
curl http://localhost:3000/health

# Debe responder:
# {"status":"ok","timestamp":"2025-XX-XXTXX:XX:XXZ","environment":"development"}
```

## 🗃️ Estructura de la Base de Datos

### Modelos Principales

- **Administrator**: Usuarios administrativos con autenticación JWT
- **Category**: Categorías de productos
- **Product**: Productos del ecommerce (con múltiples categorías e imágenes)
- **Client**: Clientes que realizan compras
- **Purchase**: Compras realizadas por clientes
- **ProductCategory**: Tabla de unión para la relación many-to-many

### Sistema de Auditoría

- **PaperTrail**: Sistema de versionado automático
- **Versions**: Tabla que registra todos los cambios
- **Tracking completo**: Qué cambió, cuándo y quién lo hizo

### Relaciones Avanzadas

- **Many-to-Many**: Products ↔ Categories (a través de ProductCategory)
- **Active Storage**: Product → Múltiples imágenes
- **Through associations**: Product → Clients through Purchases

## 🔐 Autenticación

El sistema utiliza JWT (JSON Web Tokens) para la autenticación de administradores.

### Credenciales por defecto:
- **Admin**: admin@puntospoint.com / password123
- **Manager**: manager@puntospoint.com / password123
- **Supervisor**: supervisor@puntospoint.com / password123
- **Test (Swagger)**: admin@test.com / password123

## 📡 APIs Disponibles

### Autenticación
```
POST /api/v1/auth/login
DELETE /api/v1/auth/logout
```

### Analytics (requieren autenticación JWT)
```
GET /api/v1/analytics/most_purchased_by_category
GET /api/v1/analytics/top_revenue_by_category
GET /api/v1/analytics/purchases
GET /api/v1/analytics/purchases_by_granularity
```

## 🔍 Ejemplos de Uso de las APIs

### 1. Autenticación
```bash
# Obtener token JWT
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "administrator": {
      "email": "admin@puntospoint.com",
      "password": "password123"
    }
  }'

# Respuesta esperada:
# {
#   "success": true,
#   "token": "eyJhbGciOiJIUzI1NiJ9...",
#   "administrator": {
#     "id": 1,
#     "name": "Admin User",
#     "email": "admin@puntospoint.com",
#     "role": "admin"
#   }
# }
```

### 2. Productos más comprados por categoría
```bash
curl -X GET http://localhost:3000/api/v1/analytics/most_purchased_by_category \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Respuesta esperada:
# {
#   "success": true,
#   "data": [
#     {
#       "category_id": 1,
#       "category_name": "Electrónicos",
#       "product": {
#         "id": 5,
#         "name": "Air Pods Pro 2",
#         "sku": "PRD-CEE42E7E",
#         "purchase_count": 2
#       }
#     }
#   ]
# }
```

### 3. Top 3 productos con mayor recaudación por categoría
```bash
curl -X GET http://localhost:3000/api/v1/analytics/top_revenue_by_category \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. Listado de compras con filtros
```bash
curl -X GET "http://localhost:3000/api/v1/analytics/purchases?page=1&per_page=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Con filtros opcionales:
curl -X GET "http://localhost:3000/api/v1/analytics/purchases?start_date=2025-01-01&end_date=2025-01-31&category_id=1&client_id=1&administrator_id=1&page=1&per_page=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 5. Compras por granularidad temporal
```bash
curl -X GET "http://localhost:3000/api/v1/analytics/purchases_by_granularity?granularity=day" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Con parámetros opcionales:
curl -X GET "http://localhost:3000/api/v1/analytics/purchases_by_granularity?granularity=day&start_date=2025-01-01&end_date=2025-01-31&category_id=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Script de Prueba Automática
```bash
# Ejecutar script de prueba completa
./test_apis.sh

# Debe mostrar:
# 🎉 TODAS LAS PRUEBAS EXITOSAS
```

### Script de Prueba Manual
```bash
# Guardar el token en una variable
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"administrator": {"email": "admin@puntospoint.com", "password": "password123"}}' \
  | jq -r '.token')

# Probar todas las APIs
echo "Probando API 1..."
curl -s -X GET http://localhost:3000/api/v1/analytics/most_purchased_by_category \
  -H "Authorization: Bearer $TOKEN" | jq '.success'

echo "Probando API 2..."
curl -s -X GET http://localhost:3000/api/v1/analytics/top_revenue_by_category \
  -H "Authorization: Bearer $TOKEN" | jq '.success'

echo "Probando API 3..."
curl -s -X GET "http://localhost:3000/api/v1/analytics/purchases?page=1&per_page=5" \
  -H "Authorization: Bearer $TOKEN" | jq '.success'

echo "Probando API 4..."
curl -s -X GET "http://localhost:3000/api/v1/analytics/purchases_by_granularity" \
  -H "Authorization: Bearer $TOKEN" | jq '.success'
```

## 📊 Funcionalidades Avanzadas

### Notificaciones por Email
- **Primera compra**: Email automático al administrador creador del producto
- **Reportes diarios**: Resumen de compras enviado a todos los administradores
- **En desarrollo**: Los emails se abren automáticamente en el navegador con Letter Opener

### Procesamiento en Segundo Plano
- **Sidekiq**: Manejo de jobs para emails y reportes
- **Cron Jobs**: Programación de reportes diarios

### Sistema de Auditoría (PaperTrail)
- **Versionado automático** de todos los cambios
- **Tracking de quién hizo qué** y cuándo
- **Historial completo** de modificaciones en productos, categorías y administradores

### Optimizaciones de Performance
- **Caché Redis**: APIs de analytics cacheadas
- **Consultas optimizadas**: Includes y joins para evitar N+1
- **Índices de base de datos**: Optimización de consultas frecuentes

## 📖 Documentación de API con Swagger

El proyecto incluye documentación interactiva completa usando Swagger/OpenAPI 3.0.

### 🌐 Acceso Rápido
```bash
# Interfaz web interactiva:
http://localhost:3000/api-docs

# Script automático (abre en navegador):
./test_swagger.sh
```

### 🔑 Credenciales para Swagger UI

**Login de Prueba:**
```json
{
  "administrator": {
    "email": "admin@test.com",
    "password": "password123"
  }
}
```

**Usuarios Disponibles:**
- `admin@test.com` / `password123` (admin) - Usuario de prueba para Swagger
- `admin@puntospoint.com` / `password123` (admin) - Usuario principal
- `manager@puntospoint.com` / `password123` (manager) - Usuario manager

### 🚀 Cómo usar Swagger UI

#### **1. Hacer Login:**
1. Ve a `http://localhost:3000/api-docs`
2. Expande `Autenticación` → `POST /api/v1/auth/login`
3. Click `Try it out`
4. Pega el JSON de arriba
5. Click `Execute` y **copia el token** de la respuesta

#### **2. Autorizar la Sesión (IMPORTANTE):**
1. **Busca el botón `Authorize` 🔒** en la parte superior de Swagger UI
2. Click en el botón `Authorize`
3. En el campo, pega: `Bearer [tu-token-completo]`
4. Click `Authorize` en el modal y luego `Close`

#### **3. Probar APIs:**
- Ahora todos los endpoints de Analytics funcionarán
- El token se incluye automáticamente en cada request
- Los endpoints mostrarán un candado cerrado 🔒

### 📊 Endpoints Documentados

**🔐 Autenticación:**
- `POST /api/v1/auth/login` - Iniciar sesión y obtener token JWT
- `GET /api/v1/auth/validate` - Validar token JWT

**📈 Analytics:**
- `GET /api/v1/analytics/most_purchased_by_category` - Productos más comprados por categoría
- `GET /api/v1/analytics/top_revenue_by_category` - Productos con mayor facturación por categoría  
- `GET /api/v1/analytics/purchases` - Lista de compras con filtros y paginación
- `GET /api/v1/analytics/purchases_by_granularity` - Compras agrupadas por tiempo

### ✨ Características
- **Interfaz interactiva** para pruebas en tiempo real
- **Autenticación JWT integrada** con botón Authorize
- **Esquemas completos** de request/response con ejemplos
- **Validación automática** de parámetros
- **Documentación siempre actualizada** (generada desde código)

### 🔧 Troubleshooting Swagger
- **401 Unauthorized**: Usa el botón `Authorize` después del login
- **No veo el botón Authorize**: Refresca la página
- **Token inválido**: Haz login nuevamente (tokens expiran en 24h)

## 🧪 Testing

### Tests Automatizados
```bash
# Ejecutar la suite completa de tests
bundle exec rspec

# Ejecutar tests específicos
bundle exec rspec spec/requests/api/v1/analytics_spec.rb
bundle exec rspec spec/models/product_spec.rb

# Ejecutar tests con formato detallado
bundle exec rspec --format documentation
```

### Pruebas Manuales

**Opción 1: Swagger UI (Recomendado)**
1. Ve a `http://localhost:3000/api-docs`
2. Sigue la guía de la sección "Documentación de API con Swagger"
3. Interfaz interactiva con autenticación integrada

**Opción 2: Script automático**
```bash
./test_apis.sh
```

**Opción 3: Postman Collection**
1. Importar `postman_collection.json` en Postman
2. Configurar variable `base_url` como `http://localhost:3000`
3. Ejecutar la carpeta "Authentication" → "Login"
4. Ejecutar cualquier endpoint de "Analytics"

**Opción 4: Comandos curl** (ver sección de ejemplos arriba)

### Pruebas de Email

**Probar notificaciones de email:**
```bash
# Crear una compra para probar notificación de primera compra
bundle exec rails runner "
  admin = Administrator.first
  product = Product.create!(
    name: 'Producto Test Email',
    description: 'Para probar emails',
    price: 100000,
    sku: 'EMAIL-TEST-001',
    stock: 10,
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
  
  puts 'Compra creada - revisa tu navegador para el email'
"

# Probar reporte diario
bundle exec rake reports:send_daily_report
```

**📧 Los emails se abren automáticamente en tu navegador** gracias a Letter Opener.

## 📈 Monitoreo

### Sidekiq Web UI
Disponible en desarrollo en: `http://localhost:3000/sidekiq`

**Nota**: Si encuentras errores de CSRF al acceder a Sidekiq Web, asegúrate de que el servidor Rails esté reiniciado después de los cambios en la configuración.

**Para generar actividad en Sidekiq Web:**
```bash
# Generar jobs de prueba
./test_sidekiq_web.sh

# O manualmente
bundle exec rake reports:send_daily_report
```

### Logs
- **Application**: `log/development.log`
- **Sidekiq**: Logs integrados en application log

## 🔧 Tareas de Mantenimiento

### Reportes Diarios Manuales
```bash
# Reporte del día anterior
bundle exec rake reports:send_daily_report

# Reporte de una fecha específica
DATE=2025-01-15 bundle exec rake reports:send_daily_report
```

**📧 En desarrollo:** Los emails se abren automáticamente en tu navegador gracias a Letter Opener. También se guardan en `tmp/letter_opener/` para revisión posterior.

### Configuración de Cron
```bash
bundle exec rake reports:setup_cron
```

## 🛠️ Solución de Problemas

### Redis no conecta
```bash
# Verificar si Redis está corriendo
redis-cli ping

# Si no responde, iniciar Redis
redis-server --daemonize yes

# En macOS con Homebrew
brew services start redis
```

### Sidekiq no procesa jobs
```bash
# Verificar conexión a Redis desde Rails
bundle exec rails runner "puts Sidekiq.redis { |conn| conn.ping }"

# Limpiar jobs fallidos
bundle exec rails runner "Sidekiq::RetrySet.new.clear; Sidekiq::DeadSet.new.clear"

# Reiniciar Sidekiq
pkill -f sidekiq
bundle exec sidekiq -v
```

### Base de datos
```bash
# Resetear base de datos (CUIDADO: borra todos los datos)
bundle exec rails db:drop db:create db:migrate db:seed

# Solo ejecutar migraciones
bundle exec rails db:migrate
```

### Tests fallando
```bash
# Limpiar y ejecutar tests
bundle exec rails db:test:prepare
bundle exec rspec --format progress
```

## 🏗️ Arquitectura y Patrones

### Patrones Implementados
- **Service Objects**: Lógica de negocio encapsulada
- **Concerns**: Funcionalidad compartida (JwtAuthentication)
- **Jobs**: Procesamiento asíncrono
- **Decorators**: Presentación de datos

### Principios de Diseño
- **DRY**: Don't Repeat Yourself
- **SOLID**: Principios de diseño orientado a objetos
- **RESTful**: APIs siguiendo convenciones REST
- **Security First**: Validaciones y autenticación robusta

## 📝 Estructura del Proyecto

```
app/
├── controllers/
│   └── api/v1/
│       ├── analytics_controller.rb
│       └── auth_controller.rb
├── models/
│   ├── administrator.rb
│   ├── category.rb
│   ├── client.rb
│   ├── product.rb
│   ├── product_category.rb
│   └── purchase.rb
├── jobs/
│   ├── daily_report_job.rb
│   └── first_purchase_notification_job.rb
├── mailers/
│   ├── daily_report_mailer.rb
│   └── first_purchase_notification_mailer.rb
└── services/
    └── jwt_service.rb
```

## 🔒 Seguridad

### Medidas Implementadas
- **JWT Authentication**: Tokens seguros con expiración
- **Strong Parameters**: Filtrado de parámetros
- **SQL Injection Prevention**: ActiveRecord ORM
- **XSS Protection**: Sanitización de datos
- **CORS Configuration**: Control de acceso cross-origin

### Validaciones
- **Email uniqueness**: Prevención de duplicados
- **Password strength**: Mínimo 8 caracteres
- **Data integrity**: Validaciones de modelo completas

## 🚀 Deployment

### Variables de Entorno
```bash
export REDIS_URL=redis://localhost:6379/0
export DATABASE_URL=postgresql://user:password@localhost/ecommerce_puntospoint_production
export RAILS_MASTER_KEY=your_master_key
```

### Docker Support
El proyecto incluye Dockerfile para containerización.

## 📞 Soporte

Para consultas técnicas o dudas sobre la implementación, contactar a:
- **Email**: camiloabrilth1999@gmial.com

---

**Desarrollado para PuntosPoint - Desafío Técnico Backend**
