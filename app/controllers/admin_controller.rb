class AdminController < ApplicationController
  YEARS_TO_DRINK_WINES = 2
  CELLAR_BOOK_LAST_ENTRIES_COUNT = 10
  SPENDINGS_YEAR_COUNT = 10
  EVOLUTION_YEAR_COUNT = 3
  DRINKING_YEAR_COUNT = 5

  FakeSpending = Struct.new(:year, :total)

  def main
    @bottle_count = Bottle.count
    @wine_count = Wine.with_bottles.count

    @years_to_drink_wines = YEARS_TO_DRINK_WINES
    @millesimes = Millesime.with_bottles.drink_before(YEARS_TO_DRINK_WINES).all
    @bottles_to_drink = @millesimes.to_a.inject(0) { |sum, mil| sum + mil.quantity }

    @book = Wlog.order(date: :desc, id: :desc).take(CELLAR_BOOK_LAST_ENTRIES_COUNT)
  end

  def book
    @book = Wlog.order(date: :desc, id: :desc).page(params[:page])
  end

  def stats
    set_spendings
    set_evolution
    set_garde
    set_drinking
  end

  private

  def fix_holes_in_years(ary_of_ary)
    new_ary_of_ary = []

    ary_of_ary.each_with_index do |ary, idx|
      if idx.zero?
        new_ary_of_ary << ary
        next
      end

      current_year = ary.first.to_i
      last_known_year = new_ary_of_ary.last.first.to_i
      while current_year != last_known_year + 1
        new_ary_of_ary << ["#{last_known_year + 1}", 0.0]
        last_known_year = new_ary_of_ary.last.first.to_i
      end
      new_ary_of_ary << ary
    end

    new_ary_of_ary
  end

  def set_spendings
    spendings = Wlog.where(mvt_type: 'in')
                    .group_by_year(:date,
                                   range: SPENDINGS_YEAR_COUNT.years.ago.at_beginning_of_year..Time.now)
                    .pluck(Arel.sql('strftime("%Y", date), sum(quantity*price) as total'))

    @spendings = fix_holes_in_years(spendings)
  end

  def get_first_date
    first_date = Wlog.order(:date).first.date.beginning_of_month
    return first_date if EVOLUTION_YEAR_COUNT == 0

    [first_date, Time.now.to_date.beginning_of_month - EVOLUTION_YEAR_COUNT.year].max
  end

  def set_evolution
    first_date = get_first_date
    last_date = Time.now.to_date.end_of_month

    first_value = Wlog.where('date <= ?', first_date.end_of_month)
                      .sum(:quantity)

    @evolution = [[first_date.strftime('%Y-%m'), first_value ]]

    request = Wlog.group_by_month_of_year(:date, range: first_date..last_date)

    inval = request.where(mvt_type: 'in')
                   .pluck(Arel.sql('strftime("%Y-%m", date) as ym, sum(quantity)'))
    inval = Hash[inval]
    inval.default = 0
    outval = request.where(mvt_type: 'out')
                    .pluck(Arel.sql('strftime("%Y-%m", date) as ym, sum(quantity)'))
    outval = Hash[outval]
    outval.default = 0

    (first_date..last_date).select { |d| d.day == 1}.each do |month|
      ym = month.strftime('%Y-%m')
      @evolution << [ym, @evolution.last.last + inval[ym] - outval[ym]]
    end
  end

  def set_garde
    before5 = Millesime.drink_before(5)
                       .joins(:bottles)
                       .count
    between5and10 = Millesime.drink_after(5)
                             .drink_before(10)
                             .joins(:bottles)
                             .count
    after10 = Millesime.with_bottles
                       .drink_after(10)
                       .joins(:bottles)
                       .count
    @garde = [['Less than 5 years', before5],
              ['Between 5 and 10 years', between5and10],
              ['More than 10 years', after10]]
  end

  def set_drinking
    @drinking = []
    first_year = DRINKING_YEAR_COUNT.years.ago.year

    Color.all.each do |color|
      data = color.wines
                  .joins(millesimes: [:wlogs])
                  .group_by_year('wlogs.date', range: DRINKING_YEAR_COUNT.years.ago.at_beginning_of_year..Time.now)
                  .where(wlogs: { mvt_type: 'out' })
                  .order('year')
                  .pluck(Arel.sql('strftime("%Y", wlogs.date) as year, sum(wlogs.quantity)'))

      data.unshift [first_year, 0]if data.last.first.to_i != first_year
      h = {
        name: color.name,
        data: fix_holes_in_years(data)
      }
      @drinking << h
    end
  end
end
