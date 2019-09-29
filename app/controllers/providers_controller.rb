class ProvidersController < ApplicationController
  before_action :at_provider, only: %i[show edit update destroy]

  # GET /providers
  # GET /providers.json
  def index
    @providers = Provider.page(params[:page])
  end

  # GET /providers/1
  # GET /providers/1.json
  def show; end

  # GET /providers/new
  def new
    @provider = Provider.new
  end

  # GET /providers/1/edit
  def edit; end

  # POST /providers
  # POST /providers.json
  def create
    @provider = Provider.new(provider_params)

    if @provider.save
      redirect_to @provider, notice: 'Provider was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /providers/1
  # PATCH/PUT /providers/1.json
  def update
    if @provider.update(provider_params)
      redirect_to @provider, notice: 'Provider was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /providers/1
  # DELETE /providers/1.json
  def destroy
    @provider.destroy
    redirect_to providers_url, notice: 'Provider was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def at_provider
    @provider = Provider.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def provider_params
    params.require(:provider)
          .permit(:name, :address, :zip, :city, :country_id, :phone, :web,
                  :email, :notes)
  end
end
