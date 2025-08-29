class Api::V1::AnalyticsController < ApplicationController
  include JwtAuthentication



  # API 1: Obtener los Productos más comprados por cada categoría
  # GET /api/v1/analytics/most_purchased_by_category
  # Headers: Authorization: Bearer <JWT_TOKEN>
  # Response: { success: true, data: [{ category_id, category_name, product: { id, name, sku, purchase_count } }] }
  def most_purchased_by_category
    result = Rails.cache.fetch("most_purchased_by_category", expires_in: 12.hours) do
      sql_query = <<~SQL
        WITH ranked_products AS (
          SELECT
            c.id as category_id,
            c.name as category_name,
            p.id as product_id,
            p.name as product_name,
            p.sku,
            COUNT(pu.id) as purchase_count,
            ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY COUNT(pu.id) DESC) as rank
          FROM categories c
          JOIN product_categories pc ON c.id = pc.category_id
          JOIN products p ON pc.product_id = p.id
          JOIN purchases pu ON p.id = pu.product_id
          WHERE c.active = true AND pu.status = 'completed'
          GROUP BY c.id, c.name, p.id, p.name, p.sku
        )
        SELECT * FROM ranked_products
        WHERE rank = 1
        ORDER BY category_id
      SQL

      sql_result = ActiveRecord::Base.connection.execute(sql_query)

      # Procesamiento mínimo en Ruby - solo formateo
      categories_data = {}
      sql_result.each do |row|
        category_id = row["category_id"]
        categories_data[category_id] = {
          category_id: category_id,
          category_name: row["category_name"],
          product: {
            id: row["product_id"],
            name: row["product_name"],
            sku: row["sku"],
            purchase_count: row["purchase_count"]
          }
        }
      end

      # Incluir categorías sin productos comprados
      Category.active.where.not(id: categories_data.keys).find_each do |category|
        categories_data[category.id] = {
          category_id: category.id,
          category_name: category.name,
          product: nil
        }
      end

      categories_data.values.sort_by { |item| item[:category_id] }
    end

    render json: { success: true, data: result }, status: :ok
  end

  # API 2: Obtener los 3 Productos que más han recaudado ($) por categoría
  # GET /api/v1/analytics/top_revenue_by_category
  # Headers: Authorization: Bearer <JWT_TOKEN>
  # Response: { success: true, data: [{ category_id, category_name, top_products: [{ id, name, sku, total_revenue }] }] }
  def top_revenue_by_category
    result = Rails.cache.fetch("top_revenue_by_category", expires_in: 12.hours) do
      categories_data = {}

      Category.active.find_each do |category|
        top_products = category.products
                              .joins(:purchases)
                              .where(purchases: { status: "completed" })
                              .group("products.id", "products.name", "products.sku")
                              .select("products.*, SUM(purchases.total_amount) as total_revenue")
                              .order("SUM(purchases.total_amount) DESC")
                              .limit(3)

        categories_data[category.id] = {
          category_id: category.id,
          category_name: category.name,
          top_products: top_products.map do |product|
            {
              id: product.id,
              name: product.name,
              sku: product.sku,
              total_revenue: product.total_revenue.to_f
            }
          end
        }
      end

      categories_data.values.sort_by { |item| item[:category_id] }
    end

    render json: { success: true, data: result }, status: :ok
  end

  # API 3: Obtener listado de compras según parámetros
  # GET /api/v1/analytics/purchases?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD&category_id=1&client_id=1&administrator_id=1&page=1&per_page=25
  # Headers: Authorization: Bearer <JWT_TOKEN>
  # Response: { success: true, data: [...], pagination: { current_page, total_pages, total_count, per_page } }
  def purchases
    purchases = Purchase.completed.includes(:product, :client, product: [ :administrator, { categories: [] } ])

    # Filtros
    purchases = purchases.by_date_range(params[:start_date], params[:end_date]) if params[:start_date] && params[:end_date]
    purchases = purchases.by_category(params[:category_id]) if params[:category_id].present?
    purchases = purchases.by_client(params[:client_id]) if params[:client_id].present?
    purchases = purchases.by_administrator(params[:administrator_id]) if params[:administrator_id].present?

    # Paginación
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    purchases = purchases.page(page).per(per_page)

    result = purchases.map do |purchase|
      {
        id: purchase.id,
        quantity: purchase.quantity,
        unit_price: purchase.unit_price.to_f,
        total_amount: purchase.total_amount.to_f,
        purchase_date: purchase.purchase_date,
        status: purchase.status,
        product: {
          id: purchase.product.id,
          name: purchase.product.name,
          sku: purchase.product.sku,
          categories: purchase.product.categories.map(&:name),
          administrator: {
            id: purchase.product.administrator.id,
            name: purchase.product.administrator.name
          }
        },
        client: {
          id: purchase.client.id,
          name: purchase.client.name,
          email: purchase.client.email
        }
      }
    end

    render json: {
      success: true,
      data: result,
      pagination: {
        current_page: purchases.current_page,
        total_pages: purchases.total_pages,
        total_count: purchases.total_count,
        per_page: purchases.limit_value
      }
    }, status: :ok
  end

  # API 4: Obtener cantidad de compras según granularidad
  # GET /api/v1/analytics/purchases_by_granularity?granularity=day&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD&category_id=1&client_id=1&administrator_id=1
  # Headers: Authorization: Bearer <JWT_TOKEN>
  # Granularity: hour, day, week, year
  # Response: { success: true, granularity, start_date, end_date, data: { "2023-05-01": 10, "2023-05-02": 15 } }
  def purchases_by_granularity
    granularity = params[:granularity] || "day"
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : 1.month.ago
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.current

    cache_key = "purchases_by_granularity_#{granularity}_#{start_date}_#{end_date}_#{params[:category_id]}_#{params[:client_id]}_#{params[:administrator_id]}"

    result = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      # OPTIMIZACIÓN: ActiveRecord con groupdate - más legible y mantenible
      # Con índices apropiados, el performance es aceptable
      purchases = Purchase.completed.by_date_range(start_date, end_date)

      # Aplicar filtros de forma eficiente con includes para evitar N+1
      purchases = purchases.by_category(params[:category_id]) if params[:category_id].present?
      purchases = purchases.by_client(params[:client_id]) if params[:client_id].present?
      purchases = purchases.by_administrator(params[:administrator_id]) if params[:administrator_id].present?

      # Usar groupdate con los índices optimizados que agregamos
      case granularity
      when "hour"
        purchases.group_by_hour(:purchase_date, time_zone: "UTC").count
      when "day"
        purchases.group_by_day(:purchase_date, time_zone: "UTC").count
      when "week"
        purchases.group_by_week(:purchase_date, time_zone: "UTC").count
      when "year"
        purchases.group_by_year(:purchase_date, time_zone: "UTC").count
      else
        purchases.group_by_day(:purchase_date, time_zone: "UTC").count
      end
    end

    render json: {
      success: true,
      granularity: granularity,
      start_date: start_date,
      end_date: end_date,
      data: result
    }, status: :ok
  end

  private

  def analytics_params
    params.permit(:start_date, :end_date, :category_id, :client_id, :administrator_id, :granularity, :page, :per_page)
  end
end
