class MillesimesController < ApplicationController
  before_action :set_wine
  before_action :set_millesime, only: [:show, :edit, :update, :destroy]

  def index
    @millesimes = Millesime.all
  end

  def show
    @racks = BottleRack.millesime(@millesime).all
  end

  def new
    @millesime = @wine.millesimes.build
  end

  def edit; end

  def create
    @millesime = @wine.millesimes.build(millesime_params)

    if @millesime.save
      redirect_to @millesime.wine, notice: 'Millesime was successfully created.'
    else
      render :new
    end
  end

  def update
    if @millesime.update(millesime_params)
      redirect_to @millesime.wine, notice: 'Millesime was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @millesime.destroy
    redirect_to wine_url(@wine), notice: 'Millesime was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_millesime
    @millesime = @wine.millesimes.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def millesime_params
    params.require(:millesime).permit(:year, :garde, :wine_id, :notes)
  end
end
