class CreateForestShopifyProductImages < ActiveRecord::Migration[6.1]
  def change
    create_table :forest_shopify_product_images do |t|
      t.references :forest_shopify_product, null: false, foreign_key: true, index: { name: 'index_forest_shopify_prod_images_on_forest_shopify_prod_id' }
      t.references :media_item, null: false, foreign_key: true
      t.string :shopify_id_base64
      t.text :alt_text
      t.text :src

      t.timestamps
    end
    add_index :forest_shopify_product_images, :shopify_id_base64
  end
end
