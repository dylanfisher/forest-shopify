class AddPositionToForestShopifyImages < ActiveRecord::Migration[6.0]
  def change
    add_column :forest_shopify_images, :position, :integer, default: 0, null: false
    add_index :forest_shopify_images, :position
  end
end
