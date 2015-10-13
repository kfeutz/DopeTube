class AddCartIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :cart_id, :integer
  end
end
