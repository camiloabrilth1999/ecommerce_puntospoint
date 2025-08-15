class FirstPurchaseNotificationMailer < ApplicationMailer
  def first_purchase_notification(purchase_id)
    @purchase = Purchase.includes(:product, :client, product: [:administrator, :categories]).find(purchase_id)
    @product = @purchase.product
    @client = @purchase.client
    @product_creator = @product.administrator
    @other_administrators = Administrator.active.where.not(id: @product_creator.id)

    # Email dirigido al creador del producto
    mail(
      to: @product_creator.email,
      cc: @other_administrators.pluck(:email),
      subject: "Primera compra del producto: #{@product.name}"
    )
  end
end
