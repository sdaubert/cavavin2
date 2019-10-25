class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # @private
  def self.symbol2table(sym)
    const_get(sym.to_s.singularize.camelize).arel_table
  end

  # fields: hash of table/field names
  # keywords: an array of words to search
  def self.concat_fields_like(h, keywords)
    prequery = nil
    h.each do |table_name, fields|
      table = symbol2table(table_name)
      prequery = table[fields.shift] if prequery.nil?

      fields.each { |f| prequery = prequery.concat(table[f]) }
    end

    query = prequery.matches("%#{keywords.shift}%")
    keywords.each do |kw|
      query = query.and(prequery.matches("%#{kw}%"))
    end

    where(query)
  end
end
