module ColorsHelper
  def colored_square(color)
    content_tag(:span, raw('&nbsp;&nbsp;'),
                class: 'square',
                style: "background-color: #{color.color}")
  end
end
