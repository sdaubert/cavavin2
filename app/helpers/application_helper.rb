module ApplicationHelper
  def link_to_destroy(object)
    link_to image_tag('delete.png', alt: 'Destroy'), object, method: :delete, data: { confirm: 'Are you sure?' }
  end
end
