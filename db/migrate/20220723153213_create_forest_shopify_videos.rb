class CreateForestShopifyVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :forest_shopify_videos do |t|
      t.references :forest_shopify_record, polymorphic: true, index: { name: 'index_forest_shopify_vids_on_f_s_record_type_and_f_s_record_id' }
      t.references :poster_media_item, null: true, foreign_key: { to_table: :media_items }
      t.string :shopify_id_base64
      t.jsonb :sources, default: {}
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :forest_shopify_videos, :shopify_id_base64
    add_index :forest_shopify_videos, :position
  end
end
