class CreateForestShopifyProductTags < ActiveRecord::Migration[7.0]
  def change
    create_table :forest_shopify_product_tags do |t|
      t.string :name

      t.timestamps
    end

    add_index :forest_shopify_product_tags, :name
  end
end
