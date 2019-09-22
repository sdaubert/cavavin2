module RegionsHelper
  def link_to_region(region)
    link_to region.name, country_region_path(region.country, region)
  end

  def generate_region_tree(country)
    content_tag(:ul, class: 'treeview') do
      tree_from country.regions.roots.all
    end
  end

  # Should not be used directly
  def tree_from(nodes)
    out = +''

    nodes.each do |node|
      descendants = node.direct_descendants.all
      out << content_tag(:li) do
               if descendants.count.positive?
                 out2 = content_tag(:span, link_to_region(node), class: 'caret')
                 out2 << content_tag(:ul, class: 'nested') do
                   tree_from descendants
                 end
                 out2

                 out2
               else
                 content_tag(:span, link_to_region(node), class: 'no-caret')
               end
             end

      out << "\n"
    end

    raw out
  end
end
