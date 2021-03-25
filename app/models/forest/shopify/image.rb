module Forest::Shopify
  class Image < Forest::Shopify::ApplicationRecord
    belongs_to :forest_shopify_record, polymorphic: true, touch: true
    belongs_to :media_item, dependent: :destroy, touch: true
  end
end
