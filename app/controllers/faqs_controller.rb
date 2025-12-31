class FaqsController < ApplicationController
  def index
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "よくある質問", path: public_faqs_path}]
    begin
      @faqs = Faq.order(:order)
    rescue => e
      Rails.logger.error "FAQ取得エラー: #{e.message}"
      @faqs = []
    end
  end
end
