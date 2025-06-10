class CreateSolidQueueJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue, null: false
      t.string :job_class, null: false
      t.json :arguments, null: false, default: []
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :failed_at
      t.integer :attempts, null: false, default: 0
      t.text :error_message
      t.timestamps
    end

    add_index :solid_queue_jobs, :queue
    add_index :solid_queue_jobs, :job_class
    add_index :solid_queue_jobs, :scheduled_at
  end
end
