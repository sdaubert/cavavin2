class ColorsController < ApplicationController
  def index
    @colors = Color.by_name.all
  end

  def new
    @color = Color.new
  end

  def edit
    @color = Color.find(params[:id])
  end

  def create
    @color = Color.new(color_params)

    if @color.save
      redirect_to colors_path
    else
      render 'new'
    end
  end

  def update
    @color = Color.find(params[:id])

    if @color.update(color_params)
      redirect_to colors_path
    else
      render 'edit'
    end
  end

  def destroy
    @color = Color.find(params[:id])
    @color.destroy

    redirect_to colors_path
  end

  def stats
    @colors = Hash[Color.order(:name).all.map { |c| [c, 0] }]
    Wine.find_each do |wine|
      @colors[wine.color] += wine.quantity
    end
    @colors.delete_if { |_color, value| value.zero? }

    @rgb_colors = @colors.map { |c, _sum| c.color }
    @rgb_colors = nil if @rgb_colors.compact.empty?
  end

  private

  def color_params
    params.require(:color).permit(:name, :color)
  end
end
