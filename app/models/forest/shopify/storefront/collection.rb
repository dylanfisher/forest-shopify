class Forest::Shopify::Storefront::Collection < Forest::Shopify::Storefront
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Collection::Query)
  # Forest::Shopify::Storefront::Collection.sync

  COLLECTION_NODE = <<-'GRAPHQL'
    {
      id
      title
      description
      descriptionHtml
      handle
      updatedAt
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

      puts "[Forest][Shopify] Syncing collections" if Rails.env.development?

      collections.each do |collection|
        matched_shopify_ids << collection.id

        forest_shopify_collection = Forest::Shopify::Collection.find_or_initialize_by(shopify_id_base64: collection.id)

        puts "[Forest][Shopify] -- #{collection.title}" if Rails.env.development?

        forest_shopify_collection.assign_attributes({
          description: collection.description,
          description_html: collection.description_html,
          handle: collection.handle,
          slug: collection.handle,
          shopify_id_base64: collection.id,
          shopify_updated_at: DateTime.parse(collection.updated_at),
          title: collection.title,
        })
        forest_shopify_collection.save!

        # TODO: handle collection product pagination
        collection_product_ids = collection.products.edges.collect(&:node).collect(&:id)
        forest_shopify_collection.products = Forest::Shopify::Product.where(shopify_id_base64: collection_product_ids)

        create_images(images: collection.image, forest_shopify_record: forest_shopify_collection)
      end

      if has_next_page
        response = Client.query(Query, variables: { after: collection_cursor })
        has_next_page = response.data.collections.page_info.has_next_page
      end
    end

    # Delete unmatched forest shopify collections
    unless shopify_id_base64.present?
      Forest::Shopify::Collection.where.not(shopify_id_base64: matched_shopify_ids).destroy_all
    end

    true
  end
end
