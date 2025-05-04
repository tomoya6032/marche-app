module Admin
  module Sellers
    class CommentsController < ApplicationController
      before_action :set_seller

      def create
        @comment = @seller.comments.new(comment_params)
        if @comment.save
          redirect_to edit_admin_seller_path(@seller), notice: "\u30B3\u30E1\u30F3\u30C8\u304C\u8FFD\u52A0\u3055\u308C\u307E\u3057\u305F\u3002"
        else
          redirect_to edit_admin_seller_path(@seller), alert: "\u30B3\u30E1\u30F3\u30C8\u306E\u8FFD\u52A0\u306B\u5931\u6557\u3057\u307E\u3057\u305F\u3002"
        end
      end

      private

      def set_seller
        @seller = Seller.find(params[:seller_id])
      end

      def comment_params
        params.require(:comment).permit(:body).merge(admin: current_administrator)
      end
    end
  end
end
