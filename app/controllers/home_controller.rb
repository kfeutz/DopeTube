class HomeController < ApplicationController
  @@videos = []

  def index
    unless @videos
      @videos = []
    end
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
      # This API call takes days
      #duration = retrieve_youtube_content_details(youtube_vid.id.videoId)
      #puts('Duration: ' + duration)
  		vids << Video.new(
  			:vid_id =>  youtube_vid.id.videoId,
  			:title => youtube_vid.snippet.title,
  			:description => youtube_vid.snippet.description,
  			:embed_url => 'https://www.youtube.com/embed/' + youtube_vid.id.videoId.to_s,
        :duration => "N/A"
  		)
	  end
	  return vids
  end

  # Gather video objects and pass to download controller
  def add_to_cart
    vid_ids = params[:video_id]
    # Save all video objects that will be downloaded
    @@videos.each do |video|
      # If selected video id matches id out of search result videos, add the videos to cart
      if vid_ids.include? video.vid_id
        @cart.videos <<
          Video.create(
            :vid_id =>  video.vid_id,
            :title => video.title,
            :description => video.description,
            :embed_url => video.embed_url,
            :duration => video.duration
          )
        
      end
    end

    redirect_to carts_url
  end
end
