class AddMediaItemToForestShopifyProductTags < ActiveRecord::Migration[7.0]
  def change
    add_reference :forest_shopify_product_tags, :media_item, null: true, foreign_key: true
  end
end
