class BottleRacksController < ApplicationController
  before_action :set_bottle_rack, only: %i[show edit update destroy get_info]

  # GET /bottle_racks
  def index
    @bottle_racks = BottleRack.all
  end

  # GET /bottle_racks/1
  def show; end

  # GET /bottle_racks/new
  def new
    @bottle_rack = BottleRack.new
  end

  # GET /bottle_racks/1/edit
  def edit; end

  # POST /bottle_racks
  def create
    @bottle_rack = BottleRack.new(bottle_rack_params)

    if @bottle_rack.save
      redirect_to @bottle_rack, notice: 'Bottle rack was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /bottle_racks/1
  def update
    if @bottle_rack.update(bottle_rack_params)
      redirect_to @bottle_rack, notice: 'Bottle rack was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /bottle_racks/1
  def destroy
    @bottle_rack.destroy
    redirect_to bottle_racks_url, notice: 'Bottle rack was successfully destroyed.'
  end

  # xhr only
  # POST /bottle_racks/1/get_info
  def get_info
    logger.debug "XHR get_info"
    @wlog = Wlog.find(params[:wlog_id])
    render partial: 'rack', layout: false, locals: { bottle_rack: @bottle_rack, show: false }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bottle_rack
    @bottle_rack = BottleRack.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bottle_rack_params
    params.require(:bottle_rack).permit(:name, :lines, :columns)
  end
end
