class AddSlugToForestShopifyProductTags < ActiveRecord::Migration[7.0]
  def change
    add_column :forest_shopify_product_tags, :slug, :string
    add_index :forest_shopify_product_tags, :slug, unique: true
  end
end
