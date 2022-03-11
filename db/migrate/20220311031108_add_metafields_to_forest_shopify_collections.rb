class AddMetafieldsToForestShopifyCollections < ActiveRecord::Migration[6.0]
  def change
    add_column :forest_shopify_collections, :metafields, :jsonb, default: {}
    add_index :forest_shopify_collections, :metafields, using: :gin
  end
end
