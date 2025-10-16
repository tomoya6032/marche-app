class FaqsController < ApplicationController
  def index
    begin
      @faqs = Faq.order(:order)
    rescue => e
      Rails.logger.error "FAQ取得エラー: #{e.message}"
      @faqs = []
    end
  end
end
