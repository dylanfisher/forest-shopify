module Forest::Shopify
  class Product < Forest::ApplicationRecord
    include Blockable
    include Sluggable
    include Statusable

    before_save :decode_shopify_id

    has_many :variants, class_name: 'Forest::Shopify::Variant', foreign_key: 'forest_shopify_product_id', dependent: :destroy

    has_many :collection_products, class_name: 'Forest::Shopify::CollectionProduct', foreign_key: 'forest_shopify_product_id', dependent: :destroy
    has_many :collections, through: :collection_products, source: :forest_shopify_collection, class_name: 'Forest::Shopify::Collection'

    has_many :images, as: :forest_shopify_record, dependent: :destroy
    has_many :media_items, through: :images

    has_one :featured_image, -> { order(id: :asc) }, as: :forest_shopify_record, class_name: 'Forest::Shopify::Image'
    has_one :featured_media_item, through: :featured_image, source: :media_item

    scope :available_for_sale, -> { where(available_for_sale: true) }

    def self.resource_description
      'Products are created and managed in Shopify and sync automatically to Forest.'
    end

    def slug_attribute
      handle
    end

    private

    def decode_shopify_id
      self.shopify_id = Base64.decode64(shopify_id_base64).split('/').last if shopify_id_base64_changed?
    end
  end
end
