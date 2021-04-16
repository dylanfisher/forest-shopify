class Forest::Shopify::Storefront::Product < Forest::Shopify::Storefront
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Product::Query)
  # Forest::Shopify::Storefront::Product.sync

  PRODUCT_NODE = <<-'GRAPHQL'
    {
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
            selectedOptions {
              name
              value
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
    }
  GRAPHQL

  Query = Client.parse <<-"GRAPHQL"
    query($after: String) {
      products(first: 250, after: $after) {
        pageInfo {
          hasNextPage
        }
        edges {
          cursor
          node #{PRODUCT_NODE}
        }
      }
    }
  GRAPHQL

  Query_Single = Client.parse <<-"GRAPHQL"
    query($id: ID!) {
      node(id: $id) {
        ... on Product #{PRODUCT_NODE}
      }
    }
  GRAPHQL

  def self.sync(shopify_id_base64: nil)
    if shopify_id_base64.present?
      response = Client.query(Query_Single, variables: { id: shopify_id_base64 })
      has_next_page = false
    else
      response = Client.query(Query)
      has_next_page = response.data.products.page_info.has_next_page
    end

    matched_shopify_ids = []
    page_index = 0

    while has_next_page || page_index.zero?
      page_index += 1

      if shopify_id_base64.present?
        products = Array(response.data.node)
      else
        products = response.data.products.edges.collect(&:node)
        product_cursor = response.data.products.edges.last.try(:cursor)
      end

      puts "[Forest][Shopify] Syncing Products" if Rails.env.development?

      # Look up and store products in a cahe to help limit N+1 query
      record_cache = Forest::Shopify::Product.where(shopify_id_base64: products.collect(&:id))

      products.each do |product|
        matched_shopify_ids << product.id

        forest_shopify_product = record_cache.find { |r| r.shopify_id_base64 == product.id }.presence || Forest::Shopify::Product.find_or_initialize_by(shopify_id_base64: product.id)

        puts "[Forest][Shopify] -- #{product.title}" if Rails.env.development?

        forest_shopify_product.assign_attributes({
          available_for_sale: product.available_for_sale,
          shopify_created_at: DateTime.parse(product.created_at),
          description: product.description,
          description_html: product.description_html,
          handle: product.handle,
          slug: product.handle,
          shopify_id_base64: product.id,
          product_type: product.product_type,
          shopify_published_at: DateTime.parse(product.published_at),
          title: product.title,
          status: 'published',
        })
        forest_shopify_product.save! if forest_shopify_product.changed?

        images = product.images.edges.collect(&:node)

        # Delete obsolete records that no longer exist in Shopify
        forest_shopify_product.images.where.not(shopify_id_base64: images.collect(&:id))
        duplicate_records = []
        forest_shopify_product.images.group_by(&:shopify_id_base64).each do |shopify_id, records|
          if records.size > 1
            duplicate_records.concat(records[0..-2].collect(&:id))
          end
        end
        duplicate_records.flatten!
        Forest::Shopify::Image.where(id: duplicate_records).destroy_all if duplicate_records.present?

        forest_shopify_product.variants.where.not(shopify_id_base64: product.variants.edges.collect(&:node).collect(&:id)).destroy_all
        forest_shopify_product.product_options.where.not(shopify_id_base64: product.options.collect(&:id)).destroy_all

        # TODO: do we need to specity the image association like we do with a collection's image association?
        create_images(images: images, forest_shopify_record: forest_shopify_product)
        create_variants(product: product, forest_shopify_product: forest_shopify_product)
        create_product_options(product_options: product.options, forest_shopify_record: forest_shopify_product)
      end

      if has_next_page
        response = Client.query(Query, variables: { after: product_cursor })
        has_next_page = response.data.products.page_info.has_next_page
      end
    end

    # Set unmatched forest shopify products to hidden status. We do this rather than just delete
    # the products in case the user set the product to draft mode in Shopify and may have content
    # blocks associated with the product in Forest.
    unless shopify_id_base64.present?
      Forest::Shopify::Product.not_hidden.where.not(shopify_id_base64: matched_shopify_ids).find_each { |p| p.update(status: 'hidden') }
    end

    true
  end

  def self.create_variants(product:, forest_shopify_product:)
    variants = product.variants
    nodes = variants.edges.collect(&:node)
    has_next_page = variants.page_info.has_next_page
    page_index = 1

    record_cache = Forest::Shopify::Variant.where(forest_shopify_product_id: forest_shopify_product.id, shopify_id_base64: nodes.collect(&:id))

    nodes.each do |variant|
      forest_shopify_variant = record_cache.find { |r|
        r.forest_shopify_product_id == forest_shopify_product.id &&
        r.shopify_id_base64 == variant.id
      }.presence || Forest::Shopify::Variant.find_or_initialize_by({
        forest_shopify_product_id: forest_shopify_product.id,
        shopify_id_base64: variant.id
      })

      selected_options = {}
      variant.selected_options.each { |so| selected_options[so.name] = so.value }

      puts "[Forest][Shopify] ----  #{variant.title}" if Rails.env.development?
      forest_shopify_variant.assign_attributes({
        shopify_id_base64: variant.id,
        title: variant.title,
        available_for_sale: variant.available_for_sale,
        compare_at_price: variant.compare_at_price,
        price: variant.price,
        selected_options: selected_options,
        sku: variant.sku,
        weight: variant.weight,
        weight_unit: variant.weight_unit
      })
      forest_shopify_variant.save! if forest_shopify_variant.changed?

      create_images(images: variant.image, forest_shopify_record: forest_shopify_variant)
    end

    # TODO: handle variant pagination

    true
  end

  def self.create_product_options(product_options:, forest_shopify_record:)
    product_options = Array(product_options)

    record_cache = Forest::Shopify::ProductOption.where(forest_shopify_product_id: forest_shopify_record.id, shopify_id_base64: product_options.collect(&:id))

    product_options.each do |product_option|
      forest_shopify_product_option = record_cache.find { |r|
        r.forest_shopify_product_id == forest_shopify_record.id &&
        r.shopify_id_base64 == product_option.id
      }.presence || Forest::Shopify::ProductOption.find_or_initialize_by({
        forest_shopify_product_id: forest_shopify_record.id,
        shopify_id_base64: product_option.id
      })

      forest_shopify_product_option.assign_attributes({
        name: product_option.name,
        values: product_option.values.to_a
      })

      forest_shopify_product_option.save! if forest_shopify_product_option.changed?
    end
  end
end
