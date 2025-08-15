# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Ecommerce PuntosPoint API',
        version: 'v1',
        description: 'API para sistema de ecommerce con autenticación JWT, gestión de productos, categorías, clientes y analytics de ventas.',
        contact: {
          name: 'PuntosPoint',
          email: 'noreply@puntospoint.com'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Servidor de desarrollo'
        },
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'api.puntospoint.com'
            }
          },
          description: 'Servidor de producción'
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'Token JWT obtenido del endpoint de login'
          }
        },
        schemas: {
          Error: {
            type: :object,
            properties: {
              error: {
                type: :string,
                description: 'Mensaje de error'
              },
              details: {
                type: :string,
                description: 'Detalles adicionales del error'
              }
            },
            required: [ 'error' ]
          },
          LoginRequest: {
            type: :object,
            properties: {
              email: {
                type: :string,
                format: :email,
                description: 'Email del administrador'
              },
              password: {
                type: :string,
                description: 'Contraseña del administrador'
              }
            },
            required: [ 'email', 'password' ]
          },
          LoginResponse: {
            type: :object,
            properties: {
              token: {
                type: :string,
                description: 'Token JWT para autenticación'
              },
              administrator: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  email: { type: :string },
                  role: { type: :string, enum: [ 'admin', 'manager' ] }
                }
              }
            },
            required: [ 'token', 'administrator' ]
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
