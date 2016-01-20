#Youtube API requirements
require 'rubygems'
require 'google/api_client'
require 'trollop'
require 'open3'

class ApplicationController < ActionController::Base
    # Retrive the cart in each controller
    before_action :get_cart_for_user
  
	#Read API token for api access
	DEVELOPER_KEY = api_token = File.read(Rails.root.to_s + "/youtube_auth_lock")
	YOUTUBE_API_SERVICE_NAME = 'youtube'
	YOUTUBE_API_VERSION = 'v3'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # Get the cart for the current user
  def get_cart_for_user
  	# Catch the error if a cart does not exist for the user
  	begin
  		@cart = Cart.first!
  	rescue ActiveRecord::RecordNotFound
  		@cart = Cart.create(
  			:videos => [],
  			:mp3s => []
  		)
  	end
  end

	def search_youtube(query)
		search_string = query
		vid_ids_from_search = query_to_youtube(search_string)
		#Returns the JSON object as string
		return vid_ids_from_search	
	end

	def get_service
		client = Google::APIClient.new(
			:key => DEVELOPER_KEY,
			:authorization => nil,
			:application_name => $PROGRAM_NAME,
			:application_version => '1.0.0'
		)	
		youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)
		return client, youtube
	end

	def retrieve_youtube_content_details(video_id)
		client, youtube = get_service
		begin
			search_response = client.execute!(
				:api_method => youtube.videos.list,
				:parameters => {
					:part => 'contentDetails',
					:id => video_id
				}
			)
			return search_response.data.items[0].contentDetails.duration
		rescue Google::APIClient::TransmissionError => e
			puts e.result.body
		end
	end

	def query_to_youtube(search_query)
		opts = Trollop::options do
			opt :q, 'Search term', :type => String, :default => search_query
			opt :max_results, 'Max results', :type => :int, :default => 10
		end

		client, youtube = get_service

		begin
			# Call the search.list method to retrieve results matching the specified
			# query term.
			search_response = client.execute!(
				:api_method => youtube.search.list,
				:parameters => {
					:part => 'snippet',
					:q => opts[:q],
					:maxResults => opts[:max_results],
					:type => 'video'
				}
			)

			videos = []
			channels = []
			playlists = []

			# Add each result to the appropriate list, and then display the lists of
			# matching videos, channels, and playlists.
			search_response.data.items.each do |search_result|
				case search_result.id.kind
					when 'youtube#video'
						videos << search_result
					when 'youtube#channel'
						channels << "#{search_result.snippet.title} (#{search_result.id.channelId})"
					when 'youtube#playlist'
						playlists << "#{search_result.snippet.title} (#{search_result.id.playlistId})"
				end
			end
			return videos
			# puts "Videos:\n", videos, "\n"
			# puts "Channels:\n", channels, "\n"
			# puts "Playlists:\n", playlists, "\n"
		rescue Google::APIClient::TransmissionError => e
			puts e.result.body
		end
	end
end
