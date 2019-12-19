class DishesController < ApplicationController
  before_action :at_dish, except: %w[index new create]
  before_action :at_colors, only: %w[select_regions save_regions]
  before_action :at_countries, only: %w[select_regions save_regions]

  # GET /dishes
  def index
    @dishes = Dish.by_name.all
  end

  # GET /dishes/1
  def show
    @dras = {}
    Color.by_name.each do |color|
      @dras[color.name] = @dish.dras.of_color(color).by_regions
    end
  end

  # GET /dishes/new
  def new
    @dish = Dish.new
  end

  # GET /dishes/1/edit
  def edit; end

  # POST /dishes
  def create
    @dish = Dish.new(dish_params)

    if @dish.save
      redirect_to select_regions_dish_path(@dish), redirect_notice
    else
      render :new
    end
  end

  # PATCH/PUT /dishes/1
  def update
    if @dish.update(dish_params)
      redirect_to select_regions_dish_path(@dish), redirect_notice
    else
      render :edit
    end
  end

  # DELETE /dishes/1
  def destroy
    @dish.destroy
    redirect_to dishes_url, redirect_notice
  end

  def select_regions; end

  def save_regions
    ok = true

    Dish.transaction do
      @dish.dras.destroy_all

      params['regions'].each do |region_id_s, color_hash|
        logger.debug "process region ##{region_id_s}"
        region_id = region_id_s.to_i
        next unless region_id.positive?

        region = Region.find_by(id: region_id)
        logger.debug "region id ##{region_id}: #{region.inspect}"
        next if region.nil?

        color_hash.each do |color_id_s, selected|
          logger.debug "  > process color ##{color_id_s}"
          color = Color.find_by(id: color_id_s.to_i)
          logger.debug "  > color id ##{color_id_s}: #{color.inspect}"
          next if color.nil?
          next unless selected

          ok &&= Dra.create(dish: @dish, region: region, color: color)
        end
      end
    end

    if ok
      redirect_to @dish
    else
      render :save_regions
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def at_dish
    @dish = Dish.find(params[:id])
  end

  def at_colors
    @colors = Color.by_name
    @colors_count = @colors.count
  end

  def at_countries
    @countries = Country.by_name
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def dish_params
    params.require(:dish).permit(:name, :dish_type)
  end
end
