module Forest::Shopify
  module BaseProduct
    extend ActiveSupport::Concern

    included do
      include Blockable
      include Sluggable
      include Statusable

      has_many :variants, -> { order('forest_shopify_variants.position ASC') }, class_name: 'Forest::Shopify::Variant', foreign_key: 'forest_shopify_product_id', dependent: :destroy
      has_many :variants_available_for_sale, -> { order('forest_shopify_variants.position ASC').available_for_sale }, class_name: 'Forest::Shopify::Variant', foreign_key: 'forest_shopify_product_id', dependent: :destroy
      has_one :featured_variant, -> { order('forest_shopify_variants.position ASC') }, class_name: 'Forest::Shopify::Variant', foreign_key: 'forest_shopify_product_id', dependent: :destroy

      has_many :product_options, -> { where.not(values: ['Default Title']) }, class_name: 'Forest::Shopify::ProductOption', foreign_key: 'forest_shopify_product_id', dependent: :destroy
      has_many :product_product_tags, class_name: 'Forest::Shopify::ProductProductTag', foreign_key: 'forest_shopify_product_id', dependent: :destroy
      has_many :product_tags, class_name: 'Forest::Shopify::ProductTag', through: :product_product_tags

      has_many :collection_products, class_name: 'Forest::Shopify::CollectionProduct', foreign_key: 'forest_shopify_product_id', dependent: :destroy
      has_many :collections, through: :collection_products, source: :forest_shopify_collection, class_name: 'Forest::Shopify::Collection'

      has_many :images, -> { order('forest_shopify_images.position ASC') }, as: :forest_shopify_record, dependent: :destroy
      has_many :media_items, through: :images

      has_many :videos, -> { order('forest_shopify_videos.position ASC') }, as: :forest_shopify_record, dependent: :destroy

      has_one :featured_image, -> { where(position: 0) }, as: :forest_shopify_record, class_name: 'Forest::Shopify::Image'
      has_one :featured_media_item, through: :featured_image, source: :media_item

      scope :available_for_sale, -> { where(available_for_sale: true) }
      scope :by_publish_date, -> { order(shopify_published_at: :desc) }
      scope :for_product_tag, -> (tag_slug) { joins(:product_tags).where(product_tags: { slug: tag_slug }) }
      scope :for_option_name, -> (option_name) { joins(:product_options).where('LOWER(forest_shopify_product_options.name) = ?', option_name.downcase) }
      scope :for_option_value, -> (option_value) { joins(:product_options).where("forest_shopify_product_options.values ILIKE '%' || ? || '%'", option_value.downcase) }
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
        img_tag = "<img src='#{featured_media_item.attachment_url(:thumb)}' style='height: 21px; margin-right: 5px;'> "
      end
      "#{img_tag}<span class='select2-response__id' style='margin-right: 5px;'>#{id}</span> #{to_label}"
    end

    def sync
      Forest::Shopify::Storefront::Product.sync(shopify_id_base64: shopify_id_base64)
    end
  end
end
