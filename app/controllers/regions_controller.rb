require 'select_type'

class RegionsController < ApplicationController
  before_action :set_country
  before_action :set_region, only: [:show, :edit, :update, :destroy]
  before_action :set_countries, only: [:new, :create, :edit, :update]

  def index
    #@regions = @country.regions
  end

  def show
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
    params.require(:region).permit(:name, :parent_id, :country_id)
  end
end
