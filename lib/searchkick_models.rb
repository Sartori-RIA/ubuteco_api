# frozen_string_literal: true

module SearchkickModels
  class << self
    def all
      @all ||= [
        User,
        Beer,
        Drink,
        Food,
        Dish,
        Wine,
        Maker,
        Order,
        Organization
      ].freeze
    end

    def find!(name)
      all.find { |model| model.name == name.to_s } ||
        raise(ArgumentError, "Unknown Searchkick model: #{name}")
    end
  end
end
