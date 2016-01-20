require 'fileutils'
require_relative '../helpers/zip_file_helper.rb'
class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :edit, :update, :destroy]
  before_action :init_cart

  include ZipFileHelper

  def init_cart
    @pending_mp3_downloads = []
    @cart_videos = [] 
    @cart_videos.concat(@cart.videos.all)
    @cart_mp3s = [] 
    @cart_mp3s.concat(@cart.mp3s.all)
  end

  # GET /carts
  # GET /carts.json
  def index
    # If cart is empty, mark boolean value for view
  end

  def download_audio
    # Move each file to prepare to be zipped
    @cart_mp3s.each do |audio_download|
      # Array holding three segments of download path screen
      directories = audio_download.download_path.split('/')
      FileUtils.mv(audio_download.download_path, 
        directories[0]+'/'+directories[1]+ '/zip/' + directories[2])
      audio_download.update(download_path: directories[0]+'/'+directories[1]+ '/zip/' + directories[2])
    end
    package_zip
    # Delete all audio files from disk and db
    @cart_mp3s.each do |audio_file|
      FileUtils.rm(audio_file.download_path)
      audio_file.delete
    end
    send_file './pending_downloads/zip/songs.zip'
  end

  def package_zip
    if File.exist?('./pending_downloads/zip/songs.zip')
      FileUtils.rm('./pending_downloads/zip/songs.zip')
    end
    audios_directory = './pending_downloads/zip'
    output_zip_file = './pending_downloads/zip/songs.zip'
    zip = ZipFileGenerator.new(audios_directory, output_zip_file)
    zip.write()
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
  end

  # GET /carts/new
  def new
    @cart = Cart.new
  end

  # GET /carts/1/edit
  def edit
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(cart_params)

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Cart was successfully created.' }
        format.json { render :show, status: :created, location: @cart }
      else
        format.html { render :new }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carts/1
  # PATCH/PUT /carts/1.json
  def update
    respond_to do |format|
      if @cart.update(cart_params)
        format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
        format.json { render :show, status: :ok, location: @cart }
      else
        format.html { render :edit }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  def convert_videos
    file_format = params[:file_format]
    youtube_base_url = 'http://www.youtube.com/watch?v='
    #Run youtube-dl util to convert videos
    @cart.videos.each do |video|
      logger.info "Executing youtube-dl --extract-audio --audio-format " + file_format + " -o \"%(title)s.%(ext)s\" " + youtube_base_url + "" + video.vid_id + " --restrict-filenames --verbose"
      #file = system("youtube-dl --newline --extract-audio -o \"%(title)s.%(ext)s\" " + vid_ids[0] + " --restrict-filenames")
      Open3.popen3("youtube-dl --newline --extract-audio  --audio-format " + file_format + " -o \"%(title)s.%(ext)s\" " + youtube_base_url + "" + video.vid_id + " --restrict-filenames --verbose") do |stdin, stdout, stderr, thread|
        # Receive console output in here. Use it to update conversion progress
        while line = stdout.gets
          puts line
        end
        # Check if command exceeded or not
        exit_status = thread.value
        unless exit_status.success?
          abort "FAILED !!!"
        end
        # Get all audio files that were just converted
        audio_file_paths = []
        audio_file_paths.concat(Dir['./*.m4a'])
        audio_file_paths.concat(Dir['./*.mp3'])
        audio_file_paths.concat(Dir['./*.opus'])

        puts "YOOOO " + audio_file_paths.to_s
        # eventually will only be one.
        audio_file_paths.each do |path|
          FileUtils.mv(path, './pending_downloads/' + path.split('/').last)
          @cart_mp3s << Mp3.create(
            :title => video.title,
            :download_path => './pending_downloads/' + path.split('/').last,
            :download_ready => true,
            :file_format => path.split('.').last,
            :cart_id => @cart.id
          )
        end 
      end
      video.delete
    end
    #convert_audio_files(@cart_mp3s, params[:file_format])
    respond_to do |format|
      format.html
      format.json { render :json => @cart_mp3s }
    end
  end

  def convert_audio_files(audios, audio_format)
    audios.each do |audio|
      unless audio.file_format == audio_format
        logger.info "Executing ffmpeg -i " + audio.download_path + " ./pending_downloads/" + audio.title.gsub(" ", "_") + "." + audio_format 
        Open3.popen3("ffmpeg -i " + audio.download_path + " ./pending_downloads/" + audio.title.gsub(" ", "_") + "." + audio_format ) do |stdin, stdout, stderr, thread|
          # Receive console output in here. Use it to update conversion progress
          while line = stdout.gets
            puts line
          end
          # Check if command exceeded or not
          exit_status = thread.value
          unless exit_status.success?
            abort "FAILED !!!"
          end
          audio.update(
            download_path: "./pending_downloads/" + audio.title + audio_format,
            file_format: audio_format 
          )
        end
      end
    end
  end

  def remove_videos
    remove_videos_from_db
    respond_to do |format|
      format.html { redirect_to carts_url, notice: 'Videos successfully deleted from cart.' }
      format.json { head :no_content }
    end
  end

  # DELETE /cart/videos
  # Deletes the users video items from their cart
  def remove_videos_from_db
    Video.delete_all("cart_id = 1" )
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy
    respond_to do |format|
      format.html { redirect_to carts_url, notice: 'Cart was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = Cart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_params
      params.require(:cart).permit(:num_items)
    end
end
