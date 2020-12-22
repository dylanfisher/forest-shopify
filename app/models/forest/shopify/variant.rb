module Forest::Shopify
  class Variant < Forest::ApplicationRecord
    include Sluggable
    include Statusable

    belongs_to :product, class_name: 'Forest::Shopify::Product', foreign_key: 'forest_shopify_product_id', optional: true

    has_one :image, -> { order(id: :asc) }, as: :forest_shopify_record
    has_one :media_item, through: :image, source: :media_item

    def self.resource_description
      'Variants represent a Shopify ProductVariant object.'
    end
  end
end
