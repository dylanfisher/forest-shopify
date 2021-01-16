class AddSelectedOptionsToForestShopifyVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :forest_shopify_variants, :selected_options, :text
  end
end
