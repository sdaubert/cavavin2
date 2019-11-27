module PreferencesHelper
  def preference_field(pref)
    name = "pref[#{pref.setting}]".freeze
    case pref.stype
    when 'boolean'
      check_box_tag(name, 'true', pref.ruby_value)
    else
      text_field_tag(name, pref.ruby_value)
    end
  end
end
