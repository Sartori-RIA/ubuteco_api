# frozen_string_literal: true

module SearchkickAuthorizable
  extend ActiveSupport::Concern

  class SearchUnavailableError < StandardError; end

  SEARCH_UNAVAILABLE = [
    Faraday::Error,
    Searchkick::Error
  ].freeze

  private

  def pagy_search_authorized(model, action: :read, extra_where: {}, **options)
    per_page = options.delete(:per_page) || 20
    semantic = pagy_semantic(model, action:, extra_where:, per_page:)
    return semantic if semantic

    where = searchkick_where_for(model, action:).merge(extra_where)
    search = model.pagy_search(
      params[:q].presence || "*",
      page: params[:page],
      per_page: per_page,
      where:,
      **options
    )
    pagy(:searchkick, search)
  rescue *SEARCH_UNAVAILABLE => e
    Rails.logger.warn("[search] unavailable: #{e.class}: #{e.message}")
    raise SearchUnavailableError, e.message
  end

  def pagy_semantic(model, action:, extra_where:, per_page:)
    mode = resolved_search_mode(model)
    return if mode == 'keyword' || params[:q].blank? || Current.organization.blank?

    records = Catalog::SemanticSearch.call(
      model:,
      query: params[:q],
      where: searchkick_where_for(model, action:).merge(extra_where),
      mode:,
      organization: Current.organization
    )
    return if records.nil?

    paginate_records(records, per_page)
  end

  def resolved_search_mode(model)
    requested = params[:mode].to_s
    return requested if %w[keyword semantic hybrid].include?(requested)
    return 'keyword' unless CatalogEmbeddable::MODELS.include?(model.name)

    Ai.enabled_for?(Current.organization) ? 'hybrid' : 'keyword'
  end

  def paginate_records(records, per_page)
    page = params[:page].to_i
    page = 1 if page < 1
    pagy = Pagy::Offset.new(count: records.length, page:, limit: per_page)
    [pagy, records.slice(pagy.offset, pagy.limit) || []]
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
