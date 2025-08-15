# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 Analytics', type: :request do
  let!(:administrator) { create(:administrator, email: 'admin@test.com', role: 'admin') }
  let(:Authorization) { "Bearer #{JwtService.encode({ administrator_id: administrator.id })}" }

  path '/api/v1/analytics/most_purchased_by_category' do
    get 'Obtener productos más comprados por categoría' do
      tags 'Analytics'
      description 'Obtiene el producto más comprado de cada categoría'
      produces 'application/json'
      security [ Bearer: [] ]

      response '200', 'Productos más comprados por categoría obtenidos exitosamente' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       category_id: { type: :integer },
                       category_name: { type: :string },
                       product: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           sku: { type: :string },
                           purchase_count: { type: :integer }
                         }
                       }
                     }
                   }
                 }
               },
               required: [ 'success', 'data' ]

        let!(:category) { create(:category, administrator: administrator) }
        let!(:product) { create(:product, administrator: administrator, categories: [ category ]) }
        let!(:client) { create(:client) }
        let!(:purchase) { create(:purchase, product: product, client: client, status: 'completed') }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('success')
          expect(data).to have_key('data')
          expect(data['data']).to be_an(Array)
        end
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/analytics/top_revenue_by_category' do
    get 'Obtener productos con mayor facturación por categoría' do
      tags 'Analytics'
      description 'Obtiene el producto que genera más ingresos de cada categoría'
      produces 'application/json'
      security [ Bearer: [] ]

      response '200', 'Productos con mayor facturación por categoría obtenidos exitosamente' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       category_id: { type: :integer },
                       category_name: { type: :string },
                       product: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           sku: { type: :string },
                           total_revenue: { type: :number, format: :decimal }
                         }
                       }
                     }
                   }
                 }
               },
               required: [ 'success', 'data' ]

        let!(:category) { create(:category, administrator: administrator) }
        let!(:product) { create(:product, administrator: administrator, categories: [ category ]) }
        let!(:client) { create(:client) }
        let!(:purchase) { create(:purchase, product: product, client: client, status: 'completed') }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('success')
          expect(data).to have_key('data')
          expect(data['data']).to be_an(Array)
        end
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/analytics/purchases' do
    get 'Obtener lista de compras con filtros' do
      tags 'Analytics'
      description 'Obtiene una lista paginada de compras con filtros opcionales'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :page, in: :query, type: :integer, required: false,
                description: 'Número de página', example: 1
      parameter name: :per_page, in: :query, type: :integer, required: false,
                description: 'Elementos por página (máximo 100)', example: 25
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false,
                description: 'Fecha de inicio (YYYY-MM-DD)', example: '2024-01-01'
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false,
                description: 'Fecha de fin (YYYY-MM-DD)', example: '2024-12-31'
      parameter name: :category_id, in: :query, type: :integer, required: false,
                description: 'ID de categoría para filtrar', example: 1
      parameter name: :client_id, in: :query, type: :integer, required: false,
                description: 'ID de cliente para filtrar', example: 1

      response '200', 'Lista de compras obtenida exitosamente' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       quantity: { type: :integer },
                       unit_price: { type: :number, format: :decimal },
                       total_amount: { type: :number, format: :decimal },
                       purchase_date: { type: :string, format: :datetime },
                       status: { type: :string },
                       product: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           sku: { type: :string }
                         }
                       },
                       client: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           email: { type: :string }
                         }
                       }
                     }
                   }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     per_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               },
               required: [ 'success', 'data', 'pagination' ]

        let!(:category) { create(:category, administrator: administrator) }
        let!(:product) { create(:product, administrator: administrator, categories: [ category ]) }
        let!(:client) { create(:client) }
        let!(:purchase) { create(:purchase, product: product, client: client, status: 'completed') }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('success')
          expect(data).to have_key('data')
          expect(data).to have_key('pagination')
        end
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/v1/analytics/purchases_by_granularity' do
    get 'Obtener compras agrupadas por granularidad temporal' do
      tags 'Analytics'
      description 'Obtiene las compras agrupadas por día, semana, mes o año'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :granularity, in: :query, type: :string, required: true,
                description: 'Granularidad temporal',
                enum: [ 'day', 'week', 'month', 'year' ],
                example: 'month'
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false,
                description: 'Fecha de inicio (YYYY-MM-DD)'
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false,
                description: 'Fecha de fin (YYYY-MM-DD)'
      parameter name: :category_id, in: :query, type: :integer, required: false,
                description: 'ID de categoría para filtrar'

      response '200', 'Compras por granularidad obtenidas exitosamente' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 granularity: { type: :string },
                 start_date: { type: :string },
                 end_date: { type: :string },
                 data: {
                   type: :object,
                   description: 'Datos agrupados por granularidad temporal'
                 }
               },
               required: [ 'success', 'granularity', 'data' ]

        let!(:category) { create(:category, administrator: administrator) }
        let!(:product) { create(:product, administrator: administrator, categories: [ category ]) }
        let!(:client) { create(:client) }
        let!(:purchase) { create(:purchase, product: product, client: client, status: 'completed') }
        let(:granularity) { 'month' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('success')
          expect(data).to have_key('data')
        end
      end

      response '200', 'Granularidad inválida (devuelve datos vacíos)' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 granularity: { type: :string },
                 start_date: { type: :string },
                 end_date: { type: :string },
                 data: {
                   type: :object,
                   description: 'Objeto vacío para granularidades inválidas'
                 }
               },
               required: [ 'success', 'granularity', 'data' ]

        let(:granularity) { 'invalid' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to be true
          expect(data['granularity']).to eq('invalid')
          expect(data['data']).to eq({})
        end
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer invalid_token' }
        let(:granularity) { 'month' }
        run_test!
      end
    end
  end
end
