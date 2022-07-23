module Forest::Shopify
  module BaseVariant
    extend ActiveSupport::Concern

    included do
      include Sluggable
      include Statusable

      serialize :selected_options

      belongs_to :product, class_name: 'Forest::Shopify::Product', foreign_key: 'forest_shopify_product_id', optional: true

      has_one :image, as: :forest_shopify_record, dependent: :destroy
      has_one :media_item, through: :image, source: :media_item

      scope :available_for_sale, -> { where(available_for_sale: true) }
    end

    class_methods do
      def resource_description
        'Variants represent a Shopify ProductVariant object.'
      end
    end

    def display_price
      "$#{price.sub(/\.00$/, '')}" if price.present?
    end

    def display_compare_at_price
      "$#{compare_at_price.sub(/\.00$/, '')}" if compare_at_price.present?
    end
  end
end
