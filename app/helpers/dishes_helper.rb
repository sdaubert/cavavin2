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

  def generate_line(dish, region, level=0)
    tr_opts = {}
    unless region.root?
      #tr_opts[:class] = region.ancestors.map { |a| "child-of-#{a.id}" }
      tr_opts[:class] = ["child-of-#{region.parent.id}"]
      tr_opts[:class] += region.parent.ancestors.map { |a| "subchild-of-#{a.id}" }
      tr_opts[:class] << 'not-root'
    end

    td_opts = {}
    td_opts[:class] = if region.leaf?
                        'leaf'
                      else
                        'not-leaf'
                      end

    content = content_tag(:tr, tr_opts) do
      aligner = '&nbsp;' * (level * 4)
      td_content = aligner + '&nbsp;' + content_tag(:span, region.name)
      tr_content = content_tag(:td, raw(td_content), td_opts) << "\n"

      @colors.each do |color|
        dish_has_region_color = dish.dras
                                    .where(region: region.id, color: color.id)
                                    .count == 1
        tr_content << content_tag(:td) do
          field_id = "regions[#{region.id}][#{color.id}]"
          check_box_tag(field_id, 'true', dish_has_region_color)
        end
        tr_content << "\n"
      end

      tr_content
    end

    unless region.leaf?
      content << raw(region.children.map { |subr| generate_line(dish, subr, level+1) }.join)
    end

    raw content
  end
end
