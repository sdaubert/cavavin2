class MillesimesController < ApplicationController
  before_action :at_wine
  before_action :at_millesime, only: %i[show edit update destroy]

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
      redirect_to [@millesime.wine, @millesime], notice: 'Millesime was successfully created.'
    else
      render :new
    end
  end

  def update
    if @millesime.update(millesime_params)
      redirect_to [@wine, @millesime], notice: 'Millesime was successfully updated.'
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
  def at_millesime
    @millesime = @wine.millesimes.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def millesime_params
    p = params.require(:millesime).permit(:year, :garde, :wine_id, :notes)
    if params[:millesime][:void_millesime] == 1
      p[:millesime][:year] = nil
      p[:millesime][:garde] = nil
    end

    p
  end
end
