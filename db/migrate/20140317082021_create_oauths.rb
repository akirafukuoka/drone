class CreateOauths < ActiveRecord::Migration
  def change
    create_table :oauths do |t|
      t.string :provider
      t.string :token
      t.string :token_secret
      t.string :token_expires_at
      t.string :uid
      t.string :name
      t.string :image
      t.boolean :publish, :default => false

      t.timestamps
    end
  end
end
