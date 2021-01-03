class CreateForestShopifyCollectionProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :forest_shopify_collection_products do |t|
      t.references :forest_shopify_collection, null: false, foreign_key: true, index: { name: 'index_forest_shopify_collection_products_on_f_s_collection_id' }
      t.references :forest_shopify_product, null: false, foreign_key: true, index: { name: 'index_forest_shopify_collection_products_on_f_s_product_id' }

      t.timestamps
    end
  end
end
