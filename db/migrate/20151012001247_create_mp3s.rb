class CreateMp3s < ActiveRecord::Migration
  def change
    create_table :mp3s do |t|
      t.string :title
      t.string :artist
      t.string :length
      t.string :file_size
      t.string :file_format
      t.string :download_path

      t.timestamps null: false
    end
  end
end
