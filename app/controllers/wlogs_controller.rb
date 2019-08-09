# Error raised when bottle issue in encountered
class BottleError < StandardError; end

class WlogsController < ApplicationController
  before_action :set_wine
  before_action :set_millesime
  before_action :set_wlog, except: %i[new create]
  before_action :set_racks, only: %i[select_rack select_rack2 save_rack]

  def new
    @wlog = @millesime.wlogs.build
  end

  def edit; end

  def create
    @wlog = @millesime.wlogs.build(wlog_params)

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
             when 'move' then 'Select racks to move bottles out'
             end
  end

  def select_rack2
    @title = 'Select racks to move bottles in'
    @move_in_phase = true
    render 'select_rack'
  end

  def save_rack
    @bottle_rack = BottleRack.find_by(id: params[:bottle_rack][:id])
    @move_in_phase = (params['move_in_phase'] == true)

    if @bottle_rack.nil?
      if @wlog.millesime.bottles.where(br_id: nil).empty? || @wlog.mvt_type_is_move?
        @wlog.errors.add(:bottle_rack, 'none selected')

        render :select_rack
        return
      end
    else
      set_bottle_rack_info params
    end

    Wlog.transaction do
      update_bottles! @wlog
      @wlog.save!
    rescue ActiveRecord::RecordInvalid
      render :select_rack
    end

    if (@wlog.mvt_type == 'move') && (params['move_in_phase'] != 'true')
      redirect_to select_rack2_wine_millesime_wlog_path(@wine, @millesime, @wlog)
    else
      redirect_to [@wine, @millesime], notice: 'Wlog was successfully saved.'
    end
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

  def update_bottles!(wlog)
    case wlog.mvt_type
    when 'in'
      generate_bottles! wlog
    when 'out'
      delete_bottles wlog
    when 'move'
      move_bottles! wlog
    end
  end

  def rollback_bottles(wlog)
    case wlog.mvt_type
    when 'in'
      delete_bottles wlog
    when 'out'
      generate_bottles! wlog
    when 'move'
      move_bottles! wlog, rollback: true
    end
  end

  def generate_bottles!(wlog)
    positions = BottleRack.pos_to_ary(wlog.pos)
    wlog.quantity.times do
      @millesime.bottles.create!(br_id: wlog.br_id,
                                 pos: positions.shift)
    end
  end

  def delete_bottles(wlog)
    bottles = Bottle.where(millesime_id: wlog.millesime.id, br_id: wlog.br_id)
    bottles = bottles.where(pos: BottleRack.pos_to_ary(wlog.pos)) unless wlog.br_id.nil?
    bottles.limit(wlog.quantity).destroy_all
  end

  def move_bottles!(wlog, rollback: false)
    return if wlog.move_to_br_id.nil?

    all_pos = BottleRack.pos_to_ary(wlog.pos)
    all_new_pos = BottleRack.pos_to_ary(wlog.move_to_pos)

    all_pos, all_new_pos = all_new_pos, all_pos if rollback

    @millesime.bottles.where(pos: all_pos).each do |bottle|
      idx = all_pos.index(bottle.pos)
      unless idx.nil?
        bottle.pos = all_new_pos[idx]
        bottle.save!
      end
    end
  end

  def set_bottle_rack_info(params)
    phase_type = @wlog.mvt_type
    phase_type = params['move_in_phase'] ? 'in' : 'out' if phase_type == 'move'

    value_to_select = (phase_type == 'out' ? '0' : '1')
    pos = BottleRack.ary_to_pos(params[:bottle_rack][:location].
                     select { |k,v| v == value_to_select }.
                     keys)

    if params['move_in_phase'] == 'true'
      @wlog.move_to_br_id = @bottle_rack.id
      @wlog.move_to_pos = pos
    else
      @wlog.br_id = @bottle_rack.id
      @wlog.pos = pos
    end
  end
end
