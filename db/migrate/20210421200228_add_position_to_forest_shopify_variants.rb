class AddPositionToForestShopifyVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :forest_shopify_variants, :position, :integer, default: 0, null: false
    add_index :forest_shopify_variants, :position
  end
end
