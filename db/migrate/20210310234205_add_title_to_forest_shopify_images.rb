class AddTitleToForestShopifyImages < ActiveRecord::Migration[6.0]
  def change
    add_column :forest_shopify_images, :title, :string
  end
end
