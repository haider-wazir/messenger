class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # Set default queue name for all jobs
  queue_as :default

  # Add global error handling
  rescue_from StandardError do |exception|
    Rails.logger.error "Job failed: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    raise exception
  end
end
