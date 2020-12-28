class CreateForestShopifyImages < ActiveRecord::Migration[6.0]
  def change
    create_table :forest_shopify_images do |t|
      t.references :forest_shopify_record, polymorphic: true, index: { name: 'index_forest_shopify_imgs_on_f_s_record_type_and_f_s_record_id' }
      t.references :media_item, null: false, foreign_key: true
      t.string :shopify_id_base64
      t.text :alt_text
      t.text :src

      t.timestamps
    end
    add_index :forest_shopify_images, :shopify_id_base64
  end
end
