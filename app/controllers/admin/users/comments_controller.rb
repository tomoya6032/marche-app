class Admin::Users::CommentsController < Admin::BaseController
  before_action :set_user

  def create
    @comment = @user.comments.new(comment_params)
    if @comment.save
      redirect_to edit_admin_user_path(@user), notice: "コメントが追加されました。"
    else
      redirect_to edit_admin_user_path(@user), alert: "コメントの追加に失敗しました。"
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_users_path, alert: "該当するユーザーが見つかりませんでした。"
  end

  def comment_params
    params.require(:comment).permit(:body).merge(admin: current_administrator)
  end
end
