class DownloadController < ApplicationController

  def index
  	@videos = Video.all
  end
end
