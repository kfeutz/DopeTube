require 'fileutils'
class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :edit, :update, :destroy]
  before_action :init_pending_mp3s
  # GET /carts
  # GET /carts.json
  def index
    @carts = Cart.all
    # If cart is empty, mark boolean value for view
    if @carts.size > 0 
      @cart = @carts.first
      @cart_videos = @cart.videos
      @cart_mp3s = @cart.mp3s
    else
      @cart_empty = true
    end
  end

  def download_audio

    @audio_files_download = @cart.mp3s
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

  def init_pending_mp3s
    @pending_mp3_downloads = []
  end

  def convert_videos
    #Run youtube-dl util to convert videos
    @cart.videos.each do |video|
      logger.info "Executing youtube-dl --extract-audio -o \"%(title)s.%(ext)s\" " + video.vid_id + " --restrict-filenames"
      #file = system("youtube-dl --newline --extract-audio -o \"%(title)s.%(ext)s\" " + vid_ids[0] + " --restrict-filenames")
      Open3.popen3("youtube-dl --newline --extract-audio -o \"%(title)s.%(ext)s\" " + video.vid_id + " --restrict-filenames") do |stdin, stdout, stderr, thread|
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
        audio_file_paths.concat(Dir['./*.opus'])

        puts "YOOOO " + audio_file_paths.to_s
        # eventually will only be one.
        audio_file_paths.each do |path|
          FileUtils.mv(path, './pending_downloads/' + path.split('/').last)
          @pending_mp3_downloads << Mp3.create(
            :title => path.split('/').last,
            :download_path => './pending_downloads/' + path.split('/').last,
            :download_ready => true
          )
        end 
      end
    end.to_json
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
