# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 Authentication', type: :request do
  path '/api/v1/auth/login' do
    post 'Iniciar sesión de administrador' do
      tags 'Autenticación'
      description 'Autentica un administrador y devuelve un token JWT'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :administrator, in: :body, schema: {
        type: :object,
        properties: {
          administrator: {
            '$ref' => '#/components/schemas/LoginRequest'
          }
        },
        required: [ 'administrator' ]
      }

      response '200', 'Login exitoso' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 token: { type: :string },
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
               required: [ 'success', 'token', 'administrator' ]

        let!(:admin_user) { create(:administrator, email: 'admin@test.com', password: 'password123', role: 'admin') }
        let(:administrator) do
          {
            administrator: {
              email: 'admin@test.com',
              password: 'password123'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('success')
          expect(data).to have_key('token')
          expect(data).to have_key('administrator')
          expect(data['administrator']['email']).to eq('admin@test.com')
        end
      end

      response '401', 'Credenciales inválidas' do
        schema '$ref' => '#/components/schemas/Error'

        let(:administrator) do
          {
            administrator: {
              email: 'wrong@test.com',
              password: 'wrongpassword'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end

      response '401', 'Parámetros faltantes' do
        schema '$ref' => '#/components/schemas/Error'

        let(:administrator) do
          {
            administrator: {
              email: 'admin@test.com'
              # password missing
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end
    end
  end

  path '/api/v1/auth/validate' do
    get 'Validar token JWT' do
      tags 'Autenticación'
      description 'Valida un token JWT y devuelve información del administrador'
      produces 'application/json'
      security [ Bearer: [] ]

      response '200', 'Token válido' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
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
               required: [ 'success', 'administrator' ]

        let!(:admin_user) { create(:administrator, email: 'admin@test.com', role: 'admin') }
        let(:Authorization) { "Bearer #{JwtService.encode({ administrator_id: admin_user.id })}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('success')
          expect(data).to have_key('administrator')
          expect(data['administrator']['id']).to eq(admin_user.id)
        end
      end

      response '401', 'Token inválido o faltante' do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end
    end
  end
end
