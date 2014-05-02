class AddRandomToOauths < ActiveRecord::Migration
  def change
    add_column :oauths, :random, :boolean, :default => false
  end
end
