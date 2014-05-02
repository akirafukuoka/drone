class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :oauth_id
      t.text :description
      t.text :url
      t.boolean :publish, :default => false

      t.timestamps
    end
  end
end
