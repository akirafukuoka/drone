class AddPostedAtToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :posted_at, :datetime
  end
end
