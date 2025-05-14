class AddNewsAndTopicsAndGoodsToHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :hosts, :news, :text
    add_column :hosts, :topics, :text
    add_column :hosts, :goods_introduction, :text
  end
end
