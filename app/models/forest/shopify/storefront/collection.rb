class Forest::Shopify::Storefront::Collection < Forest::Shopify::Storefront
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Collection::Query)
  # Forest::Shopify::Storefront::Collection.sync

  LAST_SYNC_SETTING_SLUG = 'forest_shopify_collection_last_sync'

  if Forest::Shopify::Product::METAFIELD_IDENTIFIERS.present?
    METAFIELDS_NODE = <<-"GRAPHQL"
      metafields(identifiers: #{Forest::Shopify::Collection::METAFIELD_IDENTIFIERS}) {
      key
      value
    }
    GRAPHQL
  else
    METAFIELDS_NODE = nil
  end

  COLLECTION_NODE = <<-"GRAPHQL"
    {
      id
      title
      description
      descriptionHtml
      handle
      updatedAt
      #{METAFIELDS_NODE}
      image {
        altText
        id
        src
      }
      products(first: 250) {
        edges {
          cursor
          node {
            id
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
      collections(first: 250, after: $after) {
        pageInfo {
          hasNextPage
        }
        edges {
          cursor
          node #{COLLECTION_NODE}
        }
      }
    }
  GRAPHQL

  Query_Single = Client.parse <<-"GRAPHQL"
    query($id: ID!) {
      node(id: $id) {
        ... on Collection #{COLLECTION_NODE}
      }
    }
  GRAPHQL

  def self.sync(shopify_id_base64: nil)
    if shopify_id_base64.present?
      response = Client.query(Query_Single, variables: { id: shopify_id_base64 })
      has_next_page = false
    else
      response = Client.query(Query)
      has_next_page = response.data.collections.page_info.has_next_page
    end

    matched_shopify_ids = []
    page_index = 0

    while has_next_page || page_index.zero?
      page_index += 1

      if shopify_id_base64.present?
        collections = Array(response.data.node)
      else
        collections = response.data.collections.edges.collect(&:node)
        collection_cursor = response.data.collections.edges.last.cursor
      end

      record_cache = Forest::Shopify::Collection.where(shopify_id_base64: collections.collect { |c| Forest::Shopify::Storefront.encode_shopify_id(c.id) })

      puts "[Forest][Shopify] Syncing collections" if Rails.env.development?

      collections.each do |collection|
        collection_id_base_64 = Forest::Shopify::Storefront.encode_shopify_id(collection.id)
        matched_shopify_ids << collection_id_base_64

        forest_shopify_collection = record_cache.find { |r| r.shopify_id_base64 == collection_id_base_64 }.presence || Forest::Shopify::Collection.find_or_initialize_by(shopify_id_base64: collection_id_base_64)

        puts "[Forest][Shopify] -- #{collection.title}" if Rails.env.development?

        metafields = Forest::Shopify::Product::METAFIELD_IDENTIFIERS.present? ? collection.metafields.reject(&:blank?) : []
        metafields_hash = {}
        metafields.each { |m| metafields_hash[m.key] = m.value }

        forest_shopify_collection.assign_attributes({
          description: collection.description,
          description_html: collection.description_html,
          handle: collection.handle,
          slug: collection.handle,
          shopify_id_base64: collection_id_base_64,
          shopify_updated_at: DateTime.parse(collection.updated_at),
          title: collection.title,
          metafields: metafields_hash
        })
        forest_shopify_collection.save! if forest_shopify_collection.changed?

        # TODO: handle collection product pagination
        collection_product_ids = collection.products.edges.collect(&:node).collect { |p| Forest::Shopify::Storefront.encode_shopify_id(p.id) }
        forest_shopify_collection_products = Forest::Shopify::Product.where(shopify_id_base64: collection_product_ids)
        forest_shopify_collection_product_ids = {}
        forest_shopify_collection_products.each { |p| forest_shopify_collection_product_ids[p.id] = p.shopify_id_base64 }
        forest_shopify_collection.products = forest_shopify_collection_products
        forest_shopify_collection.collection_products.each do |collection_product|
          matching_shopify_id = forest_shopify_collection_product_ids[collection_product.forest_shopify_product_id]
          position = collection_product_ids.index(matching_shopify_id)
          collection_product.assign_attributes({ position: position })
          collection_product.save! if collection_product.changed?
        end

        if collection.image.present?
          create_images(images: collection.image, forest_shopify_record: forest_shopify_collection)
        elsif forest_shopify_collection.image.present?
          forest_shopify_collection.image.destroy
        end
      end

      if has_next_page
        response = Client.query(Query, variables: { after: collection_cursor })
        has_next_page = response.data.collections.page_info.has_next_page
      end
    end

    # Delete unmatched forest shopify collections
    unless shopify_id_base64.present?
      Forest::Shopify::Collection.where.not(shopify_id_base64: matched_shopify_ids).destroy_all
      if Setting.has_attribute?(:setting_status)
        Setting.find_or_create_by(slug: LAST_SYNC_SETTING_SLUG, value_type: 'integer', setting_status: 'hidden').update_columns(value: Time.current.to_i)
        Setting.expire_cache!
      end
    end

    true
  end
end
