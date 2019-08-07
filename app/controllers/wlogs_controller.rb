# Error raised when bottle issue in encountered
class BottleError < StandardError; end

class WlogsController < ApplicationController
  before_action :set_wine
  before_action :set_millesime
  before_action :set_wlog, only: %i[edit update destroy select_rack save_rack]
  before_action :set_racks, only: %i[select_rack save_rack]

  def new
    @wlog = @millesime.wlogs.build
  end

  def edit; end

  def create
    @wlog = @millesime.wlogs.build(wlog_params)
    logger.debug(@wlog.inspect)

    if @wlog.save
      redirect_to select_rack_wine_millesime_wlog_url(@wine, @millesime, @wlog), notice: 'Wlog was successfully created.'
    else
      render :new
    end
  end

  def update
    if @wlog.update(wlog_params)
      redirect_to select_rack_wine_millesime_wlog_url(@wine, @millesime, @wlog), notice: 'Wlog was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    Wlog.transaction do
      rollback_bottles @wlog
      @millesime.wlogs.destroy @wlog
    end
    redirect_to [@wine, @millesime], notice: 'Wlog was successfully destroyed.'
  end

  def select_rack
    @title = case @wlog.mvt_type
             when 'in' then 'Select racks to store bottles'
             when 'out' then 'Select racks to remove bottles'
             when 'move' then 'Select racks to move out bottles'
             end
  end

  def save_rack
    begin
      @bottle_rack = BottleRack.find(params[:bottle_rack][:id])
      @wlog.br_id = @bottle_rack.id
      value_to_select = (@wlog.mvt_type == 'out' ? '0' : '1')
      @wlog.pos = BottleRack.ary_to_pos(params[:bottle_rack][:location].
                                        select { |k,v| v == value_to_select }.
                                        keys)
      # rubocop:disable Lint/HandleExceptions
    rescue ActiveRecord::RecordNotFound
      # rubocop:enable Lint/HandleExceptions
    end

    Wlog.transaction do
      update_bottles @wlog
      @wlog.save
    end
    redirect_to [@wine, @millesime], notice: 'Wlog was successfully saved.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_wlog
    @wlog = @millesime.wlogs.find(params[:id])
  end

  def set_racks
    if @wlog.mvt_type == 'in'
      @racks = BottleRack.all.order('name').map { |r| [r.name, r.id] }
    else
      @racks = BottleRack.millesime(@millesime).all.map { |r| [r.name, r.id] }
      @bottle_rack = @wlog.bottle_rack
    end
    @racks.unshift(['No rack', nil])
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
      logger.debug "  > out case"
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
    bottles = bottles.where(pos: BottleRack.pos_to_ary(wlog.pos)) unless wlog.br_id.nil?
    bottles.limit(wlog.quantity).destroy_all
  end
end
