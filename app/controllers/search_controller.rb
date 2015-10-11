
class SearchController < ApplicationController

	def index	
		#Read API token for api access
		api_token = File.read(Rails.root.to_s + "/youtube_auth_lock")
		vid_ids_from_search = query_to_youtube(search_string)
		#TODO - Chane to actual JSON search result
		search_results = {
			:search_result => search_string
		}
		#Returns the JSON object as string
		return vid_ids_from_search
	end
end
