class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :forest_shopify_products do |t|
      t.boolean :available_for_sale, default: false, null: false
      t.datetime :shopify_created_at
      t.text :description
      t.text :description_html
      t.string :handle
      t.string :shopify_id
      t.string :shopify_id_base64
      t.string :product_type
      t.datetime :shopify_published_at
      t.string :title
      t.string :slug
      t.integer :status, default: 1, null: false
      t.jsonb :blockable_metadata, default: {}

      t.timestamps
    end
    add_index :forest_shopify_products, :slug, unique: true
    add_index :forest_shopify_products, :status
    add_index :forest_shopify_products, :blockable_metadata, using: :gin
    add_index :forest_shopify_products, :shopify_id
    add_index :forest_shopify_products, :shopify_id_base64
    add_index :forest_shopify_products, :available_for_sale
    add_index :forest_shopify_products, :shopify_published_at
  end
end
