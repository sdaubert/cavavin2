# Error raised when bottle issue in encountered
class BottleError < StandardError; end

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
    logger.debug(@wlog.inspect)

    Wlog.transaction do
      update_bottles @wlog
      if @wlog.save
        redirect_to [@wine, @millesime], notice: 'Wlog was successfully created.'
      else
        render :new
      end
    end
  end

  def update
    Wlog.transaction do
      delete_bottles @wlog
      if @wlog.update(wlog_params)
        update_bottles @wlog
        redirect_to [@wine, @millesime], notice: 'Wlog was successfully updated.'
      else
        render :edit
      end
    end
  end

  def destroy
    Wlog.transaction do
      rollback_bottles @wlog
      @wlog.destroy
    end
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

  def update_bottles(wlog)
    logger.debug "update_bottles"

    case wlog.mvt_type
    when 'in'
      logger.debug "  > in case"
      generate_bottles wlog
    when 'out'
      delete_bottles wlog
    when 'move'
      logger.debug "  > move case"
    end
  end

  def rollback_bottles(wlog)
    case wlog.mvt_type
    when 'in'
      delete_bottles wlog
    when 'out'
      generate_bottles wlog
    when 'move'
    end
  end

  def generate_bottles(wlog)
    positions = BottleRack.pos_to_ary(wlog.pos)
    wlog.quantity.times do
      logger.debug @millesime.bottles.create(br_id: wlog.br_id,
                                             pos: positions.shift)
    end
  end

  def delete_bottles(wlog)
    bottles = Bottle.where(millesime_id: wlog.millesime.id, br_id: wlog.br_id)
    bottles.where(pos: BottleRack.pos_to_ary(wlog.pos)) unless wlog.br_id.nil?
    bottles.limit(wlog.quantity).destroy_all
  end
end
