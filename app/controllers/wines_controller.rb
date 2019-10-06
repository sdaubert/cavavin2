class WinesController < ApplicationController
  before_action :at_wine, only: %i[show edit update destroy]
  before_action :at_producers, only: %i[new create edit update]
  before_action :at_providers, only: %i[new create edit update]
  before_action :at_regions, only: %i[new edit]

  # GET /wines
  def index
    @wines = Millesime.joins(wine: [:color, { region: :country }])
    handles_before_after params
    handles_filter params
    handles_sort_by params
    @wines = @wines.page(params[:page])
    @url_params = params.permit(:sort_by, :filter, :filter_id, :after, :before)
  end

  # GET /wines/1
  def show; end

  # GET /wines/new
  def new
    @wine = Wine.new
    @millesime = @wine.millesimes.build
    @wlog = @millesime.wlogs.build
    @wlog.mvt_type = 'in'
    @wlog.date = Time.now.to_date
  end

  # GET /wines/1/edit
  def edit; end

  # POST /wines
  def create
    @wine = Wine.new(wine_params)

    if @wine.save
      millesime = @wine.millesimes.first
      wlog = millesime.wlogs.first
      redirect_to select_rack_wine_millesime_wlog_url(@wine, millesime, wlog),
                  notice: 'Wine was successfully created.'
    else
      at_regions
      @millesime = @wine.millesimes.first
      @wlog = @millesime.wlogs.first
      render :new
    end
  end

  # PATCH/PUT /wines/1
  def update
    if @wine.update(wine_params)
      redirect_to @wine, notice: 'Wine was successfully updated.'
    else
      at_regions
      render :edit
    end
  end

  # DELETE /wines/1
  def destroy
    @wine.destroy
    redirect_to wines_url, notice: 'Wine was successfully destroyed.'
  end

  private

  def at_wine
    @wine = Wine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def wine_params
    params.require(:wine)
          .permit(:domain, :effervescent, :organic, :garde, :color_id,
                  :region_id, :producer_id, :provider_id, :notes,
                  millesimes_attributes: [:id, :year, :garde, :notes,
                                          wlogs_attributes: %i[date mvt_type
                                                               quantity price
                                                               notes]])
  end

  def handles_before_after(params)
    if params['before']&.to_i&.positive?
      @wines = @wines.drink_before(params['before'].to_i)
    end
    if params['after']&.to_i&.positive?
      @wines = @wines.drink_after(params['after'].to_i)
    end
  end

  def handles_sort_by(params)
    @wines = case params[:sort_by]
             when 'color'
               @wines.order('colors.name, millesimes.wine_id')
             when 'millesime'
               @wines.order('millesimes.year, millesimes.wine_id')
             when 'country'
               @wines.order('countries.name, millesimes.wine_id')
             else
               @wines.order('wines.domain, millesimes.wine_id')
             end
  end

  def handles_filter(params)
    @wines = case params[:filter]
             when 'color'
               @wines.where('wines.color_id = ?', params[:filter_id].to_i)
             when 'region'
               @wines.where('wines.region_id = ?', params[:filter_id].to_i)
             when 'zone'
               begin
                 region = Region.find(params[:filter_id].to_i)
                 @wines.where('wines.region_id' => region.self_and_descendants)
               rescue ActiveRecord::RecordNotFound
                 redirect_to wines_path, alert: 'Unknown requested region'
               end
             else
               @wines
             end
  end
end
