module ApplicationHelper
  def link_to_destroy(object, options={})
    content = if options[:no_img]
                'Destroy'
              else
                image_tag('delete.png', alt: 'Destroy')
              end

    name = if object.respond_to?(:name)
             object.name
           elsif object.respond_to?(:domain)
             object.domain
           elsif object.respond_to?(:year)
             object.year
           else
             object
           end

    link_to content, object, method: :delete, data: { confirm: t_confirm_delete(name) }
  end
end
