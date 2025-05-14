class AddMultipleGoodsToHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :hosts, :goods_introduction_1, :text
    add_column :hosts, :goods_introduction_2, :text
    add_column :hosts, :goods_introduction_3, :text
    add_column :hosts, :goods_introduction_4, :text
  end
end
