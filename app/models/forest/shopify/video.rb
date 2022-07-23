module Forest::Shopify
  class Video < Forest::Shopify::ApplicationRecord
    belongs_to :forest_shopify_record, polymorphic: true, touch: true
    belongs_to :poster_media_item, optional: true, touch: true, class_name: 'MediaItem', dependent: :destroy

    def width
      sources.first.try(:[], 'width')
    end

    def height
      sources.first.try(:[], 'height')
    end
  end
end
