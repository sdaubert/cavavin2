module ApplicationHelper
  def link_to_destroy(object, options={})
    content = if options[:no_img]
                t_action(:destroy)
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

  # Redefinition of t_model from i18n_rails_helper
  # Add pluralize argument
  def t_model(model = nil, pluralize: false)
    logger.info("model: #{model.inspect}")
    return model.model_name.human if model.is_a? ActiveModel::Naming
    return model.class.model_name.human if model.class.is_a? ActiveModel::Naming

    model_key = if model.is_a? Class
                  model.name.underscore
                elsif model.nil?
                  controller_name.singularize
                else
                  model.class.name.underscore
                end
    count = pluralize ? 2 : 1
    I18n.t("activerecord.models.#{model_key}", count: count)
  end

  # Redefinition of t_title from i18n_rails_helper
  # Pluralize model from crud.title.pluralize_index key
  def t_title(action = nil, model = nil, count: 1)
    model_key = model&.model_name&.i18n_key || model&.class&.model_name&.i18n_key ||
                controller_name.underscore

    pluralize = t('crud.title.pluralize_index') && ((action || action_name).to_s == 'index')
    logger.info ("pluralize_index: #{t('crud.title.pluralize_index').inspect}; pluralize: #{pluralize.inspect}")
    I18n.t("#{model_key}.#{action || action_name}.title",
           default: [:"crud.title.#{action || action_name}"], model: t_model(model, pluralize: pluralize))
  end

end
