class AddBookmarkletToOauths < ActiveRecord::Migration
  def change
    add_column :oauths, :bookmarklet, :text
  end
end
