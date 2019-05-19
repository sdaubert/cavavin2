require 'select_type'

class ApplicationController < ActionController::Base

  private

  def set_producers
    @producers = Producer.all
  end

  def set_providers
    @providers = Provider.all
  end

  def levelize(region)
    region.level.zero? ? "* #{region.name}" : ('+' * region.level) + " #{region.name}"
  end

  def region_group(country=nil)
    country_name = country.nil? ? '' : country.name
    country_id = country.nil? ? @country.id : country.id

    group = SelectType.new(country_name)
    roots = Region.by_country(country_id).order('name').roots
    roots.each do |root|
      root.self_and_descendants.each do |r|
        group << SelectOptions.new(r.id, levelize(r))
      end
    end

    group
  end

  def set_regions(country_id=nil)
    @regions = []
    if country_id.nil?
      Country.all.each do |c|
        group = region_group(c)
        @regions << group
      end
    else
      group = region_group
      @regions << group
    end
  end

  def set_wine
    @wine = Wine.find(params[:wine_id])
  end

  def set_millesime
    @millesime = @wine.millesimes.find(params[:millesime_id])
  end
end
