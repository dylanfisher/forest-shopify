module Forest::Shopify
  class ProductProductTag < Forest::Shopify::ApplicationRecord
    belongs_to :product, class_name: 'Forest::Shopify::Product', foreign_key: 'forest_shopify_product_id', optional: true
    belongs_to :product_tag, class_name: 'Forest::Shopify::ProductTag', foreign_key: 'forest_shopify_product_tag_id', optional: true
  end
end
