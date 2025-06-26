module ActiveJob
  module QueueAdapters
    class SolidQueueAdapter
      def enqueue(job)
        # ジョブをキューに追加するロジックを記述
        Rails.logger.info("Enqueuing job: #{job.class.name}")
      end

      def enqueue_at(job, timestamp)
        # ジョブを指定された時刻にキューに追加するロジックを記述
        Rails.logger.info("Enqueuing job at #{timestamp}: #{job.class.name}")
      end
    end
  end
end