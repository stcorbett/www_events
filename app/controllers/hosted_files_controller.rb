class HostedFilesController < ApplicationController
  before_action :set_hosted_file, only: [:show, :edit, :update, :destroy]
  before_action :require_admin

  # GET /hosted_files
  # GET /hosted_files.json
  def index
    @hosted_files = HostedFile.all
  end

  # GET /hosted_files/1
  # GET /hosted_files/1.json
  def show
  end

  # GET /hosted_files/new
  def new
    @hosted_file = HostedFile.new
  end

  # GET /hosted_files/1/edit
  def edit
  end

  # POST /hosted_files
  # POST /hosted_files.json
  def create
    @hosted_file = HostedFile.new(hosted_file_params)

    respond_to do |format|
      if @hosted_file.save
        format.html { redirect_to @hosted_file, notice: 'Hosted file was successfully created.' }
        format.json { render :show, status: :created, location: @hosted_file }
      else
        format.html { render :new }
        format.json { render json: @hosted_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hosted_files/1
  # PATCH/PUT /hosted_files/1.json
  def update
    respond_to do |format|
      if @hosted_file.update(hosted_file_params)
        format.html { redirect_to @hosted_file, notice: 'Hosted file was successfully updated.' }
        format.json { render :show, status: :ok, location: @hosted_file }
      else
        format.html { render :edit }
        format.json { render json: @hosted_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hosted_files/1
  # DELETE /hosted_files/1.json
  def destroy
    @hosted_file.destroy
    respond_to do |format|
      format.html { redirect_to hosted_files_url, notice: 'Hosted file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hosted_file
      @hosted_file = HostedFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hosted_file_params
      params.require(:hosted_file).permit(:name, :content)
    end
end
