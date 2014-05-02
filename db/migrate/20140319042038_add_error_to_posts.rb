class AddErrorToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :error, :boolean, :default => false
  end
end
