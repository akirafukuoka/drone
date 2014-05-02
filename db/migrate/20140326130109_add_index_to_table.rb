class AddIndexToTable < ActiveRecord::Migration
  def change
    add_index :coops, :oauth_id
    add_index :coops, :coop_oauth_id
    add_index :entries, :oauth_id
    add_index :posts, :oauth_id
    add_index :posts, :entry_id
    add_index :retweets, :oauth_id
    add_index :retweets, :post_id
  end
end
