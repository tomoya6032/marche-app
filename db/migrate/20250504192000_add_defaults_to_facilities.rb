class AddDefaultsToFacilities < ActiveRecord::Migration[6.1]
  def change
    change_column_default :facilities, :name, ''
    change_column_default :facilities, :description, ''
    change_column_default :facilities, :address, ''
    change_column_default :facilities, :phone_number, ''
    change_column_default :facilities, :website, ''
  end
end
