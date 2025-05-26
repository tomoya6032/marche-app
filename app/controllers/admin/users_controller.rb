class Admin::UsersController < Admin::BaseController
  def index
    @sellers = Seller.all
    @hosts = Host.all
    @total_sellers = Seller.count
    @total_hosts = Host.count
    @recent_sellers = Seller.order(created_at: :desc).limit(5)
    @recent_hosts = Host.order(created_at: :desc).limit(5)
    @total_events = Event.count
    @recent_events = Event.includes(:seller, :host).order(created_at: :desc).limit(5) # セラーとホストを含めて取得
    @total_notices = Notice.count
    @recent_notices = Notice.order(published_at: :desc).limit(10)
    @notices = Notice.order(published_at: :desc).limit(10) # 最新5件のお知らせを取得
    # 他のデータ取得処理...
  end

  def edit_seller
    @seller = Seller.find_by(id: params[:id])
    @admin_comments = @seller.comments.order(created_at: :desc) if @seller&.respond_to?(:comments)
    if @seller.nil?
      redirect_to admin_sellers_path, alert: "該当するセラーが見つかりませんでした。"
    end
    render 'admin/sellers/edit' # セラー編集用のビューを指定
  end

  def update_seller
    @seller = Seller.find_by(id: params[:id])
    if @seller.nil?
      redirect_to admin_sellers_path, alert: "該当するセラーが見つかりませんでした。"
    elsif @seller.update(admin_comment: params[:admin_comment])
      redirect_to admin_sellers_path, notice: "セラーのコメントを更新しました。"
    else
      flash.now[:alert] = "セラーのコメントの更新に失敗しました。"
      render 'admin/sellers/edit'
    end
  end

  def edit_host
    @host = Host.find_by(id: params[:id])
    @admin_comments = @host.comments.order(created_at: :desc) if @host&.respond_to?(:comments)
    if @host.nil?
      redirect_to admin_hosts_path, alert: "該当するホストが見つかりませんでした。"
    end
    render 'admin/hosts/edit' # ホスト編集用のビューを指定
  end

  def update_host
    @host = Host.find_by(id: params[:id])
    if @host.nil?
      redirect_to admin_hosts_path, alert: "該当するホストが見つかりませんでした。"
    elsif @host.update(admin_comment: params[:admin_comment])
      redirect_to admin_hosts_path, notice: "ホストのコメントを更新しました。"
    else
      flash.now[:alert] = "ホストのコメントの更新に失敗しました。"
      render 'admin/hosts/edit'
    end
  end


  private

  def find_user
    Seller.find_by(id: params[:id]) || Host.find_by(id: params[:id])
  end
end
