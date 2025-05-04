module Admin
  module Hosts
    class CommentsController < ApplicationController
      before_action :set_host

      def create
        @comment = @host.comments.new(comment_params)
        if @comment.save
          redirect_to edit_admin_host_path(@host), notice: "\u30B3\u30E1\u30F3\u30C8\u304C\u8FFD\u52A0\u3055\u308C\u307E\u3057\u305F\u3002"
        else
          redirect_to edit_admin_host_path(@host), alert: "\u30B3\u30E1\u30F3\u30C8\u306E\u8FFD\u52A0\u306B\u5931\u6557\u3057\u307E\u3057\u305F\u3002"
        end
      end

      private

      def set_host
        @host = Host.find(params[:host_id])
      end

      def comment_params
        params.require(:comment).permit(:body).merge(admin: current_administrator)
      end
    end
  end
end
