class Forest::Shopify::Storefront::Product < Forest::Shopify::Storefront
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Product::Query)
  # Forest::Shopify::Storefront::Product.sync

  Query = Client.parse <<-'GRAPHQL'
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
            variants(first: 250) {
              edges {
                cursor
                node {
                  availableForSale
                  compareAtPrice
                  id
                  price
                  sku
                  title
                  weight
                  weightUnit
                  image {
                    altText
                    id
                    src
                  }
                }
              }
              pageInfo {
                hasNextPage
              }
            }
            images(first: 250) {
              edges {
                node {
                  altText
                  id
                  src
                }
              }
              pageInfo {
                hasNextPage
              }
            }
            options(first: 250) {
              id
              name
              values
            }
            metafields(first: 250) {
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
            collections(first: 250) {
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
    response = Client.query(Query)
    has_next_page = response.data.products.page_info.has_next_page
    matched_shopify_ids = []
    page_index = 0

    while has_next_page || page_index.zero?
      page_index += 1
      products = response.data.products.edges.collect(&:node)
      product_cursor = response.data.products.edges.last.cursor

      puts "[Forest][Shopify] Syncing Products" if Rails.env.development?

      products.each do |product|
        matched_shopify_ids << product.id

        # TODO: do we need to check the product/variant position field?

        forest_shopify_product = Forest::Shopify::Product.find_or_initialize_by(shopify_id_base64: product.id)
        puts "[Forest][Shopify] -- #{product.title}" if Rails.env.development?
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
        forest_shopify_product.save!

        images = product.images.edges.collect(&:node)
        # Delete obsolete images that no longer exist in Shopify
        forest_shopify_product.images.where.not(shopify_id_base64: images.collect(&:id)).destroy_all
        create_images(images: images, forest_shopify_record: forest_shopify_product)
        create_variants(product: product, forest_shopify_product: forest_shopify_product)
      end

      if has_next_page
        response = Client.query(Query, variables: { after: product_cursor })
        has_next_page = response.data.products.page_info.has_next_page
      end
    end

    # Delete unmatched forest shopify products
    Forest::Shopify::Product.where.not(shopify_id_base64: matched_shopify_ids).destroy_all

    # TODO: this won't work with the current implementation of settings, which don't play nicely with the I18n import
    # # Keep track of the last time the sync was run via a setting
    # last_run_setting = Setting.find_or_initialize_by(slug: 'forest_shopify_last_sync_products')
    # last_run_setting.assign_attributes({
    #   value: Time.current.to_i
    # })
    # last_run_setting.save!

    true
  end

  def self.create_variants(product:, forest_shopify_product:)
    variants = product.variants
    nodes = variants.edges.collect(&:node)
    has_next_page = variants.page_info.has_next_page
    page_index = 1

    nodes.each do |variant|
      forest_shopify_variant = Forest::Shopify::Variant.find_or_initialize_by({ forest_shopify_product_id: forest_shopify_product.id, shopify_id_base64: variant.id })
      puts "[Forest][Shopify] ----  #{variant.title}" if Rails.env.development?
      forest_shopify_variant.assign_attributes({
        shopify_id_base64: variant.id,
        title: variant.title,
        available_for_sale: variant.available_for_sale,
        compare_at_price: variant.compare_at_price,
        price: variant.price,
        sku: variant.sku,
        weight: variant.weight,
        weight_unit: variant.weight_unit
      })
      forest_shopify_variant.save!

      create_images(images: variant.image, forest_shopify_record: forest_shopify_variant)
    end

    # TODO: handle variant pagination

    true
  end

  def self.create_images(images:, forest_shopify_record:)
    Array(images).each_with_index do |image, index|
      forest_shopify_image = Forest::Shopify::Image.find_or_initialize_by({
        forest_shopify_record_id: forest_shopify_record.id,
        forest_shopify_record_type: forest_shopify_record.class.name,
        shopify_id_base64: image.id
      })
      forest_shopify_image.assign_attributes({
        alt_text: image.alt_text,
        src: image.src
      })
      if forest_shopify_image.media_item.blank?
        media_item = MediaItem.new({
          title: "#{forest_shopify_record.title} image #{index + 1}",
          alternative_text: image.alt_text,
          media_item_status: 'hidden'
        })
        media_item.attachment = uploader.upload(URI.open(image.src))
        forest_shopify_image.media_item = media_item
        media_item.save!
      end
      forest_shopify_image.save!
    end
  end
end
