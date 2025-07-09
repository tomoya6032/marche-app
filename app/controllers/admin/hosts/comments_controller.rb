module Admin
  module Hosts
    class CommentsController < ApplicationController
      before_action :set_host

      def create
        @comment = @host.comments.build(comment_params)
        if @comment.save
          redirect_to edit_admin_host_path(@host.slug), notice: "コメントを保存しました。"
        else
          redirect_to edit_admin_host_path(@host.slug), alert: "コメントの保存に失敗しました。"
        end
      end

      private

      def set_host
        @host = Host.find_by!(slug: params[:host_id]) # `host_id` を `slug` として検索
      rescue ActiveRecord::RecordNotFound
        redirect_to admin_hosts_path, alert: "指定されたホストが見つかりませんでした。"
      end

      def comment_params
        params.require(:comment).permit(:body).merge(admin: current_administrator)
      end
    end
  end
end
