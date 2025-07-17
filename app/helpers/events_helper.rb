module EventsHelper
  def sort_options
    [
      ['作成日時の新しい順', 'created_at_desc'],
      ['開催日の昇順', 'start_time_asc'], # ★ここを 'start_date_asc' から 'start_time_asc' に変更
      ['開催日の降順', 'start_time_desc'],  # ★ここを 'start_date_desc' から 'start_time_desc' に変更
      ['開催予定が近い順', 'upcoming_first'] # ★追加
    ]
  end
end
