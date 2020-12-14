module Forest::Shopify
  class ProductImage < Forest::ApplicationRecord
    belongs_to :product, class_name: 'Forest::Shopify::Product', foreign_key: 'forest_shopify_product_id'
    belongs_to :media_item, dependent: :destroy
  end
end
