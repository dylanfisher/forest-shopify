class CreateVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :forest_shopify_variants do |t|
      t.string :title
      t.string :shopify_id_base64
      t.string :price
      t.boolean :available_for_sale
      t.string :compare_at_price
      t.string :sku
      t.float :weight
      t.string :weight_unit
      t.references :forest_shopify_product, index: true
      t.string :slug
      t.integer :status, default: 1, null: false

      t.timestamps
    end
    add_index :forest_shopify_variants, :slug, unique: true
    add_index :forest_shopify_variants, :status
    add_index :forest_shopify_variants, :shopify_id_base64
    add_index :forest_shopify_variants, :available_for_sale
  end
end
