class AdminController < ApplicationController
  YEARS_TO_DRINK_WINES = 2
  CELLAR_BOOK_LAST_ENTRIES_COUNT = 10

  def main
    @bottle_count = Bottle.count
    @wine_count = Wine.with_bottles.count

    @years_to_drink_wines = YEARS_TO_DRINK_WINES
    @millesimes = Millesime.with_bottles.drink_before(YEARS_TO_DRINK_WINES).order('diff').all
    logger.debug Millesime.with_bottles.drink_before(YEARS_TO_DRINK_WINES).inspect
    @bottles_to_drink = @millesimes.to_a.inject(0) { |sum, mil| sum + mil.quantity }

    @book = Wlog.order(date: :desc, id: :desc).take(CELLAR_BOOK_LAST_ENTRIES_COUNT)
  end

  def book
    @book = Wlog.order(date: :desc, id: :desc).paginate(page: params[:page], per_page: 5)
  end
end
