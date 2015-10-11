#Youtube API requirements
require 'rubygems'
require 'google/api_client'
require 'trollop'
require 'open3'

class ApplicationController < ActionController::Base
	DEVELOPER_KEY = 'AIzaSyB4UDrhBocwoO7WqSkXk2Y3ZcyU9Sd9diY'
	YOUTUBE_API_SERVICE_NAME = 'youtube'
	YOUTUBE_API_VERSION = 'v3'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	def search_youtube(query)
		search_string = query
		#Read API token for api access
		api_token = File.read(Rails.root.to_s + "/youtube_auth_lock")
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

	def query_to_youtube(search_query)
		opts = Trollop::options do
			opt :q, 'Search term', :type => String, :default => search_query
			opt :max_results, 'Max results', :type => :int, :default => 25
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
					:maxResults => opts[:max_results]
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
						puts(search_result)
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

	def get_vids_from_ids(vid_id_array)
		client, youtube = get_service
		vid_titles = []
		begin
			vid_id_array.each do |vid_id|
				search_response = client.execute!(
					:api_method => youtube.videos.list,
					:parameters => {
						:part => 'snippet',
						:id => vid_id
					}
				)
				vid_titles << search_response.data.items[0].snippet.title
			end
		rescue Google::APIClient::TransmissionError => e
			puts e.result.body
		end
	end
end
