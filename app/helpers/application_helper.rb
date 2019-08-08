module ApplicationHelper
  def link_to_destroy(object, options={})
    content = if options[:no_img]
                'Destroy'
              else
                image_tag('delete.png', alt: 'Destroy')
              end
    link_to content, object, method: :delete, data: { confirm: 'Are you sure?' }
  end
end
