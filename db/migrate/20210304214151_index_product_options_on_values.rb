class IndexProductOptionsOnValues < ActiveRecord::Migration[6.0]
  def change
    add_index :forest_shopify_product_options, :values
  end
end
