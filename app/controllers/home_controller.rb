class HomeController < ApplicationController
  @@videos = []

  def index

  end

  def search
  	search_string = params[:q]
  	youtube_vids = search_youtube(search_string)
  	@@videos = create_vids_from_youtube(youtube_vids)
    @videos = @@videos
  	render :index
  end
  # Creates Videos from the youtube response
  def create_vids_from_youtube(youtube_vids)
  	vids = []
  	youtube_vids.each do |youtube_vid|
  		vids << Video.new(
  			:vid_id =>  youtube_vid.id.videoId,
  			:title => youtube_vid.snippet.title,
  			:description => youtube_vid.snippet.description,
  			:embed_url => 'https://www.youtube.com/embed/' + youtube_vid.id.videoId.to_s
  		)
	  end
	  return vids
  end

  # Gather video objects and pass to download controller
  def download
    vid_ids = params[:video_ids]
    # Save all video objects that will be downloaded
    @@videos.each do |video|
      puts "YPOOOOO IJM HEREER "
      if vid_ids.include? video.vid_id
        Video.create(
          :vid_id =>  video.vid_id,
          :title => video.title,
          :description => video.description,
          :embed_url => video.embed_url
        )
      end
    end

    redirect_to download_index_url
  end
end
