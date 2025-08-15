require 'sidekiq/testing'

RSpec.configure do |config|
  config.before(:each) do
    # Clear all Sidekiq jobs before each test
    Sidekiq::Worker.clear_all

    # Use fake mode by default (jobs are stored in memory, not executed)
    Sidekiq::Testing.fake!
  end

  config.after(:each) do
    # Clean up after each test
    Sidekiq::Worker.clear_all
  end
end

# Helper methods for testing Sidekiq jobs
module SidekiqTestHelpers
  def clear_sidekiq_jobs
    Sidekiq::Worker.clear_all
  end

  def sidekiq_jobs_count(job_class)
    job_class.jobs.size
  end

  def execute_sidekiq_jobs
    Sidekiq::Testing.inline! do
      yield if block_given?
    end
  end
end

RSpec.configure do |config|
  config.include SidekiqTestHelpers
end
