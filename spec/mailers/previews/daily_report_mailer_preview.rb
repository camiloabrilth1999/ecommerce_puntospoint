# Preview all emails at http://localhost:3000/rails/mailers/daily_report_mailer_mailer
class DailyReportMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/daily_report_mailer_mailer/daily_purchases_report
  def daily_purchases_report
    DailyReportMailer.daily_purchases_report
  end

end
