class DailyReportJob
  include Sidekiq::Job

  sidekiq_options retry: 2, dead: false

  def perform(date = Date.yesterday)
    date = Date.parse(date) if date.is_a?(String)

    Rails.logger.info "Starting daily report generation for #{date}"

    DailyReportMailer.daily_purchases_report(date).deliver_now

    Rails.logger.info "Daily report sent successfully for #{date}"
  rescue StandardError => e
    Rails.logger.error "Failed to generate daily report for #{date}: #{e.message}"
    raise e
  end
end
