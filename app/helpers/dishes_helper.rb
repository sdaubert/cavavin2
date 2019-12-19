module DishesHelper
  def generate_regions_table_lines(dish)
    out = ''
    @countries.each do |country|
      out << content_tag(:tr) do
        content_tag(:td, country.name, class: 'country') +
          content_tag(:td, '', colspan: @colors_count)
      end
      out << "\n"
      country.regions.roots.map do |root|
        out << generate_line(dish, root)
      end
    end

    raw out
  end

  def generate_line(dish, region, level = 0)
    content = content_tag(:tr, tr_opts(region)) do
      tr_content = content_tag(:td, td_opts(region)) do
        raw(aligner(level) + content_tag(:span, region.name))
      end << "\n"

      tr_content << raw(generate_columns(dish, region))
    end

    content << generate_children_region(region, dish, level + 1)
  end

  def localized_dish_type(dtype)
    t("dish.type.#{dtype}")
  end

  private

  def tr_opts(region)
    tr_opts = {}
    unless region.root?
      tr_opts[:class] = ["child-of-#{region.parent.id}"]
      tr_opts[:class] += region.parent.ancestors.map { |a| "subchild-of-#{a.id}" }
      tr_opts[:class] << 'not-root'
    end

    tr_opts
  end

  def td_opts(region)
    klass_opt = if region.leaf?
                  'leaf'
                else
                  'not-leaf'
                end

    { class: klass_opt, id: "region_#{region.id}" }
  end

  def aligner(level)
    '&nbsp;' * (level * 4 + 1)
  end

  def generate_columns(dish, region)
    @colors.map do |color|
      next raw(content_tag(:td)) unless region.color?(color)

      checked = dish.region_color?(region, color)
      field_id = "regions[#{region.id}][#{color.id}]"
      raw content_tag(:td, check_box_tag(field_id, 'true', checked, title: color.name))
    end.join("\n") << "\n"
  end

  def generate_children_region(region, dish, level)
    return raw('') if region.leaf?

    raw region.children.map { |subr| generate_line(dish, subr, level) }.join
  end
end
