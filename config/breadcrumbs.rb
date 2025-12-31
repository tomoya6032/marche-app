# Gretel breadcrumbs configuration
# See https://github.com/kzkn/gretel for more details

# ルート（ホーム）
crumb :root do
  link "ホーム", root_path
end

# イベント一覧
crumb :events do
  link "イベント一覧", events_path
  parent :root
end

# イベント詳細
crumb :event do |event|
  link event.title, event_path(event)
  parent :events
end

# 出店一覧
crumb :facilities do
  link "出店一覧", facilities_path
  parent :root
end

# 出店詳細
crumb :facility do |facility|
  link facility.name, facility_path(facility)
  parent :facilities
end

# ホスト一覧
crumb :hosts do
  link "ホスト一覧", hosts_path
  parent :root
end

# ホスト詳細
crumb :host do |host|
  link host.name, public_host_profile_path(host.slug.presence || host.id)
  parent :hosts
end

# セラー一覧
crumb :sellers do
  link "セラー一覧", sellers_path
  parent :root
end

# セラー詳細
crumb :seller do |seller|
  link seller.name, seller_path(seller)
  parent :sellers
end

# 機能一覧
crumb :features do
  link "機能一覧", features_path
  parent :root
end

# 料金について
crumb :pricing do
  link "利用料金", pricing_path
  parent :root
end

# プラン比較
crumb :plan_comparison do
  link "プラン比較", plan_comparison_path
  parent :root
end

# 出店者募集
crumb :recruitment do
  link "出店者募集", recruitment_path
  parent :root
end

# 掲載までの流れ
crumb :flow do
  link "掲載までの流れ", flow_path
  parent :root
end

# 利用事例
crumb :use_cases do
  link "利用事例", use_cases_path
  parent :root
end

# FAQ
crumb :faqs do
  link "よくある質問", public_faqs_path
  parent :root
end

# 利用規約
crumb :terms do
  link "利用規約", terms_path
  parent :root
end

# プライバシーポリシー
crumb :privacy do
  link "プライバシーポリシー", privacy_path
  parent :root
end

# 特定商取引法
crumb :commercial_law do
  link "特定商取引法に基づく表示", commercial_law_path
  parent :root
end

# 管理画面
crumb :admin do
  link "管理画面", administrator_dashboard_path
end

# 管理画面 - ユーザー一覧
crumb :admin_users do
  link "ユーザー一覧", admin_users_path
  parent :admin
end

# 管理画面 - イベント一覧
crumb :admin_events do
  link "イベント一覧", admin_events_path
  parent :admin
end

# 管理画面 - ホスト一覧
crumb :admin_hosts do
  link "ホスト一覧", admin_hosts_path
  parent :admin
end

# 管理画面 - セラー一覧
crumb :admin_sellers do
  link "セラー一覧", admin_sellers_path
  parent :admin
end

# 管理画面 - お知らせ一覧
crumb :admin_notices do
  link "お知らせ一覧", admin_notices_path
  parent :admin
end

# 管理画面 - FAQ一覧
crumb :admin_faqs do
  link "FAQ一覧", admin_faqs_path
  parent :admin
end
