module Forest::Shopify
  module BaseVariant
    extend ActiveSupport::Concern

    included do
      include Sluggable
      include Statusable

      serialize :selected_options

      belongs_to :product, class_name: 'Forest::Shopify::Product', foreign_key: 'forest_shopify_product_id', optional: true

      has_one :image, -> { order(id: :asc) }, as: :forest_shopify_record, dependent: :destroy
      has_one :media_item, through: :image, source: :media_item
    end

    class_methods do
      def resource_description
        'Variants represent a Shopify ProductVariant object.'
      end
    end

    def display_price
      "$#{price.sub(/\.00$/, '')}"
    end
  end
end
