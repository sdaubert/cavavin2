# Error raised when bottle issue in encountered
class BottleError < StandardError; end

class WlogsController < ApplicationController
  before_action :at_wine
  before_action :at_millesime
  before_action :at_wlog, except: %i[new create]
  before_action :at_racks, only: %i[select_rack save_rack]

  def new
    @wlog = @millesime.wlogs.build
  end

  def edit; end

  def create
    @wlog = @millesime.wlogs.build(wlog_params)

    if @wlog.save
      redirect_to select_rack_wine_millesime_wlog_url(@wine, @millesime, @wlog),
                  redirect_notice
    else
      render :new
    end
  end

  def update
    if @wlog.update(wlog_params)
      redirect_to select_rack_wine_millesime_wlog_url(@wine, @millesime, @wlog),
                  redirect_notice
    else
      render :edit
    end
  end

  def destroy
    Wlog.transaction do
      rollback_bottles @wlog
      @millesime.wlogs.destroy @wlog
    end
    redirect_to [@wine, @millesime], redirect_notice
  end

  def select_rack
    @title = case @wlog.mvt_type
             when 'in' then t('view.rack.select_in')
             when 'out' then t('view.rack.select_out')
             when 'move' then t('view.rack.select_move1')
             end
  end

  def select_rack2
    @title = t('view.rack.select_move2')
    @move_in_phase = true
    at_racks(force_all: true)
    render 'select_rack'
  end

  def save_rack
    @bottle_rack = BottleRack.find_by(id: params[:bottle_rack][:id])
    @move_in_phase = (params['move_in_phase'] == 'true')
    logger.info("save_rack: move_in_phase: #{@move_in_phase} (#{params['move_in_phase'].inspect})")

    if @bottle_rack.nil?
      if need_bottle_rack?
        @wlog.errors.add(:bottle_rack, t('view.errors.none_selected'))
        render :select_rack
        return
      end
    else
      record_bottle_rack_info params
    end

    Wlog.transaction do
      update_bottles! @wlog
      @wlog.save!
    rescue ActiveRecord::RecordInvalid
      render :select_rack
      return
    end

    redirect_after_save_rack
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def at_wlog
    @wlog = @millesime.wlogs.find(params[:id])
  end

  def at_racks(force_all: false)
    if force_all || (@wlog.mvt_type == 'in')
      @racks = BottleRack.by_name.all.map { |r| [r.name, r.id] }
    else
      @racks = BottleRack.millesime(@millesime).all.map { |r| [r.name, r.id] }
      @bottle_rack = @wlog.bottle_rack
    end
    @racks.unshift([t('activerecord.models.bottle_rack', count: 0), nil])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def wlog_params
    params.require(:wlog).permit(:millesime_id, :date, :mvt_type, :quantity,
                                 :price, :notes)
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
    pos_ary = BottleRack.pos_to_ary(wlog.pos)
    bottles = bottles.where(pos: pos_ary) unless wlog.br_id.nil?
    bottles.limit(wlog.quantity).destroy_all
  end

  def generate_pos(wlog)
    all_pos = BottleRack.pos_to_ary(wlog.pos)
    all_new_pos = BottleRack.pos_to_ary(wlog.move_to_pos)

    [all_pos, all_new_pos]
  end

  def move_bottles!(wlog, rollback: false)
    return if wlog.move_to_br_id.nil?

    br_id = wlog.br_id
    new_br_id = wlog.move_to_br_id
    all_pos, all_new_pos = generate_pos(wlog)

    if rollback
      all_pos, all_new_pos = all_new_pos, all_pos
      br_id, new_br_id = new_br_id, br_id
    end

    if br_id.nil?
      @millesime.bottles.where(pos: nil).limit(all_new_pos.size).each do |bottle|
        bottle.br_id = new_br_id
        bottle.pos = all_new_pos.shift
        bottle.save!
      end
    else
      @millesime.bottles.where(br_id: br_id, pos: all_pos).each do |bottle|
        idx = all_pos.index(bottle.pos)
        next if idx.nil?

        bottle.br_id = new_br_id
        bottle.pos = all_new_pos[idx]
        bottle.save!
      end
    end
  end

  def record_bottle_rack_info(params)
    phase_type = @wlog.mvt_type
    phase_type = (@move_in_phase ? 'in' : 'out') if phase_type == 'move'

    value_to_select = (phase_type == 'out' ? '0' : '1')
    pos = BottleRack.ary_to_pos(params[:bottle_rack][:location]
                    .select { |_k, v| v == value_to_select }
                    .keys)
    logger.info("record_bottle_rack_info: pos to update: #{pos.inspect}")

    if @move_in_phase
      @wlog.move_to_br_id = @bottle_rack.id
      @wlog.move_to_pos = pos
      logger.info("wlog: #{@wlog.inspect}")
    else
      @wlog.br_id = @bottle_rack.id
      @wlog.pos = pos
    end
  end

  def need_bottle_rack?
    bottles = @wlog.millesime.bottles
    (bottles.count.positive? && bottles.where(br_id: nil).empty?)
  end

  def redirect_after_save_rack
    if (@wlog.mvt_type == 'move') && (params['move_in_phase'] != 'true')
      redirect_to select_rack2_wine_millesime_wlog_path(@wine, @millesime, @wlog)
    else
      redirect_to [@wine, @millesime], notice: t('view.notice.saved', model: t('activerecord.models.wlog'))
    end
  end
end
