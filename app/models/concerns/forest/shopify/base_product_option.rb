module Forest::Shopify
  module BaseProductOption
    extend ActiveSupport::Concern

    included do
      serialize :values

      belongs_to :product, class_name: 'Forest::Shopify::Product', foreign_key: 'forest_shopify_product_id', optional: true

      scope :for_option_name, -> (option_name) { where('forest_shopify_product_options.name ILIKE ?', option_name) }
    end

    class_methods do
      def product_option_names
        distinct.pluck(:name).collect(&:downcase).uniq
      end

      def values_for_option_name(option_name)
        distinct.for_option_name(option_name).pluck(:values)
      end
    end
  end
end
