namespace :forest do
  namespace :shopify do
    desc 'Sync all Shopify storefront API endpoints.'
    task :sync_all => :environment do
      response = Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Products::Query)
      has_next_page = response.data.products.page_info.has_next_page
      matched_shopify_ids = []
      page_index = 0

      while has_next_page || page_index.zero?
        page_index += 1
        products = response.data.products.edges.collect(&:node)
        product_cursor = response.data.products.edges.last.cursor

        puts "[Forest][Shopify] Syncing product page index - #{page_index}" if Rails.env.development?

        products.each do |product|
          matched_shopify_ids << product.id

          forest_shopify_product = Forest::Shopify::Product.find_or_initialize_by(shopify_id: product.id)
          puts "[Forest][Shopify]   #{product.title}" if Rails.env.development?
          forest_shopify_product.assign_attributes({
            available_for_sale: product.available_for_sale,
            shopify_created_at: DateTime.parse(product.created_at),
            description: product.description,
            description_html: product.description_html,
            handle: product.handle,
            shopify_id: product.id,
            product_type: product.product_type,
            shopify_published_at: DateTime.parse(product.published_at),
            title: product.title,
          })
          forest_shopify_product.save
        end

        if has_next_page
          response = Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Products::Query, variables: { after: product_cursor })
          has_next_page = response.data.products.page_info.has_next_page
        end
      end

      # Delete unmatched forest shopify products
      Forest::Shopify::Product.where.not(shopify_id: matched_shopify_ids).destroy_all
    end
  end
end
