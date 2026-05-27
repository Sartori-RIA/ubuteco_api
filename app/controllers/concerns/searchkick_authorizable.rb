# frozen_string_literal: true

module SearchkickAuthorizable
  extend ActiveSupport::Concern

  private

  def pagy_search_authorized(model, action: :read, **options)
    per_page = options.delete(:per_page) || 20
    search = model.pagy_search(
      params[:q].presence || "*",
      page: params[:page],
      per_page: per_page,
      where: searchkick_where_for(model, action:),
      **options
    )
    pagy(:searchkick, search)
  end

  def searchkick_where_for(model, action: :read)
    conditions = current_ability.model_adapter(model, action).conditions
    return {} if conditions.blank?

    case conditions
    when Hash
      normalize_searchkick_where(conditions)
    else
      { id: model.accessible_by(current_ability, action).pluck(:id) }
    end
  end

  def normalize_searchkick_where(conditions)
    conditions.each_with_object({}) do |(key, value), where|
      case key
      when :role, :roles
        where[:role_name] = value[:name] if value.is_a?(Hash) && value[:name]
      when :status
        where[:status] = value.to_s
      else
        where[key] = value
      end
    end
  end
end
