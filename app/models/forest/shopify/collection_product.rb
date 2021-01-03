module Forest::Shopify
  class CollectionProduct < Forest::ApplicationRecord
    belongs_to :forest_shopify_collection, class_name: 'Forest::Shopify::Collection'
    belongs_to :forest_shopify_product, class_name: 'Forest::Shopify::Product'
  end
end
