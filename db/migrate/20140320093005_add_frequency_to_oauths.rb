class AddFrequencyToOauths < ActiveRecord::Migration
  def change
    add_column :oauths, :frequency, :string, :default => 'hour'
    add_column :oauths, :base_hour, :integer, :default => 0
    add_column :oauths, :base_min, :integer, :default => 0
  end
end
