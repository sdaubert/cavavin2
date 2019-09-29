class ProducersController < ApplicationController
  before_action :at_producer, only: %i[show edit update destroy]

  # GET /producers
  # GET /producers.json
  def index
    @producers = Producer.page(params[:page])
  end

  # GET /producers/1
  # GET /producers/1.json
  def show; end

  # GET /producers/new
  def new
    @producer = Producer.new
  end

  # GET /producers/1/edit
  def edit; end

  # POST /producers
  # POST /producers.json
  def create
    @producer = Producer.new(producer_params)

    if @producer.save
      redirect_to @producer, notice: 'Producer was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /producers/1
  # PATCH/PUT /producers/1.json
  def update
    if @producer.update(producer_params)
      redirect_to @producer, notice: 'Producer was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /producers/1
  # DELETE /producers/1.json
  def destroy
    @producer.destroy
    redirect_to producers_url, notice: 'Producer was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def at_producer
    @producer = Producer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def producer_params
    params.require(:producer)
          .permit(:name, :address, :zip, :city, :country_id, :notes, :phone,
                  :web, :email)
  end
end
