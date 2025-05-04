class AddPrefectureToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :prefecture, :string
  end
end
