module RegionsHelper
  def link_to_region(region)
    link_to region.name, country_region_path(region.country, region)
  end

  def generate_region_tree(country)
    content_tag(:ul, class: 'treeview') do
      tree_from country.regions.roots.by_name
    end
  end

  private

  def tree_from(nodes)
    out = +''

    nodes.each do |node|
      descendants = node.direct_descendants.by_name
      out << content_tag(:li) do
        if descendants.count.positive?
          out2 = content_tag(:span, link_to_region(node), class: 'caret')
          out2 << content_tag(:ul, class: 'nested') do
            tree_from descendants
          end
        else
          content_tag(:span, link_to_region(node), class: 'no-caret')
        end
      end

      out << "\n"
    end

    raw out
  end
end
