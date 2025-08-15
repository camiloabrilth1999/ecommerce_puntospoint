# Preview all emails at http://localhost:3000/rails/mailers/first_purchase_notification_mailer_mailer
class FirstPurchaseNotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/first_purchase_notification_mailer_mailer/first_purchase_notification
  def first_purchase_notification
    FirstPurchaseNotificationMailer.first_purchase_notification
  end

end
