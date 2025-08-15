class DailyReportMailer < ApplicationMailer
  def daily_purchases_report(date = Date.yesterday)
    @date = date
    @purchases = Purchase.daily_report(@date)
    @total_purchases = @purchases.count
    @total_revenue = @purchases.sum(:total_amount)
    @products_sold = @purchases.joins(:product).group("products.name").sum(:quantity)
    @top_products = @purchases.joins(:product)
                              .group("products.name", "products.id")
                              .order(Arel.sql("COUNT(*) DESC"))
                              .limit(5)
                              .count

    @administrators = Administrator.active

    mail(
      to: @administrators.pluck(:email),
      subject: "Reporte Diario de Compras - #{@date.strftime('%d/%m/%Y')}"
    )
  end
end
