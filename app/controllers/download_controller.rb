class DownloadController < ApplicationController

  def index
  	@videos = Video.all
  end

  def download
  	#Run youtube-dl util to convert videos
    logger.info "Executing youtube-dl --extract-audio -o \"%(title)s.%(ext)s\" " + vid_ids[0] + " --restrict-filenames"
    #file = system("youtube-dl --newline --extract-audio -o \"%(title)s.%(ext)s\" " + vid_ids[0] + " --restrict-filenames")
    Open3.popen3("youtube-dl --newline --extract-audio -o \"%(title)s.%(ext)s\" " + vid_ids[0] + " --restrict-filenames") do |stdin, stdout, stderr, thread|
      while line = stdout.gets
        puts "YOOOO " + line
      end
      # Check if command exceeded or not
      exit_status = wait_thr.value
      unless exit_status.success?
        abort "FAILED !!!"
      end
    end
  end
end
