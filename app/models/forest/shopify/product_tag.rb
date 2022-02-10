module Forest::Shopify
  class ProductTag < Forest::Shopify::ApplicationRecord
    has_many :product_product_tags, class_name: 'Forest::Shopify::ProductProductTag', foreign_key: 'forest_shopify_product_tag_id'
    has_many :products, class_name: 'Forest::Shopify::Product', through: :product_product_tags
  end
end
