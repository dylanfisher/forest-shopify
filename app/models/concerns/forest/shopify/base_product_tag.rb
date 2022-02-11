module Forest::Shopify
  module BaseProductTag
    extend ActiveSupport::Concern

    included do
      include Sluggable

      validates :name, uniqueness: true, presence: true

      has_many :product_product_tags, class_name: 'Forest::Shopify::ProductProductTag', foreign_key: 'forest_shopify_product_tag_id'
      has_many :products, class_name: 'Forest::Shopify::Product', through: :product_product_tags

      belongs_to :media_item, optional: true

      scope :by_name, -> { order(name: :asc) }
    end

    class_methods do
      def resource_description
        'Product tags are used to categorize products within Shopify. Product tag images can be customized within Forest.'
      end
    end
  end
end
