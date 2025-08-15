class Api::V1::AnalyticsController < ApplicationController
  include JwtAuthentication



  # API 1: Obtener los Productos más comprados por cada categoría
  # GET /api/v1/analytics/most_purchased_by_category
  # Headers: Authorization: Bearer <JWT_TOKEN>
  # Response: { success: true, data: [{ category_id, category_name, product: { id, name, sku, purchase_count } }] }
  def most_purchased_by_category
    result = Rails.cache.fetch("most_purchased_by_category", expires_in: 1.hour) do
      categories = Category.active.includes(:products)

      categories.map do |category|
        most_purchased_product = category.products
                                        .joins(:purchases)
                                        .where(purchases: { status: "completed" })
                                        .group("products.id")
                                        .order("COUNT(purchases.id) DESC")
                                        .first

        if most_purchased_product
          purchase_count = most_purchased_product.purchases.completed.count
          {
            category_id: category.id,
            category_name: category.name,
            product: {
              id: most_purchased_product.id,
              name: most_purchased_product.name,
              sku: most_purchased_product.sku,
              purchase_count: purchase_count
            }
          }
        else
          {
            category_id: category.id,
            category_name: category.name,
            product: nil
          }
        end
      end
    end

    render json: { success: true, data: result }, status: :ok
  end

  # API 2: Obtener los 3 Productos que más han recaudado ($) por categoría
  # GET /api/v1/analytics/top_revenue_by_category
  # Headers: Authorization: Bearer <JWT_TOKEN>
  # Response: { success: true, data: [{ category_id, category_name, top_products: [{ id, name, sku, total_revenue }] }] }
  def top_revenue_by_category
    result = Rails.cache.fetch("top_revenue_by_category", expires_in: 1.hour) do
      categories = Category.active.includes(:products)

      categories.map do |category|
        top_products = category.products
                              .joins(:purchases)
                              .where(purchases: { status: "completed" })
                              .group("products.id")
                              .order("SUM(purchases.total_amount) DESC")
                              .limit(3)
                              .select("products.*, SUM(purchases.total_amount) as total_revenue")

        products_data = top_products.map do |product|
          {
            id: product.id,
            name: product.name,
            sku: product.sku,
            total_revenue: product.total_revenue.to_f
          }
        end

        {
          category_id: category.id,
          category_name: category.name,
          top_products: products_data
        }
      end
    end

    render json: { success: true, data: result }, status: :ok
  end

  # API 3: Obtener listado de compras según parámetros
  # GET /api/v1/analytics/purchases?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD&category_id=1&client_id=1&administrator_id=1&page=1&per_page=25
  # Headers: Authorization: Bearer <JWT_TOKEN>
  # Response: { success: true, data: [...], pagination: { current_page, total_pages, total_count, per_page } }
  def purchases
    purchases = Purchase.completed.includes(:product, :client, product: [ :administrator, :categories ])

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
          categories: purchase.product.categories.pluck(:name),
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

    result = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      purchases = Purchase.completed.by_date_range(start_date, end_date)

      # Aplicar filtros adicionales
      purchases = purchases.by_category(params[:category_id]) if params[:category_id].present?
      purchases = purchases.by_client(params[:client_id]) if params[:client_id].present?
      purchases = purchases.by_administrator(params[:administrator_id]) if params[:administrator_id].present?

      case granularity
      when "hour"
        purchases.group_by_hour(:purchase_date).count
      when "day"
        purchases.group_by_day(:purchase_date).count
      when "week"
        purchases.group_by_week(:purchase_date).count
      when "year"
        purchases.group_by_year(:purchase_date).count
      else
        {}
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
