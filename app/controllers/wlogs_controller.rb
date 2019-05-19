class WlogsController < ApplicationController
  before_action :set_wine
  before_action :set_millesime
  before_action :set_wlog, only: [:edit, :update, :destroy]

  def index
    @wlogs = Wlog.all
  end

  def show
  end

  def new
    @wlog = @millesime.wlogs.build
  end

  def edit
  end

  def create
    @wlog = @millesime.wlogs.build(wlog_params)

    if @wlog.save
      redirect_to [@wine, @millesime], notice: 'Wlog was successfully created.'
    else
      render :new
    end
  end

  def update
    if @wlog.update(wlog_params)
      redirect_to [@wine, @millesime], notice: 'Wlog was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @wlog.destroy
    redirect_to [@wine, @millesime], notice: 'Wlog was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_wlog
    @wlog = @millesime.wlogs.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wlog_params
    params.require(:wlog).permit(:millesime_id, :date, :mvt_type, :quantity, :price, :notes)
  end
end
