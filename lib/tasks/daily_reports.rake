namespace :reports do
  desc "Send daily purchases report"
  task send_daily_report: :environment do
    date = ENV['DATE'] ? Date.parse(ENV['DATE']) : Date.yesterday

    puts "Scheduling daily report for #{date}"
    DailyReportJob.perform_async(date.to_s)
    puts "Daily report job scheduled successfully"
  end

  desc "Setup recurring daily reports (for cron)"
  task setup_cron: :environment do
    puts "Add this line to your crontab to run daily reports at 8:00 AM:"
    puts "0 8 * * * cd #{Rails.root} && #{RbConfig.ruby} bin/rails reports:send_daily_report RAILS_ENV=#{Rails.env}"
  end
end
