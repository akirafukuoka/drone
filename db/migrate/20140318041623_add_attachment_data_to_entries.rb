class AddAttachmentDataToEntries < ActiveRecord::Migration
  def self.up
    change_table :entries do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :entries, :image
  end
end
