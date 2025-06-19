# app/controllers/admin/faqs_controller.rb

module Admin
  class FaqsController < Admin::BaseController # Admin::BaseController を継承
    before_action :authenticate_administrator! # 管理者認証 (Administratorモデルを使用)
    before_action :set_faq, only: [:edit, :update, :destroy]

    # FAQ一覧表示
    def index
      @faqs = Faq.all.order(:order) # orderカラムでソートして取得
    end

    # 新規FAQ作成フォーム表示
    def new
      @faq = Faq.new
      # 新規作成時、既存のFAQの最大のorder値+1をデフォルトに設定すると便利です。
      @faq.order = (Faq.maximum(:order) || 0) + 1
    end

    # FAQ作成処理
    def create
      @faq = Faq.new(faq_params)
      if @faq.save
        redirect_to admin_faqs_path, notice: 'FAQ項目を作成しました。'
      else
        # エラーが発生した場合、フォームを再表示し、エラーメッセージをユーザーに伝えます。
        render :new, status: :unprocessable_entity
      end
    end

    # FAQ編集フォーム表示
    def edit
      # set_faq で @faq が設定済み
    end

    # FAQ更新処理
    def update
      if @faq.update(faq_params)
        redirect_to admin_faqs_path, notice: 'FAQ項目を更新しました。'
      else
        # エラーが発生した場合、フォームを再表示し、エラーメッセージをユーザーに伝えます。
        render :edit, status: :unprocessable_entity
      end
    end

    # FAQ削除処理
    def destroy
      @faq.destroy
      redirect_to admin_faqs_path, notice: 'FAQ項目を削除しました。'
    end

    private

    # 共通のFAQ取得メソッド
    def set_faq
      @faq = Faq.find(params[:id])
    end

    # ストロングパラメーター
    def faq_params
      params.require(:faq).permit(:question, :note_url, :order)
    end
  end
end