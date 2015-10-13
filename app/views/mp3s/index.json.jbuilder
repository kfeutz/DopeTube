json.array!(@mp3s) do |mp3|
  json.extract! mp3, :id, :title, :artist, :length, :file_size, :file_format, :download_path
  json.url mp3_url(mp3, format: :json)
end
