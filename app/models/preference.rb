class Preference < ApplicationRecord
  SETTING_TYPES = %w[boolean integer].freeze
  BOOLEAN_VALUES = %w[false true].freeze

  validates :setting, presence: true, uniqueness: true
  validates :stype, presence: true, inclusion: { in: SETTING_TYPES }
  validates :value, presence: true
  validate :value_from_stype

  def self.value(setting)
    pref = Preference.find_by_setting(setting)
    return nil if pref.nil?

    pref.ruby_value
  end

  def ruby_value
    case stype
    when 'boolean'
      case value
      when 'true'
        true
      when 'false'
        false
      else
        nil
      end
    when 'integer'
      value.to_i
    end
  end

  def boolean?
    stype == 'boolean'
  end

  private

  def value_from_stype
    case stype
    when 'boolean'
      if value.nil? || !BOOLEAN_VALUES.include?(value.downcase)
        errors.add(:value, 'not a boolean')
      end
    when 'integer'
      unless value =~ /^[0-9]+$/
        errors.add(:value, 'not an integer')
      end
    end
  end
end
