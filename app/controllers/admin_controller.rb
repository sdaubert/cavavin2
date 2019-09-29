class AdminController < ApplicationController
  YEARS_TO_DRINK_WINES = 2
  CELLAR_BOOK_LAST_ENTRIES_COUNT = 10
  SPENDINGS_YEAR_COUNT = 10
  EVOLUTION_YEAR_COUNT = 3
  DRINKING_YEAR_COUNT = 5

  SELECT_QUANTITY_PER_MONTH = 'strftime("%Y-%m", date) as ym, sum(quantity)'

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
    compute_spendings
    compute_evolution
    compute_garde
    compute_drinking
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
        new_ary_of_ary << [(last_known_year + 1).to_s, 0.0]
        last_known_year = new_ary_of_ary.last.first.to_i
      end
      new_ary_of_ary << ary
    end

    new_ary_of_ary
  end

  def compute_spendings
    date_range = SPENDINGS_YEAR_COUNT.years.ago.at_beginning_of_year..Time.now
    spendings = Wlog.where(mvt_type: 'in')
                    .group_by_year(:date,
                                   range: date_range)
                    .pluck(Arel.sql('strftime("%Y", date), sum(quantity*price) as total'))

    @spendings = fix_holes_in_years(spendings)
  end

  def compute_first_date
    first_wlog = Wlog.order(:date).first
    return Time.now.to_date if first_wlog.nil?

    first_date = first_wlog.date.beginning_of_month
    return first_date if EVOLUTION_YEAR_COUNT.zero?

    ago = Time.now.to_date.beginning_of_month - EVOLUTION_YEAR_COUNT.year
    [first_date, ago].max
  end

  def compute_first_value(first_date)
    first_value = Wlog.where('date <= ?', first_date.end_of_month)
                      .where(mvt_type: 'in')
                      .sum(:quantity)
    first_value - Wlog.where('date <= ?', first_date.end_of_month)
                      .where(mvt_type: 'out')
                      .sum(:quantity)
  end

  def compute_evolution_values(req, type:)
    values = req.where(mvt_type: type)
                .pluck(Arel.sql(SELECT_QUANTITY_PER_MONTH))
    values = Hash[values]
    values.default = 0

    values
  end

  def evolution_values(first_date, last_date)
    data = []
    request = Wlog.group_by_month_of_year(:date, range: first_date..last_date)

    inval = compute_evolution_values(request, type: 'in')
    outval = compute_evolution_values(request, type: 'out')

    (first_date.next_month..last_date).select { |d| d.day == 1 }.each do |month|
      ym = month.strftime('%Y-%m')
      data << [ym, @evolution.last.last + inval[ym] - outval[ym]]
    end

    data
  end

  def compute_evolution
    first_date = compute_first_date
    first_value = compute_first_value(first_date)
    last_date = Time.now.to_date.end_of_month

    @evolution = [[first_date.strftime('%Y-%m'), first_value]]
    @evolution.concat(evolution_values(first_date, last_date))
  end

  def compute_garde
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

  def compute_drinking
    first_year = DRINKING_YEAR_COUNT.years.ago.year

    @drinking = Color.all.map do |color|
      year_range = DRINKING_YEAR_COUNT.years.ago.at_beginning_of_year..Time.now
      data = color.wines
                  .drunk
                  .group_by_year('wlogs.date', range: year_range)
                  .order('year')
                  .pluck(Arel.sql('strftime("%Y", wlogs.date) as year, sum(wlogs.quantity)'))

      data.unshift [first_year, 0] if !data.empty? && (data.last.first.to_i != first_year)

      { name: color.name, data: fix_holes_in_years(data) }
    end
  end
end
