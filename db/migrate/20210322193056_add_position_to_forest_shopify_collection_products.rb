class AddPositionToForestShopifyCollectionProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :forest_shopify_collection_products, :position, :integer
    add_index :forest_shopify_collection_products, :position
  end
end
