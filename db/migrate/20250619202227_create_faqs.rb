# db/migrate/YYYYMMDDHHMMSS_create_faqs.rb

class CreateFaqs < ActiveRecord::Migration[8.0]
  def change
    create_table :faqs do |t|
      t.string :question, null: false
      t.string :note_url, null: false
      t.integer :order, default: 0

      t.timestamps
    end

    # 頻繁に検索される可能性があるため、question にインデックスを追加するのも良いでしょう (任意)
    # add_index :faqs, :question

    # order によるソートが頻繁に行われる場合、インデックスを追加することも検討 (任意)
    # add_index :faqs, :order
  end
end
