class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :oauth_id
      t.integer :entry_id
      t.string :posted_id

      t.timestamps
    end
  end
end
