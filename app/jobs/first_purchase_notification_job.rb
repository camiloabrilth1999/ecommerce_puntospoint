class FirstPurchaseNotificationJob
  include Sidekiq::Job

  sidekiq_options retry: 3, dead: false

  def perform(purchase_id)
    purchase = Purchase.find(purchase_id)

    # Verificar que sea realmente la primera compra para evitar condiciones de carrera
    return unless purchase.first_purchase_of_product?

    FirstPurchaseNotificationMailer.first_purchase_notification(purchase_id).deliver_now

    Rails.logger.info "First purchase notification sent for purchase ##{purchase_id} - Product: #{purchase.product.name}"
  rescue StandardError => e
    Rails.logger.error "Failed to send first purchase notification for purchase ##{purchase_id}: #{e.message}"
    raise e
  end
end
