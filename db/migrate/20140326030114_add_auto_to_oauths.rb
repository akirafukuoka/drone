class AddAutoToOauths < ActiveRecord::Migration
  def change
    add_column :oauths, :auto_follow, :boolean, :default => false
    add_column :oauths, :auto_retweet, :boolean, :default => false
  end
end
