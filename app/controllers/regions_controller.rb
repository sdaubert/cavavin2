require 'select_type'

class RegionsController < ApplicationController
  before_action :at_country
  before_action :at_regions, only: %i[new edit]
  before_action :at_region, only: %i[show edit update destroy stats]
  before_action :at_countries, only: %i[new create edit update]

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
  end

  def edit; end

  def create
    @region = @country.regions.build(region_params)

    if @region.save
      redirect_to [@region.country, @region],
                  notice: 'Region was successfully created.'
    else
      set_regions @country.id
      render action: 'new'
    end
  end

  def update
    if @region.update_attributes(region_params)
      redirect_to [@region.country, @region],
                  notice: 'Region was successfully updated.'
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
    compute_statistics_on_wines(Wine.from_country(@country), &:root)
  end

  def stats
    subregions = @region.children
    if subregions.empty?
      @regions = {}
      return
    end

    subregions += [@region]
    wines = Wine.from_region_and_its_descendant(@region)
    compute_statistics_on_wines(wines) do |region|
      region.self_and_ancestors.reverse.find { |r| subregions.include?(r) }
    end
  end

  private

  def at_country
    @country = Country.find(params[:country_id])
  end

  def at_countries
    @countries = Country.by_name
  end

  def at_region
    @region = @country.regions.find(params[:id])
  end

  def region_params
    params.require(:region)
          .permit(:name, :parent_id, :country_id, color_ids: [])
  end

  def clean_and_compute_percentages
    @regions.each_key do |k|
      if @regions[k][:nb].zero?
        @regions.delete(k)
      else
        @regions[k][:p] = @regions[k][:nb].to_f / @sum_regions.to_f * 100
      end
    end
  end

  def compute_statistics_on_wines(wines)
    @regions = {}
    @sum_regions = 0

    wines.each do |wine|
      ref_region = yield wine.region
      rr_name = ref_region.name
      @regions[rr_name] = init_region_stat(ref_region) unless @regions.key?(rr_name)
      @regions[rr_name][:nb] += wine.quantity
      @sum_regions += wine.quantity
    end

    clean_and_compute_percentages
  end

  def init_region_stat(region)
    { nb: 0, p: 0.0, id: region.id }
  end
end
