class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      t.references :user, null: false, foreign_key: true
      t.bigint :admin_id, null: false # 外部キー制約を削除
      t.timestamps
    end
  end
end
