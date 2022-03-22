module Forest::Shopify
  class Image < Forest::Shopify::ApplicationRecord
    belongs_to :forest_shopify_record, polymorphic: true, touch: true
    belongs_to :media_item, touch: true

    after_destroy :destroy_orphaned_media_items

    private

    def destroy_orphaned_media_items
      unless Forest::Shopify::Image.exists?(media_item: self.media_item)
        self.media_item.destroy if self.media_item.present?
      end
    end
  end
end
