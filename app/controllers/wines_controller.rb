class WinesController < ApplicationController
  before_action :set_wine, only: %i[show edit update destroy]
  before_action :set_producers, only: %i[new create edit update]
  before_action :set_providers, only: %i[new create edit update]
  before_action :set_regions, only: %i[new create edit update]

  # GET /wines
  # GET /wines.json
  def index
    @wines = Millesime.includes(:wine).all
    case params[:sort_by]
    when 'color'
      @wines = @wines.sort_by { |w| w.wine.color.name }
    when 'millesime'
      @wines = @wines.sort_by(&:year)
    when 'country'
      @wines = @wines.sort_by { |w| w.wine.region.country.name }
    when 'zone'
      @wines = @wines.sort_by { |w| w.wine.region.root.name }
    else
      @wines = @wines.sort_by { |w| w.wine.domain }
    end
  end

  # GET /wines/1
  # GET /wines/1.json
  def show
  end

  # GET /wines/new
  def new
    @wine = Wine.new
  end

  # GET /wines/1/edit
  def edit
  end

  # POST /wines
  # POST /wines.json
  def create
    @wine = Wine.new(wine_params)

    if @wine.save
      redirect_to @wine, notice: 'Wine was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /wines/1
  # PATCH/PUT /wines/1.json
  def update
    if @wine.update(wine_params)
      redirect_to @wine, notice: 'Wine was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /wines/1
  # DELETE /wines/1.json
  def destroy
    @wine.destroy
    redirect_to wines_url, notice: 'Wine was successfully destroyed.'
  end

  private

  def set_wine
    @wine = Wine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wine_params
    params.require(:wine).permit(:domain, :effervescent, :organic, :garde, :color_id, :region_id, :producer_id, :provider_id, :notes)
  end
end
