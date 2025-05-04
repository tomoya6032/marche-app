class AddSellerIdToEvents < ActiveRecord::Migration[8.0]
  def change
    # seller_id カラムが存在しない場合のみ追加
    unless column_exists?(:events, :seller_id)
      add_reference :events, :seller, foreign_key: true
    end
  end
end
