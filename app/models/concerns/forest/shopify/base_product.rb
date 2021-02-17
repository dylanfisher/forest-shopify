module Forest::Shopify
  module BaseProduct
    extend ActiveSupport::Concern

    included do
      include Blockable
      include Sluggable
      include Statusable

      has_many :variants, class_name: 'Forest::Shopify::Variant', foreign_key: 'forest_shopify_product_id', dependent: :destroy
      has_one :featured_variant, -> { order('forest_shopify_variants.id ASC') }, class_name: 'Forest::Shopify::Variant', foreign_key: 'forest_shopify_product_id', dependent: :destroy

      has_many :product_options, class_name: 'Forest::Shopify::ProductOption', foreign_key: 'forest_shopify_product_id', dependent: :destroy

      has_many :collection_products, class_name: 'Forest::Shopify::CollectionProduct', foreign_key: 'forest_shopify_product_id', dependent: :destroy
      has_many :collections, through: :collection_products, source: :forest_shopify_collection, class_name: 'Forest::Shopify::Collection'

      has_many :images, as: :forest_shopify_record, dependent: :destroy
      has_many :media_items, through: :images

      has_one :featured_image, -> { order(id: :asc) }, as: :forest_shopify_record, class_name: 'Forest::Shopify::Image'
      has_one :featured_media_item, through: :featured_image, source: :media_item

      scope :available_for_sale, -> { where(available_for_sale: true) }
    end

    class_methods do
      def resource_description
        'Products are created and managed in Shopify and sync automatically to Forest.'
      end
    end

    def slug_attribute
      handle
    end

    def to_select2_response
      if featured_media_item.try(:attachment_url, :thumb).present?
        img_tag = "<img src='#{featured_media_item.attachment_url(:thumb)}' style='height: 20px; margin-right: 5px;'> "
      end
      "#{img_tag}<span class='select2-response__id' style='margin-right: 5px;'>#{id}</span> #{to_label}"
    end
  end
end
