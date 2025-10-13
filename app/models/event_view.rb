class EventView < ApplicationRecord
  belongs_to :event

  validates :ip_address, presence: true
  validates :viewed_at, presence: true

  scope :recent_week, -> { where(viewed_at: 1.week.ago..Time.current) }
  scope :today, -> { where(viewed_at: Date.current.beginning_of_day..Date.current.end_of_day) }

  # 同じIPアドレスから同じイベントへの重複アクセスを1日1回に制限
  def self.record_view!(event, ip_address)
    today_start = Date.current.beginning_of_day
    today_end = Date.current.end_of_day

    # 今日同じIPから同じイベントへのアクセスがあるかチェック
    existing_view = find_by(
      event: event,
      ip_address: ip_address,
      viewed_at: today_start..today_end
    )

    # 今日初回のアクセスの場合のみ記録
    unless existing_view
      create!(
        event: event,
        ip_address: ip_address,
        viewed_at: Time.current
      )
    end
  end
end
