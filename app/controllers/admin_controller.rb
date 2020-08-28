class AdminController < ApplicationController
  YEARS_TO_DRINK_WINES = 2
  CELLAR_BOOK_LAST_ENTRIES_COUNT = 10
  SPENDINGS_YEAR_COUNT = 10
  EVOLUTION_YEAR_COUNT = 3
  DRINKING_YEAR_COUNT = 5

  FakeSpending = Struct.new(:year, :total)

  MILLESIME_SEARCH_FIELDS = {
    wine: %i[domain notes],
    millesime: %i[notes],
    region: %i[name],
    country: %i[name],
    color: %i[name]
  }.freeze

  PRODUCER_SEARCH_FIELDS = {
    producer: %i[name address zip city phone web email notes],
    country: %i[name]
  }.freeze

  PROVIDER_SEARCH_FIELDS = {
    provider: %i[name address zip city phone web email notes],
    country: %i[name]
  }.freeze

  def main
    @bottle_count = Bottle.count
    @wine_count = Wine.with_bottles.count

    @years_to_drink_wines = YEARS_TO_DRINK_WINES
    @millesimes = Millesime.with_bottles.drink_before(YEARS_TO_DRINK_WINES).order(:diff).all
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

  def search
    keywords = params[:search].to_s.split
    return if keywords.length.zero?

    @millesimes = Millesime.joins(wine: [:color, { region: :country }])
                           .concat_fields_like(MILLESIME_SEARCH_FIELDS, keywords)

    @producers = Producer.joins(:country)
                         .concat_fields_like(PRODUCER_SEARCH_FIELDS, keywords)

    @providers = Provider.joins(:country)
                         .concat_fields_like(PROVIDER_SEARCH_FIELDS, keywords)
  end

  def preferences
    @preferences = Preference.all
  end

  def set_preferences
    @preferences = Preference.all

    no_error = true

    @preferences.each do |pref|
      if params['pref'].nil? || params['pref'][pref.setting].nil?
        next unless pref.boolean?

        pref.value = 'false'
      elsif !params['pref'].nil?
        pref.value = params['pref'][pref.setting]
      end

      no_error &&= pref.save
    end

    if no_error
      redirect_to admin_preferences_path
    else
      render 'preferences', notice: 'Preferences saved'
    end
  end

  private

  def fix_holes_in_years(ary_of_ary, use_float: false)
    new_ary_of_ary = []
    null = use_float ? 0.0 : 0

    ary_of_ary.each_with_index do |ary, idx|
      if idx.zero?
        new_ary_of_ary << ary
        next
      end

      current_year = ary.first.to_i
      last_known_year = new_ary_of_ary.last.first.to_i
      while current_year != last_known_year + 1
        new_ary_of_ary << [(last_known_year + 1).to_s, null]
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

    @spendings = fix_holes_in_years(spendings, use_float: true)
  end

  def compute_first_date
    first_wlog = Wlog.order(:date).first
    return Time.now.to_date if first_wlog.nil?

    first_date = first_wlog.date.beginning_of_month
    return first_date if EVOLUTION_YEAR_COUNT.zero?

    ago = Time.now.to_date.beginning_of_month - EVOLUTION_YEAR_COUNT.year
    [first_date, ago].max
  end

  def compute_evolution_values(req, type:)
    values = req.where(mvt_type: type).sum(:quantity)
    values = Hash[values]
    values.default = 0

    values
  end

  def quantity_before(date)
    hsh = Wlog.group(:mvt_type).where('date < ?', date).sum(:quantity)
    hsh.default = 0
    hsh['in'] - hsh['out']
  end

  def evolution_values(first_date, last_date)
    data = []
    request = Wlog.group_by_month(:date, range: first_date..last_date, format: '%Y-%m')

    inval = compute_evolution_values(request, type: 'in')
    outval = compute_evolution_values(request, type: 'out')

    (first_date..last_date).select { |d| d.day == 1 }.each do |month|
      ym = month.strftime('%Y-%m')
      previous_value = data.empty? ? quantity_before(first_date) : data.last[1]
      data << [ym, previous_value + inval[ym] - outval[ym]]
    end

    data
  end

  def compute_evolution
    first_date = compute_first_date
    last_date = Time.now.to_date.end_of_month

    @evolution = evolution_values(first_date, last_date)
  end

  def compute_garde
    before5 = Millesime.drink_before(5)
                       .joins(:bottles)
                       .count('bottles.id')
    between5and10 = Millesime.drink_after(5)
                             .drink_before(10)
                             .joins(:bottles)
                             .count('bottles.id')
    after10 = Millesime.with_bottles
                       .drink_after(10)
                       .joins(:bottles)
                       .count('bottles.id')
    @garde = [[t('view.statistic.lt5'), before5],
              [t('view.statistic.bt5and10'), between5and10],
              [t('view.statistic.gt10'), after10]]
  end

  def compute_drinking
    first_year = DRINKING_YEAR_COUNT.years.ago.year.to_s
    colors = Color.with_wines

    @colors = colors.map(&:color)
    if @colors.compact.empty?
      @colors = nil
    else
      @colors.unshift('#3366CC')
    end

    total_data = nil
    @drinking = colors.map do |color|
      year_range = DRINKING_YEAR_COUNT.years.ago.at_beginning_of_year..Time.now
      data = color.wines
                  .drunk
                  .group_by_year('wlogs.date', range: year_range)
                  .order('year')
                  .pluck(Arel.sql('strftime("%Y", wlogs.date) as year, sum(wlogs.quantity)'))

      data.unshift [first_year, 0] if !data.empty? && (data.last.first != first_year)
      data = fix_holes_in_years(data)

      if total_data.nil?
        total_data = data.map(&:dup)
      else
        (0...data.size).each do |idx|
          total_data[idx][1] += data[idx][1]
        end
      end

      { name: color.name, data: data }
    end

    @drinking.unshift(name: 'Total', data: total_data)
  end
end
