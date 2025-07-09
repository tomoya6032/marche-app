class AddSlugToHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :hosts, :slug, :string # ここから , null: false を削除
    add_index :hosts, :slug, unique: true # unique: true のインデックスを追加
  end
end
