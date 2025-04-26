module EventsHelper
  def sort_options
    [
      ['作成日時 (新しい順)', 'created_at_desc'],
      ['開催日時 (近い順)', 'start_time_asc'],
      ['開催日時 (遠い順)', 'start_time_desc']
    ]
  end
end
