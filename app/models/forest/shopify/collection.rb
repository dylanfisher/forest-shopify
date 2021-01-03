module Forest::Shopify
  class Collection < Forest::ApplicationRecord
    include Blockable
    include Sluggable
    include Statusable

    has_many :collection_products, class_name: 'Forest::Shopify::CollectionProduct', foreign_key: 'forest_shopify_collection_id', dependent: :destroy
    has_many :products, through: :collection_products, source: :forest_shopify_product, class_name: 'Forest::Shopify::Product'

    has_one :image, -> { order(id: :asc) }, as: :forest_shopify_record, dependent: :destroy
    has_one :media_item, through: :image, source: :media_item

    def self.resource_description
      'Collections are groupings of products created and organized in Shopify.'
    end
  end
end
