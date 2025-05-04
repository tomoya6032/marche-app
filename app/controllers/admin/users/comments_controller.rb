class Admin::Users::CommentsController < Admin::BaseController
  def create
    @user = Seller.find_by(id: params[:user_id]) || Host.find_by(id: params[:user_id])
    Rails.logger.debug "User: #{@user.inspect}" # デバッグログを追加

    if @user.nil?
      redirect_to admin_users_path, alert: "\u8A72\u5F53\u3059\u308B\u30E6\u30FC\u30B6\u30FC\u304C\u898B\u3064\u304B\u308A\u307E\u305B\u3093\u3067\u3057\u305F\u3002"
      return
    end

    if params[:comment][:body].blank?
      redirect_to edit_admin_user_path(@user), alert: "\u30B3\u30E1\u30F3\u30C8\u304C\u7A7A\u3067\u3059\u3002"
      return
    end

    @comment = Comment.new(comment_params)
    if @user.is_a?(User)
      @comment.user_id = @user.id
    elsif @user.is_a?(Seller)
      @comment.seller_id = @user.id
    elsif @user.is_a?(Host)
      @comment.host_id = @user.id
    end

    Rails.logger.debug "Comment: #{@comment.inspect}" # デバッグログを追加

    if @comment.save
      redirect_to edit_admin_user_path(@user), notice: "\u30B3\u30E1\u30F3\u30C8\u304C\u8FFD\u52A0\u3055\u308C\u307E\u3057\u305F\u3002"
    else
      redirect_to edit_admin_user_path(@user), alert: "\u30B3\u30E1\u30F3\u30C8\u306E\u8FFD\u52A0\u306B\u5931\u6557\u3057\u307E\u3057\u305F\u3002"
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body).merge(admin_id: current_admin.id)
  end
end
