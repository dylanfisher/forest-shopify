class CreateForestShopifyCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :forest_shopify_collections do |t|
      t.text :description
      t.text :description_html
      t.string :handle
      t.string :shopify_id
      t.string :shopify_id_base64
      t.datetime :shopify_updated_at
      t.string :title
      t.string :slug
      t.integer :status, default: 1, null: false
      t.jsonb :blockable_metadata, default: {}

      t.timestamps
    end
    add_index :forest_shopify_collections, :slug, unique: true
    add_index :forest_shopify_collections, :status
    add_index :forest_shopify_collections, :blockable_metadata, using: :gin
    add_index :forest_shopify_collections, :shopify_id
    add_index :forest_shopify_collections, :shopify_id_base64
    add_index :forest_shopify_collections, :shopify_updated_at
  end
end
