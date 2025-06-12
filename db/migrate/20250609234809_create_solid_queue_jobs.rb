class CreateSolidQueueJobs < ActiveRecord::Migration[8.0] # ここを 8.0 に変更
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false # Solid Queue 1.1.5 では :queue_name がデフォルト。もし現在のマイグレーションが :queue ならそのまま
      t.string :class_name, null: false # Solid Queue 1.1.5 では :class_name がデフォルト。もし現在のマイグレーションが :job_class ならそのまま
      t.json :arguments # null: false と default: [] を削除
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :failed_at
      t.integer :attempts, null: false, default: 0
      t.text :error_message
      t.timestamps
    end

    add_index :solid_queue_jobs, :queue_name # 同上
    add_index :solid_queue_jobs, :class_name # 同上
    add_index :solid_queue_jobs, :scheduled_at
  end
end