require 'test_helper'
require 'sidekiq/api'

module ActiveJob::Cancel::QueueAdapters
  class ActiveJob::Cancel::QueueAdapters::SidekiqAdapterTest< Minitest::Test
    def setup
      ActiveJob::Base.queue_adapter = :sidekiq
    end

    def teardown
    end

    def test_queued_job_with_instance_method
      queue = Sidekiq::Queue.new('active_job_cancel_test')
      assert_equal 0, queue.size

      job = HelloJob.perform_later
      assert_equal 1, queue.size

      job.cancel
      assert_equal 0, queue.size
    ensure
      queue.clear
    end

    def test_queued_job_with_class_method
      queue = Sidekiq::Queue.new('active_job_cancel_test')
      assert_equal 0, queue.size

      job = HelloJob.perform_later
      assert_equal 1, queue.size

      HelloJob.cancel(job.job_id)
      assert_equal 0, queue.size
    ensure
      queue.clear
    end

    def test_scheduled_job_with_instance_method
      assert_equal 0, scheduled_jobs.size

      job = HelloJob.set(wait: 30.seconds).perform_later
      assert_equal 1, scheduled_jobs.size

      job.cancel
      assert_equal 0, scheduled_jobs.size
    ensure
      scheduled_jobs.map(&:delete)
    end

    def test_scheduled_job_with_instance_method
      assert_equal 0, scheduled_jobs.size

      job = HelloJob.set(wait: 30.seconds).perform_later
      assert_equal 1, scheduled_jobs.size

      HelloJob.cancel(job.job_id)
      assert_equal 0, scheduled_jobs.size
    ensure
      scheduled_jobs.map(&:delete)
    end

    private
      def scheduled_jobs
        scheduled_set = Sidekiq::ScheduledSet.new
        scheduled_set.select do |scheduled_job|
          scheduled_job.args.first['queue_name'] == 'active_job_cancel_test'
        end
      end
  end
end
