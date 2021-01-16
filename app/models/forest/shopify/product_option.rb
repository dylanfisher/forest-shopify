module Forest::Shopify
  class ProductOption < Forest::Shopify::ApplicationRecord
    serialize :values

    belongs_to :product, class_name: 'Forest::Shopify::ProductOption', foreign_key: 'forest_shopify_product_id', optional: true
  end
end
