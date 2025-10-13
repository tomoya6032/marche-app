namespace :event_views do
  desc "古い閲覧データをクリーンアップ（30日以前のデータを削除）"
  task cleanup_old_views: :environment do
    puts "古い閲覧データのクリーンアップを開始..."

    # 30日以前のデータを削除
    old_views_count = EventView.where("viewed_at < ?", 30.days.ago).count
    EventView.where("viewed_at < ?", 30.days.ago).delete_all

    puts "#{old_views_count}件の古い閲覧データを削除しました"
    puts "クリーンアップ完了"
  end

  desc "人気イベントのキャッシュを更新"
  task refresh_popular_events: :environment do
    puts "人気イベントデータを更新中..."

    # 人気イベントの上位3つを取得（キャッシュの準備）
    popular_events = Event.popular_this_week(3)

    puts "現在の人気イベント上位3位："
    popular_events.each_with_index do |event, index|
      view_count = event.views_count_this_week
      puts "#{index + 1}位: #{event.title} (#{view_count}回閲覧)"
    end

    puts "人気イベントデータの更新完了"
  end

  desc "週次メンテナンス（古いデータクリーンアップ + キャッシュ更新）"
  task weekly_maintenance: :environment do
    puts "=== 週次メンテナンス開始 ==="

    # 古いデータのクリーンアップ
    Rake::Task["event_views:cleanup_old_views"].invoke

    # 人気イベントキャッシュの更新
    Rake::Task["event_views:refresh_popular_events"].invoke

    puts "=== 週次メンテナンス完了 ==="
  end
end
