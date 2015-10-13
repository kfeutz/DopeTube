class AddDownloadReadyToMp3s < ActiveRecord::Migration
  def change
    add_column :mp3s, :download_ready, :boolean
  end
end
