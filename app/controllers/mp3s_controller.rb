class Mp3sController < ApplicationController
  before_action :set_mp3, only: [:show, :edit, :update, :destroy]

  # GET /mp3s
  # GET /mp3s.json
  def index
    @mp3s = Mp3.all
  end

  # GET /mp3s/1
  # GET /mp3s/1.json
  def show
  end

  # GET /mp3s/new
  def new
    @mp3 = Mp3.new
  end

  # GET /mp3s/1/edit
  def edit
  end

  # POST /mp3s
  # POST /mp3s.json
  def create
    @mp3 = Mp3.new(mp3_params)

    respond_to do |format|
      if @mp3.save
        format.html { redirect_to @mp3, notice: 'Mp3 was successfully created.' }
        format.json { render :show, status: :created, location: @mp3 }
      else
        format.html { render :new }
        format.json { render json: @mp3.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mp3s/1
  # PATCH/PUT /mp3s/1.json
  def update
    respond_to do |format|
      if @mp3.update(mp3_params)
        format.html { redirect_to @mp3, notice: 'Mp3 was successfully updated.' }
        format.json { render :show, status: :ok, location: @mp3 }
      else
        format.html { render :edit }
        format.json { render json: @mp3.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mp3s/1
  # DELETE /mp3s/1.json
  def destroy
    @mp3.destroy
    respond_to do |format|
      format.html { redirect_to mp3s_url, notice: 'Mp3 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mp3
      @mp3 = Mp3.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mp3_params
      params.require(:mp3).permit(:title, :artist, :length, :file_size, :file_format, :download_path)
    end
end
