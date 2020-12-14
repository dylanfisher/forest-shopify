module Forest::Shopify
  class Variant < Forest::ApplicationRecord
    include Sluggable

    belongs_to :product, class_name: 'Forest::Shopify::Product', foreign_key: 'forest_shopify_product_id', optional: true

    # TODO: image association

    def self.resource_description
      'Variants represent a Shopify ProductVariant object.'
    end
  end
end
