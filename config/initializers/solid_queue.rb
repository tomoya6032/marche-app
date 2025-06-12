# config/initializers/solid_queue.rb

# Rails.application.configure do # この行と end を削除
#   config.solid_queue.connects_to = { database: { writing: :queue } }
# end

# 代わりに、直接 SolidQueue モジュールを設定する
# SolidQueue.connects_to = { database: { writing: :queue } }

# もし将来的に Solid Queue の他の設定（例: max_threads）を追加する場合は、
# ここに直接記述します。
# SolidQueue.max_threads = 5