class AddRanToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :ran, :integer, :default => 0
  end
end
