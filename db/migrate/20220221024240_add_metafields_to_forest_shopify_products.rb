class AddMetafieldsToForestShopifyProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :forest_shopify_products, :metafields, :jsonb, default: {}
    add_index :forest_shopify_products, :metafields, using: :gin
  end
end
