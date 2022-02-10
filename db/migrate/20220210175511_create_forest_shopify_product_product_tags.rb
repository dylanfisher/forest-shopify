class CreateForestShopifyProductProductTags < ActiveRecord::Migration[7.0]
  def change
    create_table :forest_shopify_product_product_tags do |t|
      t.references :forest_shopify_product, null: false, foreign_key: true, index: { name: 'index_forest_shopify_product_product_tags_on_f_s_p_id' }
      t.references :forest_shopify_product_tag, null: false, foreign_key: true, index: { name: 'index_forest_shopify_product_product_tags_on_f_s_p_tag_id' }

      t.timestamps
    end
  end
end
