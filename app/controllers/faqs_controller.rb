class FaqsController < ApplicationController
  def index
    # Faqモデルに default_scope { order(:order) } を設定しているので、
    # シンプルに Faq.all で取得すれば、orderカラムの昇順で並んだFAQが取得されます。
    @faqs = Faq.all
  end
end
