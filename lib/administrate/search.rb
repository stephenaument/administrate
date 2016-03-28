require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"

module Administrate
  class Search
    def initialize(resolver, term)
      @resolver = resolver
      @term = term
    end

    def run
      if @term.blank?
        dashboard_model.all
      else
        dashboard_model.where(query, *search_terms)
      end
    end

    private

    delegate :resource_class, to: :resolver

    def dashboard_model
      if resource_class.respond_to?(:translates?) &&
         resource_class.translates?
        resource_class.with_translations(I18n.locale)
      else
        resource_class
      end
    end

    def query
      search_attributes.map { |attr| "lower(#{attr}) LIKE ?" }.join(" OR ")
    end

    def search_terms
      ["%#{term.downcase}%"] * search_attributes.count
    end

    def search_attributes
      attribute_types.keys.select do |attribute|
        attribute_types[attribute].searchable?
      end
    end

    def attribute_types
      resolver.dashboard_class::ATTRIBUTE_TYPES
    end

    attr_reader :resolver, :term
  end
end
