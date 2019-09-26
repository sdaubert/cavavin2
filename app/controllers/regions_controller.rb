require 'select_type'

class RegionsController < ApplicationController
  before_action :set_country
  before_action :set_region, only: %i[show edit update destroy]
  before_action :set_countries, only: %i[new create edit update]

  def index; end

  def show
    @millesimes = Millesime.from_region(@region)
                           .with_bottles
                           .order('wines.domain, millesimes.year')
    @drunk_millesimes = Millesime.from_region(@region)
                                 .without_bottles
                                 .order('wines.domain, millesimes.year')
  end

  def new
    @region = @country.regions.build
    set_regions @country.id
  end

  def edit
    set_regions @country.id
  end

  def create
    @region = @country.regions.build(region_params)

    if @region.save
      redirect_to([@region.country, @region], notice: 'Region was successfully created.')
    else
      set_regions @country.id
      render action: 'new'
    end
  end

  def update
    if @region.update_attributes(region_params)
      redirect_to([@region.country, @region], notice: 'Region was successfully updated.')
    else
      set_regions @country.id
      render action: 'edit'
    end
  end

  def destroy
    @region.destroy

    redirect_to country_regions_url(@country)
  end

  def country_stats
    @regions = {}
    @sum_regions = 0

    Wine.from_country(@country).each do |wine|
      root_region = wine.region.root
      rr_name = root_region.name
      @regions[rr_name] = { nb: 0, p: 0.0, id: wine.region.root.id } unless @regions.key?(rr_name)
      @regions[rr_name][:nb] += wine.quantity
      @sum_regions += wine.quantity
    end

    compute_percentages
  end

  def stats
  end

  private

  def set_country
    @country = Country.find(params[:country_id])
  end

  def set_countries
    @countries = Country.order('name')
  end

  def set_region
    @region = @country.regions.find(params[:id])
  end

  def region_params
    params.require(:region).permit(:name, :parent_id, :country_id, color_ids: [])
  end

  def compute_percentages
    @regions.each_key do |k|
      if @regions[k][:nb] == 0
        @regions.delete(k)
      else
        @regions[k][:p] = @regions[k][:nb].to_f / @sum_regions.to_f * 100
      end
    end
  end
end
