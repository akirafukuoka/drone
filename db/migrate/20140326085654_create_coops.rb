class CreateCoops < ActiveRecord::Migration
  def change
    create_table :coops do |t|
      t.integer :oauth_id
      t.integer :coop_oauth_id

      t.timestamps
    end
  end
end
