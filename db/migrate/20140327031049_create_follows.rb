class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :oauth_id
      t.string :twitter_id

      t.timestamps
    end
    add_index :follows, :oauth_id
  end
end
