class AddVidIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :vid_id, :string
  end
end
