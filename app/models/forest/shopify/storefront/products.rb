class Forest::Shopify::Storefront::Products
  # Forest::Shopify::Storefront::Products.sync

  Query = Forest::Shopify::Storefront::Client.parse <<-'GRAPHQL'
    query($after: String) {
      products(first: 250, after: $after) {
        pageInfo {
          hasNextPage
        }
        edges {
          cursor
          node {
            availableForSale
            createdAt
            description
            descriptionHtml
            handle
            id
            productType
            publishedAt
            title
            variants(first: 10) {
              edges {
                node {
                  available
                  availableForSale
                  compareAtPrice
                  id
                  price
                  sku
                  title
                  weight
                  weightUnit
                }
              }
            }
            images(first: 10) {
              edges {
                node {
                  altText
                  id
                  src
                }
              }
            }
            options(first: 3) {
              id
              name
              values
            }
            metafields(first: 10) {
              edges {
                cursor
                node {
                  description
                  id
                  key
                  namespace
                  value
                  valueType
                }
              }
              pageInfo {
                hasNextPage
              }
            }
            collections(first: 10) {
              edges {
                cursor
                node {
                  id
                  title
                  description
                  handle
                }
              }
              pageInfo {
                hasNextPage
              }
            }
          }
        }
      }
    }
  GRAPHQL

  def self.sync
    response = Forest::Shopify::Storefront::Client.query(Query)
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

        forest_shopify_product = Forest::Shopify::Product.find_or_initialize_by(shopify_id_base64: product.id)
        puts "[Forest][Shopify]   #{product.title}" if Rails.env.development?
        forest_shopify_product.assign_attributes({
          available_for_sale: product.available_for_sale,
          shopify_created_at: DateTime.parse(product.created_at),
          description: product.description,
          description_html: product.description_html,
          handle: product.handle,
          shopify_id_base64: product.id,
          product_type: product.product_type,
          shopify_published_at: DateTime.parse(product.published_at),
          title: product.title,
        })
        forest_shopify_product.save
      end

      if has_next_page
        response = Forest::Shopify::Storefront::Client.query(Query, variables: { after: product_cursor })
        has_next_page = response.data.products.page_info.has_next_page
      end
    end

    # Delete unmatched forest shopify products
    Forest::Shopify::Product.where.not(shopify_id_base64: matched_shopify_ids).destroy_all

    # Keep track of the last time the sync was run via a setting
    last_run_setting = Setting.find_or_initialize_by(slug: 'forest_shopify_last_sync_products')
    last_run_setting.update(value: Time.current.to_i)

    true
  end
end
