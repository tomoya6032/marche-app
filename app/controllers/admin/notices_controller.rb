module Admin
  class NoticesController < ApplicationController
    before_action :set_notice, only: [ :edit, :update, :destroy]

    def index
      @notices = Notice.order(published_at: :desc)
    end

    def show
      
    end

    def new
      @notice = Notice.new
      # 新規作成フォーム表示時に、初期値として現在時刻を設定することもできますが、
      # createアクションで設定するのであれば必須ではありません。
      # @notice.published_at = Time.current # 初期表示が必要なら追加
    end

    def create
      @notice = Notice.new(notice_params)

      # --- ★ ここを修正 ★ ---
      # published_at をフォームから受け取らず、現在時刻を設定する
      @notice.published_at = Time.current

      if @notice.save
        redirect_to admin_notices_path, notice: 'お知らせを作成しました。'
        # リダイレクト先が admin_users_path になっていましたが、
        # admin_notices_path の方が適切かと思い修正しました。
        # 必要に応じて元の admin_users_path に戻してください。
      else
        render :new
      end
    end

    def edit
    end

    def update
      # --- ★ ここも修正（更新時も現在時刻にする場合） ★ ---
      # 更新時も自動的に現在時刻にする場合
      if @notice.update(notice_params.except(:published_at).merge(published_at: Time.current))
        redirect_to admin_notices_path, notice: 'お知らせを更新しました。'
      else
        render :edit
      end
      # もし更新時は手動で日時を指定したい場合は、updateアクションの修正は不要です。
      # その場合、published_at は notice_params に含めておいてください。
    end

    def destroy
       @notice.destroy
       redirect_to admin_users_path, notice: 'お知らせを削除しました。'
    end

    private

    def set_notice
      @notice = Notice.find(params[:id])
    end

    def notice_params
      # --- ★ ここを修正 ★ ---
      # published_at はフォームから受け取らないので、permitから削除する
      params.require(:notice).permit(:title, :content) # published_at を削除
    end
  end
end