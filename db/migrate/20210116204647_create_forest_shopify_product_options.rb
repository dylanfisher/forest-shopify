class CreateForestShopifyProductOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :forest_shopify_product_options do |t|
      t.string :shopify_id
      t.string :shopify_id_base64
      t.string :name
      t.string :values
      t.references :forest_shopify_product, foreign_key: true, index: { name: 'index_forest_shopify_product_options_on_f_s_product_id' }

      t.timestamps
    end

    add_index :forest_shopify_product_options, :shopify_id
    add_index :forest_shopify_product_options, :shopify_id_base64
  end
end
