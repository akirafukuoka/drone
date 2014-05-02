class AddHourToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :post_hour, :integer
    add_column :entries, :post_min, :integer
  end
end
