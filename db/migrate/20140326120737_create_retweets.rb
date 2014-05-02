class CreateRetweets < ActiveRecord::Migration
  def change
    create_table :retweets do |t|
      t.integer :oauth_id
      t.integer :post_id

      t.timestamps
    end
  end
end
